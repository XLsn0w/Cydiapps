//
//  UICardDetailView.swift
//  Saily
//
//  Created by Lakr Aream on 2019/6/3.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class UICardDetailView: UIView {
    
    var lenth: CGFloat = 28
    var last_view_for_auto_layout: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("???")
    }
    
}

extension common_views {
    
    func NRCD_create_card_detail(info: String) -> UICardDetailView {
        let ret = UICardDetailView()
        
        var last_view = UIView()
        ret.addSubview(last_view)
        last_view.snp.makeConstraints { (x) in
            x.top.equalTo(ret.snp.top).offset(-18)
            x.height.equalTo(0)
            x.left.equalTo(ret.snp.left)
            x.right.equalTo(ret.snp.right)
        }
        
        var content_head: card_detail_type = .LKPrivateAPI_RESVERED
        var content_body = String()
        var content_vfsl = [String]()
        
        run_content_invoker: for item in info.split(separator: "\n") {
            if item.to_String().drop_space() == "//BLANK-LINE//" {
                content_body += "\n"
                continue run_content_invoker
            }
            // 这里 不要删除空格 这是 被 需要 的 ！！！！！！
            let read = item.to_String().drop_comment()
            if read.drop_space().hasPrefix("--> Begin Section |") && read.drop_space().split(separator: "|").count >= 2 {
                // 头
                content_head = .LKPrivateAPI_RESVERED
                content_body = String()
                content_vfsl = [String]()
                
                switch read.drop_space().split(separator: "|")[1].to_String() {
                case "text": content_head = .text
                case "text_inherit_saying": content_head = .text_inherit_saying
                case "photo": content_head = .photo
                case "photo_with_description": content_head = .photo_with_description
                case "news_repo": content_head = .news_repo
                case "package_repo": content_head = .package_repo
                case "package": content_head = .package
                case "LKPrivateAPI_setting_page": content_head = .LKPrivateAPI_setting_page
                default:
                    print("[*] 这啥玩意啊？？？" + read)
                }
                if read.split(separator: "|").count > 2 {
                    for vfsl in read.split(separator: "|").dropFirst().dropFirst() {
                        content_vfsl.append(vfsl.to_String())
                    }
                }
                continue run_content_invoker
            }
            if read.drop_space().hasPrefix("---> End Section") {
                // 尾
                if content_body.hasSuffix("\n") {
                    content_body = content_body.dropLast().to_String()
                }
                let return_this_shit = NRCD_create_card_detail_build_single(type: content_head, body: content_body, vfsl: content_vfsl)
                ret.addSubview(return_this_shit.0)
                return_this_shit.0.snp.makeConstraints { (x) in
                    x.top.equalTo(last_view.snp.bottom).offset(8)
                    x.left.equalTo(ret.snp.left)
                    x.right.equalTo(ret.snp.right)
                    x.height.equalTo(return_this_shit.1)
                }
                last_view = return_this_shit.0
                ret.lenth += return_this_shit.1 + 8
                continue run_content_invoker
            }
            // 身子
            content_body += read + "\n"
        }
        
        // 底层分割
        let return_this_shit = NRCD_create_card_detail_build_single(type: .text, body: "\n\n\n", vfsl: [])
        ret.addSubview(return_this_shit.0)
        return_this_shit.0.snp.makeConstraints { (x) in
            x.top.equalTo(last_view.snp.bottom).offset(8)
            x.left.equalTo(ret.snp.left)
            x.right.equalTo(ret.snp.right)
            x.height.equalTo(return_this_shit.1)
        }
        last_view = return_this_shit.0
        ret.lenth += return_this_shit.1 - 108
        
        ret.last_view_for_auto_layout = last_view
        
        return ret
    }
    
    func NRCD_create_card_detail_build_single(type: card_detail_type, body: String, vfsl: [String]) -> (UIView, CGFloat) {
        let ret = UIView()
        var lenth = CGFloat(2)
        
        switch type {
        case .text:
            do {
                let text_view = UITextView()
                text_view.font = .systemFont(ofSize: 16)
                text_view.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
                text_view.text = body
                text_view.backgroundColor = .clear
                text_view.isUserInteractionEnabled = false
                ret.addSubview(text_view)
                
                text_view.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left)
                    x.right.equalTo(ret.snp.right)
                    x.top.equalTo(ret.snp.top)
                    if LKRoot.is_iPad {
                        x.height.equalTo(text_view.sizeThatFits(CGSize(width: 444, height: CGFloat.infinity)).height)
                    } else {
                        x.height.equalTo(text_view.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 56, height: CGFloat.infinity)).height)
                    }
                }
                if LKRoot.is_iPad {
                    lenth += text_view.sizeThatFits(CGSize(width: 444, height: CGFloat.infinity)).height
                } else {
                    lenth += text_view.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 56, height: CGFloat.infinity)).height
                }
            }
        case .text_inherit_saying:
            do {
                lenth = 28
                let left_label = UILabel()
                left_label.text = "“"
                left_label.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
                left_label.font = UIFont(name:"HiraMinProN-W6", size: 128)
                ret.addSubview(left_label)
                left_label.snp.makeConstraints { (x) in
                    x.top.equalTo(ret.snp.top).offset(-35)
                    x.left.equalTo(ret.snp.left).offset(-15)
                    x.width.equalTo(150)
                    x.height.equalTo(188)
                }
                let text = UITextView()
                text.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
                text.text = body
                text.backgroundColor = .clear
                text.isUserInteractionEnabled = false
                text.font = .boldSystemFont(ofSize: 20)
                ret.addSubview(text)
                text.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left).offset(55)
                    x.top.equalTo(ret.snp.top).offset(3)
                    x.right.equalTo(ret.snp.right).offset(0)
                    if LKRoot.is_iPad {
                        // 晚点再来处理
                        x.height.equalTo(text.sizeThatFits(CGSize(width: 444, height: CGFloat.infinity)).height)
                        lenth += text.sizeThatFits(CGSize(width: 444, height: CGFloat.infinity)).height
                    } else {
                        x.height.equalTo(text.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 56, height: CGFloat.infinity)).height) // 56 + 28
                        lenth += text.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 84, height: CGFloat.infinity)).height
                    }
                }
                let right_label = UILabel()
                right_label.text = "”"
                right_label.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
                right_label.font = UIFont(name:"HiraMinProN-W6", size: 54)
                ret.addSubview(right_label)
                right_label.snp.makeConstraints { (x) in
                    x.top.equalTo(text.snp.bottom).offset(-3)
                    x.right.equalTo(ret.snp.right).offset(12)
                    x.width.equalTo(55)
                    x.height.equalTo(55)
                }
                let des_str = UILabel()
                des_str.text = vfsl.first ?? ""
                des_str.font = .systemFont(ofSize: 16)
                des_str.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
                des_str.textAlignment = .right
                ret.addSubview(des_str)
                des_str.snp.makeConstraints { (x) in
                    x.top.equalTo(text.snp.bottom).offset(3)
                    x.right.equalTo(right_label.snp.left).offset(-4)
                    x.left.equalTo(ret.snp.left)
                    x.height.equalTo(18)
                }
            }
        case .photo:
            do {
                lenth = 166
                let image = UIImageView()
                ret.addSubview(image)
                image.sd_setImage(with: URL(string: vfsl.first ?? ""), placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
                image.contentMode = .scaleAspectFill
                image.clipsToBounds = true
                image.snp.makeConstraints { (x) in
                    x.top.equalTo(ret.snp.top)
                    x.left.equalTo(ret.snp.left).offset(8)
                    x.right.equalTo(ret.snp.right).offset(-8)
                    x.height.equalTo(166)
                }
            }
        case .photo_with_description:
            do {
                lenth = 200
                let image = UIImageView()
                ret.addSubview(image)
                image.sd_setImage(with: URL(string: vfsl.first ?? ""), placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
                image.contentMode = .scaleAspectFill
                image.clipsToBounds = true
                image.snp.makeConstraints { (x) in
                    x.top.equalTo(ret.snp.top)
                    x.left.equalTo(ret.snp.left).offset(8)
                    x.right.equalTo(ret.snp.right).offset(-8)
                    x.height.equalTo(166)
                }
                let des_str = UILabel()
                des_str.text = body
                des_str.font = .systemFont(ofSize: 12)
                des_str.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
                des_str.textAlignment = .center
                ret.addSubview(des_str)
                des_str.snp.makeConstraints { (x) in
                    x.top.equalTo(image.snp.bottom).offset(8)
                    x.left.equalTo(ret.snp.left).offset(8)
                    x.right.equalTo(ret.snp.right).offset(-8)
                    x.height.equalTo(34)
                }
            }
        case .package_repo:
            do {
                let cell = common_views.LKIconBannerSection()
                cell.apart_init()
                cell.title.text = body
                cell.sub_title.text = vfsl.first
                cell.icon.sd_setImage(with: URL(string: (vfsl.first ?? "") + "CydiaIcon.png"), completed: nil)
                DispatchQueue.main.async {
                    cell.button.removeFromSuperview()
                }
                let button = UIButton()
                button.setTitle("添加".localized(), for: .normal)
                button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_text"), for: .normal)
                button.setTitleColor(.gray, for: .highlighted)
                button.accessibilityHint = vfsl.first
                button.addTarget(self, action: #selector(NRCD_add_repo_section_handler(sender:)), for: .touchUpInside)
                ret.addSubview(cell)
                ret.addSubview(button)
                button.snp.makeConstraints { (x) in
                    x.centerY.equalTo(cell.icon.snp.centerY)
                    x.right.equalTo(ret.snp.right)
                }
                cell.clipsToBounds = true
                cell.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left).offset(-15)
                    x.right.equalTo(ret.snp.right).offset(-50)
                    x.top.equalTo(ret.snp.top)
                    x.height.equalTo(68)
                }
                lenth += 80
            }
        case .package:
            do {
                let cell = common_views.LKIconBannerSection()
                cell.apart_init()
                DispatchQueue.main.async {
                    cell.button.removeFromSuperview()
                }
                let button = UIButton()
                button.setTitle("查看".localized(), for: .normal)
                button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_text"), for: .normal)
                button.setTitleColor(.gray, for: .highlighted)
                button.accessibilityHint = vfsl.first
                button.addTarget(self, action: #selector(NRCD_add_package_section_handler(sender:)), for: .touchUpInside)
                
                ret.addSubview(cell)
                ret.addSubview(button)
                button.snp.makeConstraints { (x) in
                    x.centerY.equalTo(cell.icon.snp.centerY)
                    x.right.equalTo(ret.snp.right)
                }
                cell.clipsToBounds = true
                cell.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left).offset(-15)
                    x.right.equalTo(ret.snp.right).offset(-50)
                    x.top.equalTo(ret.snp.top)
                    x.height.equalTo(68)
                }
                lenth += 80
                
                if let vfslf = vfsl.first {
                    if let pack = LKRoot.container_packages[vfslf]?.copy() {
                        let version = LKRoot.ins_common_operator.PAK_read_newest_version(pack: pack).1
                        cell.title.text = LKRoot.ins_common_operator.PAK_read_name(version: version)
                        cell.sub_title.text = body
                        let icon_link = LKRoot.ins_common_operator.PAK_read_icon_addr(version: version)
                        if icon_link.hasPrefix("http") {
                            cell.icon.sd_setImage(with: URL(string: icon_link), placeholderImage: UIImage(named: "Gary")) { (img, err, _, _) in
                                if err != nil || img == nil {
                                    cell.icon.image = UIImage(named: "Error")
                                }
                            }
                        } else if icon_link.hasPrefix("NAMED:") {
                            let link = icon_link.dropFirst("NAMED:".count).to_String()
                            cell.icon.sd_setImage(with: URL(string: link), placeholderImage: UIImage(named: "Gary")) { (img, err, _, _) in
                                if err != nil || img == nil {
                                    cell.icon.image = UIImage(named: "Error")
                                }
                            }
                        } else {
                            if let some = UIImage(contentsOfFile: icon_link) {
                                cell.icon.image = some
                            } else {
                                cell.icon.image = UIImage(named: TWEAK_DEFAULT_IMG_NAME)
                            }
                        }
                        
                    } else {
                        cell.title.text = "未找到的软件包".localized()
                        cell.sub_title.text = vfslf
                        cell.icon.image = UIImage(named: "Error")
                        button.isEnabled = false
                    }
                } else {
                    cell.icon.image = UIImage(named: "Error")
                }
                
            }
        default:
            print("[*] 这啥玩意啊？？？")
        }
        
        return (ret, lenth)
    } // NRCD_create_card_detail_build_single
    
    @objc func NRCD_add_repo_section_handler(sender: UIButton) {
        if let url = URL(string: sender.accessibilityHint ?? "") {
            let read = url.absoluteString
            IHProgressHUD.show()
            UIApplication.shared.beginIgnoringInteractionEvents()
            LKRoot.queue_dispatch.async {
                let new = DBMPackageRepos()
                new.link = read
                new.sort_id = LKRoot.container_package_repo_DBSync.count
                try? LKRoot.root_db?.insertOrReplace(objects: new, intoTable: common_data_handler.table_name.LKPackageRepos.rawValue)
                LKRoot.ins_common_operator.PR_sync_and_download(sync_all: false) { (_) in
                    DispatchQueue.main.async {
                        IHProgressHUD.dismiss()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        if LKRoot.manager_reg.pr.initd {
                            LKRoot.manager_reg.pr.update_user_interface {
                                presentStatusAlert(imgName: "Done",
                                                   title: "已尝试刷新软件源".localized(),
                                                   msg: "软件包的更新将在后台进行。".localized())
                            } // update_user_interface
                        } else {
                            presentStatusAlert(imgName: "Done",
                                               title: "已尝试刷新软件源".localized(),
                                               msg: "软件包的更新将在后台进行。".localized())
                        } // initd
                    } // async
                } // PR_sync_and_download
            } // async
        } // if let url
    }
    
    @objc func NRCD_add_package_section_handler(sender: UIButton) {
        if let id = sender.accessibilityHint {
            if let pack = LKRoot.container_packages[id]?.copy() {
                if let vc = (LKRoot.tabbar_view_controller as? UIEnteryS) {
                    vc.home.close_button_handler(sender: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        presentPackage(pack: pack)
                    }
                } else {
                    //                (LKRoot.tabbar_view_controller as? UIEnteryL)?.home.close_button_handler(sender: nil)
                    LKRoot.breakPoint("as? UIEnteryL")
                }
            } else {
                presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "没有找到这个软件包".localized())
            }
        }
    }
    
}
