//
//  LKPackageDetail.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/17.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import WebKit
import AVFoundation
import SwiftyMarkdown
import AHDownloadButton

// swiftlint:disable:next type_body_length
class LKPackageDetail: UIViewController {
    
    var item: DBMPackage = DBMPackage()
    var item_status = current_info.unknown
    var item_dld: dld_info?
    
    var theme_color = UIColor()
    var theme_color_bak = UIColor()
    var tint_color_consit = false
    var contentView = UIScrollView()

    var sum_content_height = 0
    
    var webView: WKWebView = WKWebView()
    
    let status_bar_cover = UIView()
    let banner_image = UIImageView()
    let banner_section = common_views.LKIconBannerSection()
    var downloadButtonSignal = false
//    let section_headers = [common_views.LKSectionBeginHeader]()
    
    var buttonActionStore = [String]()
    
    var currentAnchor = UIView()
    
    var timer : Timer?
    
    var img_initd = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LKRoot.settings?.use_dark_mode ?? false {
            navigationController?.navigationBar.barStyle = .blackOpaque
        } else {
            navigationController?.navigationBar.barStyle = .default
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = theme_color
        updateColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationController?.navigationBar.tintColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: LKRoot.ins_color_manager.read_a_color("main_tint_color")]
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            let red = self.theme_color_bak.redRead()
            let green = self.theme_color_bak.greenRead()
            let blue = self.theme_color_bak.blueRead()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: red,
                                                                               green: green,
                                                                               blue: blue,
                                                                               alpha: 1)
        }, completion: nil)
        
        timer?.invalidate()
        timer = nil
        IHProgressHUD.dismiss()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
        
        if LKRoot.settings?.use_dark_mode ?? false {
            navigationController?.navigationBar.barStyle = .blackOpaque
        } else {
            navigationController?.navigationBar.barStyle = .default
        }
        
        view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        
        // 校验软件包数据合法性
        if item.version.count != 1 {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            title = "错误".localized()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }
        //              版本号        源地址
        if item.version.first!.value.count != 1 {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            title = "错误".localized()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        // 检查是否存在 Sileo 死了哦的皮孙 Depiction
        var dep: String?
        var dep_type = ""
        if item.version.first?.value.first?.value["SileoDepiction".uppercased()] != nil {
            dep = item.version.first?.value.first?.value["SileoDepiction".uppercased()]!
            dep_type = "Sileo"
        } else if item.version.first?.value.first?.value["Depiction".uppercased()] != nil {
            dep = item.version.first?.value.first?.value["Depiction".uppercased()]!
            dep_type = "Cydia"
        } else {
            dep = item.version.first?.value.first?.value["Description".uppercased()]
            dep_type = "none"
        }
        
        // --------------------- 开始处理你的脸！
        
        theme_color = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        theme_color_bak = LKRoot.ins_color_manager.read_a_color("main_background")
        
        edgesForExtendedLayout = .top
        extendedLayoutIncludesOpaqueBars = true
        
        view.addSubview(contentView)
        contentView.delegate = self
        contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.contentOffset = CGPoint(x: 0, y: 0)
        if #available(iOS 11.0, *) {
            contentView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        contentView.snp.makeConstraints { (x) in
            x.edges.equalTo(self.view.snp.edges)
        }
        contentView.contentSize = CGSize(width: 0, height: 1888)
        
        status_bar_cover.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        view.addSubview(status_bar_cover)
        status_bar_cover.snp.makeConstraints { (x) in
            x.top.equalTo(self.view.snp.top)
            if #available(iOS 11.0, *) {
                x.height.equalTo(UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
            } else {
                // Fallback on earlier versions
                x.height.equalTo(20)
            }
            x.left.equalTo(self.view.snp.left)
            x.right.equalTo(self.view.snp.right)
        }
        
        contentView.addSubview(banner_image)
        banner_image.contentMode = .scaleAspectFill
        banner_image.image = UIImage(color: UIColor(hexString: "#00A5F8", transparency: 0.5)!, size: CGSize(width: 1, height: 1))
        banner_image.snp.makeConstraints { (x) in
            x.top.lessThanOrEqualTo(self.contentView.snp.top)
            x.top.lessThanOrEqualTo(self.view.snp.top)
            x.left.equalTo(view.snp.left)
            x.right.equalTo(view.snp.right)
            x.height.lessThanOrEqualTo(233)
            x.height.equalTo(233)
            x.bottom.equalTo(self.contentView.snp.top).offset(233)
        }
        sum_content_height += 233
        
        banner_image.clipsToBounds = true
        // 获取图标
        let d1 = UIImageView()
        let icon_addr = item.version.first?.value.first?.value["ICON"] ?? ""
        d1.sd_setImage(with: URL(string: icon_addr)) { (_, _, _, _) in
        }
        
        contentView.addSubview(banner_section)
        banner_section.snp.makeConstraints { (x) in
            x.top.equalTo(contentView.snp.top).offset(233)
            x.left.equalTo(self.view.snp.left)
            x.right.equalTo(self.view.snp.right)
            x.height.equalTo(98)
        }
        sum_content_height += 98
        banner_section.icon.sd_setImage(with: URL(string: icon_addr), placeholderImage: UIImage(named: TWEAK_DEFAULT_IMG_NAME))
        banner_section.title.text = LKRoot.ins_common_operator.PAK_read_name(version: item.version.first?.value ?? LKRoot.ins_common_operator.PAK_return_error_vision())
        title = banner_section.title.text
        banner_section.sub_title.text = LKRoot.ins_common_operator.PAK_read_auth(version: item.version.first?.value ?? LKRoot.ins_common_operator.PAK_return_error_vision()).0
        banner_section.button.startDownloadButtonTitle = "获取".localized()
        let infoo = LKRoot.ins_common_operator.PAK_read_current_install_status(packID: item.id)
        item_status = infoo
        if infoo != .not_installed {
            banner_section.button.startDownloadButtonTitle = "更改".localized()
        }
        if let dldinfo = LKRoot.ins_common_operator.PAK_read_current_download_info(packID: item.id) {
            item_dld = dldinfo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.233) {
                // 请务必检查是否在队列
                for item in LKDaemonUtils.ins_operation_delegate.operation_queue where item.package.id == self.item.id {
                    if dldinfo.succeed == .download_finished {
                        self.banner_section.button.state = .downloaded
                    } else if dldinfo.succeed != .failed && !dldinfo.dlReq.isSuspended && !dldinfo.dlReq.isCancelled {
                        self.banner_section.button.state = .pending
                    } else {
                        // 下载失败咯
                    }
                    break
                }
            }
        }
        banner_section.button.downloadedButtonTitle = "等待执行".localized()
        banner_section.button.startDownloadButtonHighlightedBackgroundColor = .lightGray
        banner_section.button.startDownloadButtonTitleSidePadding = 12
        banner_section.button.delegate = self
        banner_section.button.transitionAnimationDuration = 0.5
        banner_section.button.downloadingButtonCircleLineWidth = 2
        banner_section.apart_init() // sizeThatFit 需要先放文字
        
        updateColor()
        
        // 防止抽风
        DispatchQueue.main.async {
            self.scrollViewDidScroll(self.contentView)
        }
        
        currentAnchor = banner_section
        
        switch dep_type {
        case "none":
            setup_none(dep: dep ?? "")
        case "Sileo":
            setup_Sileo(dep: dep ?? "")
        case "Cydia":
            setup_Cydia(dep: dep ?? "")
        default:
            fatalError("你这是啥子情况啊？")
        }
        
    }
    
    func setup_none(dep: String) {
        let text = UITextView()
        text.backgroundColor = .clear
        text.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        text.font = .boldSystemFont(ofSize: 16)
        text.text = dep
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        contentView.addSubview(text)
        text.snp.makeConstraints { (x) in
            x.top.equalTo(self.banner_section.snp.bottom).offset(38)
            x.left.equalTo(self.view.snp.left).offset(18)
            x.right.equalTo(self.view.snp.right).offset(-18)
            x.height.equalTo(666)
        }
        let text2 = UITextView()
        text2.backgroundColor = .clear
        text2.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        text2.font = .boldSystemFont(ofSize: 10)
        text2.isScrollEnabled = false
        text2.isUserInteractionEnabled = false
        var read = "因出现未知错误现提供软件包的原始信息：\n\n".localized()
        let depsss = item.version.first?.value.first?.value ?? ["未知错误".localized() : "无更多信息".localized()]
        for item in depsss.keys.sorted() where !item.contains("_internal") {
            read.append(item)
            read.append(": ")
            read.append("\n")
            read.append(depsss[item] ?? "")
            read.append("\n")
            read.append("\n")
        }
        text2.text = read
        contentView.addSubview(text2)
        text2.snp.makeConstraints { (x) in
            x.top.equalTo(text.snp.bottom).offset(38)
            x.left.equalTo(self.view.snp.left).offset(18)
            x.right.equalTo(self.view.snp.right).offset(-18)
            x.height.equalTo(666)
        }
        DispatchQueue.main.async {
            let height = text.sizeThatFits(CGSize(width: text.frame.width, height: .infinity)).height
            text.snp.remakeConstraints { (x) in
                x.top.equalTo(self.banner_section.snp.bottom).offset(38)
                x.left.equalTo(self.view.snp.left).offset(38)
                x.right.equalTo(self.view.snp.right).offset(-38)
                x.height.equalTo(height)
            }
            let height2 = text2.sizeThatFits(CGSize(width: text2.frame.width, height: .infinity)).height
            text2.snp.remakeConstraints { (x) in
                x.top.equalTo(text.snp.bottom).offset(38)
                x.left.equalTo(self.view.snp.left).offset(38)
                x.right.equalTo(self.view.snp.right).offset(-38)
                x.height.equalTo(height2)
            }
            self.contentView.contentSize.height = CGFloat(400) + height + height2
        }
    }
    
    var loadUrl = URL(string: "https://www.apple.com/")!
    func setup_Cydia(dep: String) {
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        // 获取数据
        if let url = URL(string: dep) {
            IHProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                IHProgressHUD.dismiss()
            }
            contentView.addSubview(webView)
            webView.snp.makeConstraints { (x) in
                x.top.equalTo(self.currentAnchor.snp.bottom)
                x.left.equalTo(self.view.snp.left)
                x.right.equalTo(self.view.snp.right)
                x.height.equalTo(666)
            }
            webView.navigationDelegate = self
            webView.scrollView.isScrollEnabled = false
            loadWebPage(url: url)
            webView.allowsBackForwardNavigationGestures = false
        } else {
            setup_none(dep: "发生了未知错误。".localized())
        }
    }
    
    func loadWebPage(url: URL)  {
        if LKRoot.settings?.use_dark_mode ?? false {
            webView.alpha = 0.233
        }
        webView.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        webView.load(LKRoot.ins_networking.read_request(url: url))
    }
    
    func setup_Sileo(dep: String) {
        // 获取数据
        if let url = URL(string: dep) {
            IHProgressHUD.show()
            AF.request(url, method: .get, headers: nil).response(queue: LKRoot.queue_dispatch) { [weak self] (responed) in
                var read = String(data: responed.data ?? Data(), encoding: .utf8) ?? ""
                if read == "" {
                    read = String(data: responed.data ?? Data(), encoding: .ascii) ?? ""
                }
                if read == "" {
                    DispatchQueue.main.async {
                        IHProgressHUD.dismiss()
                        self?.setup_none(dep: "获取描述数据失败，请检查网络连接。".localized())
                    }
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: read.data(using: .utf8)!, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            IHProgressHUD.dismiss()
                            self?.doJsonSetupLevelRoot(json: json)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        IHProgressHUD.dismiss()
                        self?.setup_none(dep: "获取描述数据失败，请检查网络连接。".localized())
                    }
                    return
                }
            }
        } else {
            setup_none(dep: "发生了未知错误。".localized())
        }
    }
    
}

extension LKPackageDetail: AHDownloadButtonDelegate {
    
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        switch state {
        case .startDownload:
            if item.version.first?.value.first?.value["TAG"]?.contains("cydia::commercial") ?? false {
                presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "暂不支持付费插件下载".localized())
            } else {
                downloadButtonSignal = true
                downloadButton.state = .pending
            }
        case .pending: break
        case .downloading:
            downloadButtonSignal = false
            banner_section.button.state = .startDownload
            LKRoot.queue_dispatch.async {
                LKDaemonUtils.ins_operation_delegate.cancel_add_install(packID: self.item.id)
            }
            timer?.invalidate()
            timer = nil
        case .downloaded:
            presentSwiftMessageController(some: LKRequestList())
        }
        
    }
    
    func downloadButton(_ downloadButton: AHDownloadButton, stateChanged state: AHDownloadButton.State) {
        switch state {
        case .startDownload:
            if downloadButtonSignal == true {
                downloadButton.state = .pending
            } else {
                downloadButtonSignal = true
            }
        case .pending:
            if downloadButtonSignal != true {
                return
            }
            LKRoot.queue_dispatch.async {
                if self.item_status == .not_installed {
                    let ret = LKDaemonUtils.ins_operation_delegate.add_install(pack: self.item)
                    if ret.0 != .success && ret.1 == nil {
                        DispatchQueue.main.async {
                            downloadButton.state = .startDownload
                        }
                        presentStatusAlert(imgName: "Warning", title: "未知错误".localized(), msg: "无法添加到下载队列，请尝试刷新软件包".localized())
                        return
                    }
                    self.item_dld = ret.1
                    self.timer = nil
                    self.timer = Timer(timeInterval: 0.233, target: self, selector: #selector(self.downloadTimerCall(sender:)), userInfo: nil, repeats: false)
                    self.timer?.fire()
                    // 既然返回了 dld info 那就说明下载存在 发送到下载 session
                    DispatchQueue.main.async {
                        downloadButton.state = .downloading
                    }
                } else {
                    // some alert
                    let alert = UIAlertController(title: "选择".localized(), message: "请选择一个操作".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "删除".localized(), style: .default, handler: { (_) in
                        self.downloadButtonSignal = false
                        let ret = LKDaemonUtils.ins_operation_delegate.add_uninstall(pack: self.item)
                        if ret.0 != .success {
                            let msg = "该软件包可能被其他软件包所依赖".localized() + "\n" + (ret.1 ?? "")
                            presentStatusAlert(imgName: "Warning", title: "未知错误".localized(), msg: msg)
                        } else {
                            presentStatusAlert(imgName: "Done", title: "成功".localized(), msg: "删除操作已经添加到队列".localized())
                            downloadButton.state = .downloaded
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "重新安装".localized(), style: .default, handler: { (_) in
                        self.downloadButtonSignal = false
                        let ret = LKDaemonUtils.ins_operation_delegate.add_reinstall(pack: self.item)
                        if ret.0 != .success && ret.1 == nil {
                            DispatchQueue.main.async {
                                downloadButton.state = .startDownload
                            }
                            presentStatusAlert(imgName: "Warning", title: "未知错误".localized(), msg: "无法添加到下载队列，请尝试刷新软件包".localized())
                            return
                        }
                        self.item_dld = ret.1
                        self.timer = nil
                        self.timer = Timer(timeInterval: 0.233, target: self, selector: #selector(self.downloadTimerCall(sender:)), userInfo: nil, repeats: false)
                        self.timer?.fire()
                        // 既然返回了 dld info 那就说明下载存在 发送到下载 session
                        DispatchQueue.main.async {
                            downloadButton.state = .downloading
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "取消".localized(), style: .default, handler: { (_) in
                        self.downloadButtonSignal = false
                        self.banner_section.button.state = .startDownload
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        case .downloading: break
        case .downloaded: break
        }
        
    }
    
    @objc func downloadTimerCall(sender: Any) {
        LKRoot.queue_dispatch.async { // Don't change this I fuck you
            DispatchQueue.main.async {
                self.banner_section.button.progress = CGFloat(self.item_dld?.progress ?? 0)
                // 请务必检查是否在队列内
                for item in LKDaemonUtils.ins_operation_delegate.operation_queue where item.package.id == self.item.id {
                    if self.item_dld?.succeed == operation_result.download_finished {
                        self.timer?.invalidate()
                        self.timer = nil
                        self.banner_section.button.state = .downloaded
                    } else {
                        self.timer = nil
                        self.timer = Timer(timeInterval: 0.233, target: self, selector: #selector(self.downloadTimerCall(sender:)), userInfo: nil, repeats: false)
                        self.timer?.fire()
                    }
                    break
                }
            }
        }
    }
    
    
}
