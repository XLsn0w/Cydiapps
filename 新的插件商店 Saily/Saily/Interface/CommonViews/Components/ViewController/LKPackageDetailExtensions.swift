//
//  LKPackageDetailExtensions.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/22.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// 内玩意太长了我吃不消 啧啧啧

import WebKit
import AVFoundation
import SwiftyMarkdown

extension LKPackageDetail: UIScrollViewDelegate {
    
    func updateColor() {
        view.backgroundColor = self.theme_color_bak
        banner_section.button.startDownloadButtonNonhighlightedTitleColor = .white
        banner_section.button.startDownloadButtonNonhighlightedBackgroundColor = theme_color
        banner_section.button.pendingCircleColor = .lightGray
        banner_section.button.downloadingButtonHighlightedTrackCircleColor = theme_color
        banner_section.button.downloadingButtonNonhighlightedTrackCircleColor = .lightGray
        scrollViewDidScroll(contentView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if contentView == scrollView {
            // 基准线
            var base = CGFloat(233)
            if #available(iOS 11.0, *) {
                base -= (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
            }
            base -= (self.navigationController?.navigationBar.frame.height ?? 0)
            base -= (self.navigationController?.navigationBar.frame.height ?? 0)
            base -= 20
            let offset = self.contentView.contentOffset
            // 基准线 - 当前线 超过部分变透明
            var calc = (offset.y - base) / 66
            if calc > 0.9 {
                calc = 1
            }
            let bannerc = self.theme_color_bak
            let red = bannerc.redRead()
            let green = bannerc.greenRead()
            let blue = bannerc.blueRead()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: red,
                                                                               green: blue,
                                                                               blue: blue,
                                                                               alpha: calc)
            self.status_bar_cover.backgroundColor = UIColor(red: red,
                                                            green: green,
                                                            blue: blue,
                                                            alpha: calc)
            var text_color: UIColor
            if !self.tint_color_consit {
                text_color = theme_color.transit2white(percent: 1 - calc)
            } else {
                text_color = theme_color
            }
            self.navigationController?.navigationBar.tintColor = text_color
            calc = (offset.y - base - 98) / 60
            if calc > 1 {
                calc = 1
            }
            if !self.tint_color_consit {
                text_color = theme_color.transit2white(percent: 1 - calc)
            } else {
                text_color = theme_color
            }
            text_color = UIColor(red: Int(text_color.redRead() * 255),
                                 green: Int(text_color.greenRead() * 255),
                                 blue: Int(text_color.blueRead() * 255),
                                 transparency: calc) ?? text_color
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: text_color]
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if contentView == scrollView {
            if scrollView.contentOffset.y > 48 && scrollView.contentOffset.y < 256 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                    if #available(iOS 11.0, *) {
                        self.contentView.contentOffset.y = 233 -
                            (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) -
                            (self.navigationController?.navigationBar.frame.height ?? 0)
                    } else {
                        // Fallback on earlier versions
                        self.contentView.contentOffset.y = 233 -
                            (self.navigationController?.navigationBar.frame.height ?? 0)
                    }
                }, completion: { (_) in
                })
            }
        }
    }
}

// 死了哦

extension LKPackageDetail {
    
    func doJsonSetupLevelRoot(json: [String : Any]) {
        if let img_addr = json["headerImage"] as? String {
            self.banner_image.sd_setImage(with: URL(string: img_addr)) { (_, _, _, _) in
    
            }
        }
        
        if let tint_color = json["tintColor"] as? String {
            if let color = UIColor(hexString: tint_color) {
                self.theme_color = color
            }
        }
        
        if let back_color = json["backgroundColor"] as? String {
            if let color = UIColor(hexString: back_color) {
                self.theme_color_bak = color
            }
        }
        
        if let tabs = json["tabs"] as? [[String : Any]] {
            doJsonSetUpLevelTabs(tabs: tabs)
        }
        
    }
    
    func doJsonSetUpLevelTabs(tabs: [[String: Any]]) {
        
        // tab 好像不需要排序
        
        for tab in tabs {
            
            if let someString = tab["tabname"] as? String {
                let header = common_views.LKSectionBeginHeader()
                if let someString = tab["tintColor"] as? String {
                    header.theme_color = UIColor(hexString: someString)
                } else {
                    header.theme_color = theme_color
                }
                header.apart_init(section_name: someString.uppercased())
                contentView.addSubview(header)
                header.snp.makeConstraints { (x) in
                    x.top.equalTo(self.currentAnchor.snp.bottom)
                    x.height.equalTo(50)
                    x.left.equalTo(self.view.snp.left)
                    x.right.equalTo(self.view.snp.right)
                }
                currentAnchor = header
                using_bottom_margins(height: 4)
                sum_content_height += 37
            }
            
            
            for view in tab["views"] as? [[String : Any]] ?? [] {
                // (lldb) po ((tab["views"] as! [[String : Any]]))[0]
                // view 的类型是 [String : Any]
                if let class_name = view["class"] as? String {
                    switch class_name {
                    case "DepictionHeaderView": setup_HeaderView(object: view)
                    case "DepictionSubheaderView": setup_SubheaderView(object: view)
                    case "DepictionLabelView": setup_LabelView(object: view)
                    case "DepictionMarkdownView": setup_MarkdownView(object: view)
                    case "DepictionVideoView": setup_VideoView(object: view)
                    case "DepictionImageView": setup_ImageView(object: view)
                    case "DepictionScreenshotsView": setup_ScreenshotsView(object: view)
                    case "DepictionTableTextView": setup_TableTextView(object: view)
                    case "DepictionTableButtonView": setup_TableButtonView(object: view)
                    case "DepictionButtonView": setup_ButtonView(object: view)
                    case "DepictionSeparatorView": setup_SeparatorView(object: view)
                    case "DepictionSpacerView": setup_SpacerView(object: view)
                    case "DepictionAdmobView": setup_AdmobView(object: view)
                    case "DepictionRatingView": setup_RatingView(object: view)
                    case "DepictionReviewView": setup_ReviewView(object: view)
                    case "DepictionStackView": doJsonSetUpLevelTabs(tabs: [view]) // This is for you: Nepeta
                    default: print("[?] 这嘛子玩意嘛： " + class_name)
                    }
                } else {
                    print("[?] 这个 view 没有 class ？")
                }
            }
        } // for tab in tabs {
        updateColor()
        
        using_bottom_margins()
        sum_content_height += 128
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.233) { [weak self] in
            self?.contentView.contentSize.height = CGFloat(self?.sum_content_height ?? 0)
        }
        
        
    }
    
    func using_bottom_margins(height: Int = 16) {
        let d = UIView()
        contentView.addSubview(d)
        d.snp.makeConstraints { (x) in
            x.centerX.equalTo(self.view.snp.centerX)
            x.width.equalTo(0)
            x.top.equalTo(self.currentAnchor.snp.bottom)
            x.height.equalTo(height)
        }
        self.currentAnchor = d
        sum_content_height += height
    }
    
    func setup_HeaderView(object: [String : Any]) {
        let subHeader = UILabel(text: object["title"] as? String ?? "")
        subHeader.font = .boldSystemFont(ofSize: 20)
        subHeader.textColor = self.theme_color
        subHeader.numberOfLines = 2
        if let alig_t = object["alignment"] as? Int {
            if alig_t == 1 {
                subHeader.textAlignment = .center
            } else if alig_t == 2 {
                subHeader.textAlignment = .right
            }
        }
        contentView.addSubview(subHeader)
        subHeader.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(18)
            x.right.equalTo(self.view.snp.right).offset(-18)
            x.top.equalTo(self.currentAnchor.snp.bottom).offset(4)
            x.height.equalTo(40)
        }
        if object["useMargins"] as? Bool ?? true {
            currentAnchor = subHeader
            sum_content_height += 44
        }
        if object["useBottomMargin"] as? Bool ?? true {
            using_bottom_margins(height: 8)
            sum_content_height += 8
        }
    }
    
    func setup_SubheaderView(object: [String : Any]) {
        let subHeader = UILabel(text: object["title"] as? String ?? "")
        subHeader.font = .boldSystemFont(ofSize: 14)
        subHeader.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
        subHeader.numberOfLines = 2
        contentView.addSubview(subHeader)
        subHeader.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(18)
            x.right.equalTo(self.view.snp.right).offset(-18)
            x.top.equalTo(self.currentAnchor.snp.bottom).offset(4)
            x.height.equalTo(25)
        }
        if object["useMargins"] as? Bool ?? true {
            currentAnchor = subHeader
            sum_content_height += 25
        }
        if object["useBottomMargin"] as? Bool ?? true {
            using_bottom_margins()
            sum_content_height += 16
        }
    }
    
    func setup_LabelView(object: [String : Any]) {
        
    }
    
    func setup_MarkdownView(object: [String : Any]) {
        
        guard let text = object["markdown"] as? String else {
            return
        }
        
        let markdown = UITextView()
        markdown.backgroundColor = .clear
        markdown.font = .boldSystemFont(ofSize: 14)
        if object["useRawFormat"] as? Bool ?? false || (text.contains("<") && text.contains("</")) || text.contains("<br") {
            markdown.attributedText = text.htmlToAttributedString
        } else {
            let atr_text = SwiftyMarkdown(string: text).attributedString().mutableCopy() as? NSMutableAttributedString
            atr_text?.setFontFace(font: .boldSystemFont(ofSize: 14))
            markdown.attributedText = atr_text
        }
        markdown.isEditable = false
        markdown.isScrollEnabled = false
        markdown.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        contentView.addSubview(markdown)
        markdown.snp.makeConstraints { (x) in
            x.top.equalTo(self.currentAnchor.snp.bottom)
            x.left.equalTo(self.view.snp.left)
            x.right.equalTo(self.view.snp.right)
        }
        let currentAnchorSnapshot = self.currentAnchor
        DispatchQueue.main.async {
            let h = markdown.sizeThatFits(CGSize(width: self.view.frame.width - 28, height: .infinity))
            markdown.snp.remakeConstraints { (x) in
                x.top.equalTo(currentAnchorSnapshot.snp.bottom)
                x.left.equalTo(self.view.snp.left).offset(14)
                x.right.equalTo(self.view.snp.right).offset(-14)
                x.height.equalTo(h)
            }
            if object["useMargins"] as? Bool ?? true {
                self.sum_content_height += Int(h.height)
            }
        }
        
        if object["useMargins"] as? Bool ?? true {
            currentAnchor = markdown
        }
        
    }
    
    func setup_VideoView(object: [String : Any]) {
        
    }
    
    func setup_ImageView(object: [String : Any]) {
        
        guard let width = object["width"] as? Double else {
            return
        }
        
        guard let height = object["height"] as? Double else {
            return
        }
        
        guard let url_str = object["URL"] as? String else {
            return
        }
        
        guard let url = URL(string: url_str) else {
            return
        }
        
        guard let radius = object["cornerRadius"] as? Double else {
            return
        }
        
        let horizPadding = object["horizontalPadding"] as? Double
        
        if let somePadding = horizPadding {
            using_bottom_margins(height: Int(somePadding))
            sum_content_height += Int(somePadding)
        }
        
        let image = UIImageView()
        contentView.addSubview(image)
        image.snp.makeConstraints { (x) in
            x.centerX.equalTo(self.view.center)
            x.top.equalTo(self.currentAnchor.snp.bottom)
            x.width.equalTo(width)
            x.height.equalTo(height)
        }
        sum_content_height += Int(height)
        image.sd_setImage(with: url, completed: nil)
        image.setRadiusCGF(radius: CGFloat(radius))
        currentAnchor = image
        
        if let somePadding = horizPadding {
            using_bottom_margins(height: Int(somePadding))
            sum_content_height += Int(somePadding)
        }
        
        if let somePadding = horizPadding {
            using_bottom_margins(height: Int(somePadding))
        }
    }
    
    func setup_ScreenshotsView(object: [String : Any]) {
        
        var object = object
        
        guard var screenshotsObjects = object["screenshots"] as? [[String : Any]] else {
            return
        }
        
        if object["ipad"] != nil && LKRoot.is_iPad {
            object = object["ipad"] as? [String : Any] ?? ["" : ""]
            guard let screenshotsObjects2 = object["screenshots"] as? [[String : Any]] else {
                return
            }
            screenshotsObjects = screenshotsObjects2
        }
        
        guard let itemSizeStr = object["itemSize"] as? String else {
            return
        }
        //        I was stupid that.
        //        let i1 = itemSizeStr.dropFirst().split(separator: ",").first?.to_String().drop_space() ?? "0"
        //        let i2 = itemSizeStr.dropLast().split(separator: ",").last?.to_String().drop_space() ?? "0"
        //        let itemSize = CGSize(width: Double(i1) ?? 0, height: Double(i2) ?? 0)
        //        if itemSize.width <= 0 || itemSize.height <= 0 {
        //            return
        //        }
        let itemSize = NSCoder.cgSize(for: itemSizeStr)
        if itemSize.width <= 0 || itemSize.height <= 0 {
            return
        }
        guard let radius = object["itemCornerRadius"] as? Int else {
            return
        }
        
        // 开始创建stacks
        let container = UIScrollView()
        let placeholder = UIView()
        contentView.addSubview(placeholder)
        contentView.addSubview(container)
        container.showsVerticalScrollIndicator = false
        container.showsHorizontalScrollIndicator = false
        container.isUserInteractionEnabled = true
        container.decelerationRate = .fast
        container.contentSize = CGSize(width: screenshotsObjects.count * (Int(itemSize.width) + 18) + 18, height: 0)
        placeholder.snp.makeConstraints { (x) in
            x.centerX.equalTo(self.view.snp.centerX)
            x.width.equalTo(0)
            x.top.equalTo(self.currentAnchor.snp.bottom).offset(8)
            x.height.equalTo(itemSize.height + 8)
        }
        sum_content_height += Int(itemSize.height) + 16
        currentAnchor = placeholder
        container.snp.makeConstraints { (x) in
            x.top.equalTo(placeholder.snp.top)
            x.left.equalTo(self.view.snp.left)
            x.right.equalTo(self.view.snp.right)
            x.height.equalTo(itemSize.height)
        }
        
        var screenshotAnchor = UIView()
        container.addSubview(screenshotAnchor)
        screenshotAnchor.snp.makeConstraints { (x) in
            x.width.equalTo(0)
            x.top.equalTo(container.snp.top)
            x.height.equalTo(itemSize.height)
            x.left.equalTo(container.snp.left)
        }
        
        for screenshotObject in screenshotsObjects {
            if screenshotObject["video"] as? Bool ?? false {
                let plh = UIView()
                plh.clipsToBounds = true
                plh.setRadiusINT(radius: radius)
                plh.backgroundColor = .gray
                container.addSubview(plh)
                plh.snp.makeConstraints { (x) in
                    x.left.equalTo(screenshotAnchor.snp.right).offset(18)
                    x.top.equalTo(screenshotAnchor.snp.top)
                    x.width.equalTo(itemSize.width)
                    x.height.equalTo(itemSize.height)
                }
                screenshotAnchor = plh
                let url = URL(string: screenshotObject["url"] as? String ?? "") ?? URL(string: "https://somethingwentwrong.com.for.sure")!
                let player = AVPlayer(url: url)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                DispatchQueue.main.async {
                    playerLayer.frame = plh.frame
                }
                playerLayer.frame = self.view.bounds
                plh.layer.addSublayer(playerLayer)
                player.volume = 0
                player.actionAtItemEnd = .none
                player.play()
                NotificationCenter.default.addObserver(self, selector: #selector(videoEndNotify(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            } else {
                let img = UIImageView()
                container.addSubview(img)
                img.contentMode = .scaleAspectFill
                img.clipsToBounds = true
                img.backgroundColor = .gray
                img.setRadiusINT(radius: radius)
                img.sd_setImage(with: URL(string: screenshotObject["url"] as? String ?? ""), completed: nil)
                img.isUserInteractionEnabled = false
                img.snp.makeConstraints { (x) in
                    x.left.equalTo(screenshotAnchor.snp.right).offset(18)
                    x.top.equalTo(screenshotAnchor.snp.top)
                    x.width.equalTo(itemSize.width)
                    x.height.equalTo(itemSize.height)
                }
                screenshotAnchor = img
            }
        }
        
    }
    
    func setup_TableTextView(object: [String : Any]) {
        guard let s1 = object["title"] as? String else {
            return
        }
        guard let s2 = object["text"] as? String else {
            return
        }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "oops??")
        cell.textLabel?.text = s1
        cell.detailTextLabel?.text = s2
        cell.textLabel?.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        cell.detailTextLabel?.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
        contentView.addSubview(cell)
        cell.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(3)
            x.right.equalTo(self.view.snp.right).offset(-3)
            x.top.equalTo(self.currentAnchor.snp.bottom)
            x.height.equalTo(44)
        }
        self.currentAnchor = cell
        sum_content_height += 44
    }
    
    func setup_TableButtonView(object: [String : Any]) {
        guard let title = object["title"] as? String else {
            return
        }
        guard let action = object["action"] as? String else {
            return
        }
        self.buttonActionStore.append(action)
        if let backupAction = object["backupAction"] as? String {
            self.buttonActionStore.append(backupAction)
        } else {
            self.buttonActionStore.append(action)
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "oooooops?")
        let button = UIButton()
        contentView.addSubview(cell)
        contentView.addSubview(button)
        cell.textLabel?.text = title
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.textLabel?.textColor = theme_color
        contentView.addSubview(cell)
        cell.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(3)
            x.right.equalTo(self.view.snp.right).offset(-3)
            x.top.equalTo(self.currentAnchor.snp.bottom)
            x.height.equalTo(44)
        }
        button.titleLabel?.textAlignment = .left
        button.snp.makeConstraints { (x) in
            x.edges.equalTo(cell.snp.edges)
        }
        button.tag = buttonActionStore.count - 1
        button.addTarget(self, action: #selector(button_call(sender:)), for: .touchUpInside)
        self.currentAnchor = cell
        self.contentView.bringSubviewToFront(button)
        sum_content_height += 44
    }
    
    @objc func button_call(sender: UIButton) {
        
        let tag = sender.tag
        if tag - 1 < 0 || tag >= buttonActionStore.count {
            return
        }
        if let url1 = URL(string: buttonActionStore[tag - 1]) {
            if UIApplication.shared.canOpenURL(url1) {
                UIApplication.shared.open(url1, options: [:], completionHandler: nil)
            } else {
                if let url2 = URL(string: buttonActionStore[tag]) {
                    UIApplication.shared.open(url2, options: [:], completionHandler: nil)
                }
            }
        }
        
    }
    
    func setup_ButtonView(object: [String : Any]) {
        
    }
    
    func setup_SeparatorView(object: [String : Any]) {
        using_bottom_margins(height: 8)
        let sep = UIView()
        sep.backgroundColor = .gray
        sep.alpha = 0.233
        contentView.addSubview(sep)
        sep.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(18)
            x.right.equalTo(self.view.snp.right).offset(-18)
            x.top.equalTo(self.currentAnchor.snp.bottom)
            x.height.equalTo(0.5)
        }
        sum_content_height += 1
        self.currentAnchor = sep
    }
    
    func setup_SpacerView(object: [String : Any]) {
        using_bottom_margins()
    }
    
    func setup_AdmobView(object: [String : Any]) {
        return
    }
    
    func setup_RatingView(object: [String : Any]) {
        
    }
    
    func setup_ReviewView(object: [String : Any]) {
        
    }
    
}

extension LKPackageDetail /* AVPlayer Section*/ {
    
    @objc func videoEndNotify(sender: Any) {
        if let noter = sender as? NSNotification {
            (noter.object as? AVPlayerItem)?.seek(to: .zero, completionHandler: nil)
        }
    }
    
}

extension LKPackageDetail: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = (navigationResponse.response as? HTTPURLResponse)?.url else {
            decisionHandler(.cancel)
            return
        }
        if url != loadUrl {
            loadUrl = url
            decisionHandler(.cancel)
            loadWebPage(url: url)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] (complete, _) in
            if complete != nil {
                self?.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, _) in
                    self?.contentView.contentSize.height = 233 + (height as? CGFloat ?? 0)
                    self?.webView.snp.remakeConstraints({ (x) in
                        x.top.equalTo(self!.currentAnchor.snp.bottom)
                        x.left.equalTo(self!.view.snp.left)
                        x.right.equalTo(self!.view.snp.right)
                        x.height.equalTo(height as? CGFloat ?? 0)
                    })
                    if LKRoot.settings?.use_dark_mode ?? false {
                        self?.webView.alpha = 1
                        self?.run_night_mode()
                    }
                })
            }
            
        })
    }
    
    func run_night_mode() {
        if LKRoot.settings?.use_dark_mode ?? false {
            let script = """
var darkModeCss = `
* {
background-color: #000000 !important;
color: #fff !important;
}
`
var documentHead = document.head || document.getElementsByTagName('head')[0];
var darkModeStyle = style = document.createElement('style');
documentHead.appendChild(style);
style.type = 'text/css';
if (style.styleSheet){
// This is required for IE8 and below.
style.styleSheet.cssText = css;
} else {
style.appendChild(document.createTextNode(darkModeCss));
}
""" // Dark mode magic script
            webView.evaluateJavaScript(script) { (result, _) in
                if let result = result {
                    print(result)
                }
            }
        }
    }
}
