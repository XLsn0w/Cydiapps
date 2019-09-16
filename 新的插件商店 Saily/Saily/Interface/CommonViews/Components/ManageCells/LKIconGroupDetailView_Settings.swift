//
//  LKIconGroupDetailView_Settings.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/15.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension manage_views {
  
    class LKIconGroupDetailView_Settings: UIView, UITableViewDataSource {
        
        var initd = false
        
        let contentView = UIView()
        let table_view_container = UIView()
        
        let table_view = UITableView()
        let icon = UIImageView()
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func apart_init(father: UIView?) {
            
            initd = true
            
            let RN_ANCHOR_O = 0
            let RN_ANCHOR_I = 16
            
            contentView.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
            contentView.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
            addSubview(contentView)
            contentView.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top).offset(0)
                x.bottom.equalTo(self.snp.bottom).offset(-RN_ANCHOR_O + 8)
                x.left.equalTo(self.snp.left).offset(RN_ANCHOR_O)
                x.right.equalTo(self.snp.right).offset(-RN_ANCHOR_O)
            }
            
            // 标题
            let title_view = UILabel()
            title_view.text = "设置".localized()
            title_view.textColor = LKRoot.ins_color_manager.read_a_color("main_title_three")
            title_view.font = .boldSystemFont(ofSize: 28)
            contentView.addSubview(title_view)
            title_view.snp.makeConstraints { (x) in
                x.top.equalTo(self.contentView.snp.top).offset(6)
                x.left.equalTo(self.contentView.snp.left).offset(RN_ANCHOR_I)
                x.height.equalTo(46)
                x.width.equalTo(266)
            }
            
            // 描述
            let sub_title_view = UITextView()
            sub_title_view.text = "这个板块显示了最近更新的软件包。".localized()
            sub_title_view.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
            sub_title_view.font = .systemFont(ofSize: 10)
            sub_title_view.isUserInteractionEnabled = false
            sub_title_view.backgroundColor = .clear
            contentView.addSubview(sub_title_view)
            sub_title_view.snp.makeConstraints { (x) in
                x.top.equalTo(title_view.snp.bottom).offset(-4)
                x.left.equalTo(self.contentView.snp.left).offset(RN_ANCHOR_I - 4)
                x.right.equalTo(self.contentView.snp.right).offset(-RN_ANCHOR_I + 4)
                //                x.height.equalTo(sub_title_view.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 92, height: .infinity)))
                x.height.equalTo(33)
            }
            
            // 分割线
            let sep = UIView()
            sep.backgroundColor = LKRoot.ins_color_manager.read_a_color("tabbar_untint")
            sep.alpha = 0.3
            contentView.addSubview(sep)
            sep.snp.makeConstraints { (x) in
                x.top.equalTo(sub_title_view.snp.bottom).offset(6)
                x.left.equalTo(self.contentView.snp.left)
                x.right.equalTo(self.contentView.snp.right)
                x.height.equalTo(0.5)
            }
            
            // 图标组
            icon.image = UIImage(named: "Setting")
            icon.contentMode = .scaleAspectFit
            contentView.addSubview(icon)
            icon.snp.makeConstraints { (x) in
                x.right.equalTo(self.contentView.snp.right).offset(-28)
                x.top.equalTo(self.contentView.snp.top).offset(12)
                x.width.equalTo(50)
                x.height.equalTo(50)
            }

            contentView.addSubview(table_view_container)
            table_view_container.clipsToBounds = true
            table_view_container.snp.makeConstraints { (x) in
                x.top.equalTo(sep.snp.bottom).offset(8)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                x.bottom.equalTo(contentView.snp.bottom).offset(-8)
            }
            
            contentView.bringSubviewToFront(self)
            
            table_view.delegate = self
            table_view.dataSource = self
            table_view.allowsSelection = false
            table_view.isScrollEnabled = false
            table_view_container.addSubview(table_view)
            table_view.snp.makeConstraints { (x) in
                x.top.equalTo(self.table_view_container.snp.top)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                x.bottom.equalTo(contentView.snp.bottom).offset(-8)
            }
            table_view.separatorColor = .clear
            table_view.backgroundColor = .clear
            table_view.beginUpdates()
            table_view.reloadData()
            table_view.endUpdates()
            
            // Color Egg Don't Modify This
            let egg = UILabel(text: "你可真是个厉害的小可爱".localized())
            egg.font = .boldSystemFont(ofSize: 16)
            egg.textColor = LKRoot.ins_color_manager.read_a_color("main_operations_allow")
            egg.textAlignment = .center
            addSubview(egg)
            egg.snp.makeConstraints { (x) in
                x.bottom.equalTo(self.snp.bottom).offset(666)
                x.left.equalTo(self.snp.left)
                x.right.equalTo(self.snp.right)
                x.height.equalTo(23)
            }
            
        }
       
    }
    
}

extension manage_views.LKIconGroupDetailView_Settings: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret = UITableViewCell()
        let LR_OFFSET: CGFloat = 14
        let LRT_OFFSET: CGFloat = 0 // Left Right Title Offset 以免有强迫症和我取名过不去
        let touched_color = UIColor.lightGray
        ret.backgroundColor = .clear
        switch indexPath.row {
        case 0:
            let new = UILabel(text: "手动加载".localized())
            new.font = .boldSystemFont(ofSize: 22)
            new.textColor = LKRoot.ins_color_manager.read_a_color("main_title_three")
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left).offset(LR_OFFSET - LRT_OFFSET)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right).offset(-LR_OFFSET + LRT_OFFSET)
            }
            return ret
        case 1:
            let new = UIButton()
            new.setTitle("刷新 - 新闻源".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(refresh_np), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 2:
            let new = UIButton()
            new.setTitle("刷新 - 软件源 & 软件包".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(refresh_pack), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 3:
            let new = UIButton()
            new.setTitle("导入 - 新闻源".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(import_news_repo), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 4:
            let new = UIButton()
            new.setTitle("导入 - 软件源".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(import_package_repo), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 5:
            let new = UILabel(text: "交互界面".localized())
            new.font = .boldSystemFont(ofSize: 22)
            new.textColor = LKRoot.ins_color_manager.read_a_color("main_title_three")
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left).offset(LR_OFFSET - LRT_OFFSET)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right).offset(-LR_OFFSET + LRT_OFFSET)
            }
            return ret
        case 6:
            let new = UILabel(text: "外观 - 启用黑夜模式".localized())
            new.font = .systemFont(ofSize: 18)
            new.textColor = LKRoot.ins_color_manager.read_a_color("main_title_three")
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left).offset(LR_OFFSET)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right).offset(-60)
            }
            let switcher = UISwitch()
            switcher.tintColor = .white
            switcher.onTintColor = .black
            switcher.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
            switcher.setOn(LKRoot.settings?.use_dark_mode ?? false, animated: true)
            ret.contentView.addSubview(switcher)
            switcher.snp.makeConstraints { (x) in
                x.centerY.equalTo(new.snp.centerY).offset(-0.5)
                x.right.equalTo(ret.contentView.snp.right).offset(-LR_OFFSET)
            }
            switcher.addTarget(self, action: #selector(switch_dark_mode), for: .valueChanged)
            return ret
        case 7:
            let new = UIButton()
            new.setTitle("外观 - 全局卡片圆角".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(set_gobal_round_rate), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 8:
            let new = UILabel(text: "软件逻辑".localized())
            new.font = .boldSystemFont(ofSize: 22)
            new.textColor = LKRoot.ins_color_manager.read_a_color("main_title_three")
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left).offset(LR_OFFSET - LRT_OFFSET)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right).offset(-LR_OFFSET + LRT_OFFSET)
            }
            return ret
        case 9:
            let new = UIButton()
            new.setTitle("通用 - 全局下载超时".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(set_gobal_timeout), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 10:
            let new = UIButton()
            new.setTitle("通用 - 强制解锁 dpkg".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(force_unlock_dpkg), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 11:
            let new = UIButton()
            new.setTitle("通用 - 强制解锁网络".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(force_unlock_net), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 12:
            let new = UIButton()
            new.setTitle("通用 - 强制刷新桌面缓存".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(force_uicache), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
        case 13:
            let new = UILabel(text: "关于".localized())
            new.font = .boldSystemFont(ofSize: 22)
            new.textColor = LKRoot.ins_color_manager.read_a_color("main_title_three")
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left).offset(LR_OFFSET - LRT_OFFSET)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right).offset(-LR_OFFSET + LRT_OFFSET)
            }
            return ret
//        case 13:
//            let new = UIButton()
//            new.setTitle("查看 - 软件信息".localized(), for: .normal)
//            new.titleLabel?.font = .systemFont(ofSize: 18)
//            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
//            new.setTitleColor(touched_color, for: .highlighted)
//            new.addTarget(self, action: #selector(get_software_info), for: .touchUpInside)
//            new.contentHorizontalAlignment = .left
//            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
//            ret.contentView.addSubview(new)
//            new.snp.makeConstraints { (x) in
//                x.top.equalTo(ret.contentView.snp.top)
//                x.left.equalTo(ret.contentView.snp.left)
//                x.bottom.equalTo(ret.contentView.snp.bottom)
//                x.right.equalTo(ret.contentView.snp.right)
//            }
//            return ret
        case 14:
            let new = UIButton()
            new.setTitle("查看 - 软件帮助手册".localized(), for: .normal)
            new.titleLabel?.font = .systemFont(ofSize: 18)
            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
            new.setTitleColor(touched_color, for: .highlighted)
            new.addTarget(self, action: #selector(get_help), for: .touchUpInside)
            new.contentHorizontalAlignment = .left
            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right)
            }
            return ret
//        case 16:
//            let new = UIButton()
//            new.setTitle("分享 - 社交媒体".localized(), for: .normal)
//            new.titleLabel?.font = .systemFont(ofSize: 18)
//            new.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_three"), for: .normal)
//            new.setTitleColor(touched_color, for: .highlighted)
//            new.addTarget(self, action: #selector(get_software_info), for: .touchUpInside)
//            new.contentHorizontalAlignment = .left
//            new.contentEdgeInsets = UIEdgeInsets(top: 0, left: LR_OFFSET, bottom: 0, right: 0)
//            ret.contentView.addSubview(new)
//            new.snp.makeConstraints { (x) in
//                x.top.equalTo(ret.contentView.snp.top)
//                x.left.equalTo(ret.contentView.snp.left)
//                x.bottom.equalTo(ret.contentView.snp.bottom)
//                x.right.equalTo(ret.contentView.snp.right)
//            }
//            return ret
        case 15:
            let new = UILabel(text: "Copyright © 2019 Saily Team. All rights reserved.".localized())
            new.font = .boldSystemFont(ofSize: 8)
            new.textColor = .lightGray
            new.textAlignment = .center
            ret.contentView.addSubview(new)
            new.snp.makeConstraints { (x) in
                x.top.equalTo(ret.contentView.snp.top)
                x.left.equalTo(ret.contentView.snp.left).offset(LR_OFFSET - LRT_OFFSET)
                x.bottom.equalTo(ret.contentView.snp.bottom)
                x.right.equalTo(ret.contentView.snp.right).offset(-LR_OFFSET + LRT_OFFSET)
            }
            return ret
        default:
            return ret
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let title_size: CGFloat = 48
        let button_size: CGFloat = 30
        switch indexPath.row {
        case 0, 5, 8, 13:
            return title_size
        default:
            return button_size
        }
    }
    
    @objc func refresh_np() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        UIApplication.shared.beginIgnoringInteractionEvents()
        IHProgressHUD.show()
        LKRoot.queue_dispatch.async {
            LKRoot.ins_common_operator.NR_sync_and_download { (_) in
                LKRoot.manager_reg.nr.update_user_interface {
                    presentStatusAlert(imgName: "Done",
                                       title: "完成".localized(),
                                       msg: "已尝试刷新新闻源。".localized())
                }
            }
        }
    }
    
    @objc func refresh_pack() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        UIApplication.shared.beginIgnoringInteractionEvents()
        IHProgressHUD.show()
        LKRoot.queue_dispatch.async {
            LKRoot.ins_common_operator.PR_sync_and_download(sync_all: true) { (_) in
                LKRoot.manager_reg.pr.update_user_interface {
                    presentStatusAlert(imgName: "Done",
                                       title: "已尝试刷新软件源".localized(),
                                       msg: "软件包的更新将在后台进行。".localized())
                }
            }
        }
    }
    
    func exists_check_nr(_ w: String) -> Bool {
        LKRoot.manager_reg.nr.re_sync()
        for item in LKRoot.container_news_repo_DBSync where item.link == w {
            return false
        }
        return true
    }
    
    @objc func import_news_repo() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let read = String().readClipBoard().cleanRN()
        var read_out = [String]()
        var msg_str = "准备导入如下的新闻源\n".localized()
        for item in read.split(separator: "\n") where item.hasPrefix("http") && exists_check_nr(item.to_String()) {
            var read = item.to_String().drop_space()
            if !read.hasSuffix("/") {
                read += "/"
            }
            read_out.append(read)
            msg_str.append(read)
            msg_str.append("\n")
        }
        if read_out.count < 1 {
            presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "没有在剪贴板中找到有效的新闻源地址".localized())
            return
        }
        
        let alert = UIAlertController(title: "即将导入".localized(), message: msg_str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "执行".localized(), style: .destructive, handler: { (_) in
            IHProgressHUD.show()
            UIApplication.shared.beginIgnoringInteractionEvents()
            LKRoot.queue_dispatch.async {
                var index = 0
                for item in read_out {
                    let new = DBMNewsRepo()
                    new.link = item
                    new.sort_id = LKRoot.container_news_repo_DBSync.count + index
                    index += 1
                    try? LKRoot.root_db?.insertOrReplace(objects: new, intoTable: common_data_handler.table_name.LKNewsRepos.rawValue)
                }
                LKRoot.ins_common_operator.NR_sync_and_download { (_) in
                    DispatchQueue.main.async {
                        LKRoot.manager_reg.nr.update_user_interface {
                            presentStatusAlert(imgName: "Done", title: "导入成功".localized(), msg: "请考虑手动检查导入的完整性".localized())
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .default, handler: nil))
        alert.presentToCurrentViewController()
    }
    
    func exists_check_pr(_ w: String) -> Bool {
        LKRoot.manager_reg.pr.re_sync()
        for item in LKRoot.container_package_repo_DBSync where item.link == w {
            return false
        }
        return true
    }
    
    @objc func import_package_repo() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let alert: UIAlertController
        if LKRoot.is_iPad {
            alert = UIAlertController(title: "?", message: "请选择一个导入对象".localized(), preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "?", message: "请选择一个导入对象".localized(), preferredStyle: .actionSheet)
        }
        alert.addAction(UIAlertAction(title: "剪贴板".localized(), style: .default, handler: { (_) in
            self.importFromClipBoard()
        }))
        alert.addAction(UIAlertAction(title: "APT软件".localized(), style: .default, handler: { (_) in
            self.importFromAPT()
        }))
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: nil))
        presentViewController(some: alert)
    }
    
    func importFromAPT() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        IHProgressHUD.show()
        LKRoot.queue_dispatch.async {
            LKDaemonUtils.daemon_msg_pass(msg: "init:req:importAPT")
            var cnt = 0
            while !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/completedSourceImport") && cnt < 12 {
                sleep(1)
                cnt += 1
            }
            usleep(23333)
            DispatchQueue.main.async {
                if !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/completedSourceImport") {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    IHProgressHUD.dismiss()
                    presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "没有找到有效的软件源地址".localized())
                    return
                }
                try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/completedSourceImport")
                guard let items = try? FileManager.default.contentsOfDirectory(atPath: LKRoot.root_path! + "/daemon.call/import/") else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    IHProgressHUD.dismiss()
                    presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "没有找到有效的软件源地址".localized())
                    return
                    
                }
                var read = " "
                for name in items {
                    if let str = try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/import/" + name) {
                        read += str.cleanRN().drop_space().replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil) + " "
                    }
                }
                var result = [String]()
                for sep in read.split(separator: " ") {
                    if sep.hasPrefix("http") {
                        var add = sep.to_String().drop_space()
                        if !add.hasSuffix("/") {
                            add += "/"
                        }
                        if !result.contains(add) {
                            result.append(add)
                            print("[*] 准备导入软件源 " + add)
                        }
                    }
                }
                var index = 0
                for item in result {
                    let new = DBMPackageRepos()
                    new.link = item
                    new.sort_id = LKRoot.container_package_repo_DBSync.count + index
                    index += 1
                    try? LKRoot.root_db?.insertOrReplace(objects: new, intoTable: common_data_handler.table_name.LKPackageRepos.rawValue)
                }
                LKRoot.ins_common_operator.PR_sync_and_download(sync_all: true) { (_) in
                    DispatchQueue.main.async {
                        LKRoot.manager_reg.pr.update_user_interface {
                            presentStatusAlert(imgName: "Done", title: "导入成功".localized(), msg: "请考虑手动检查导入的完整性".localized())
                        }
                    }
                }
            }
        }
    }
    
    func importFromClipBoard() {
        let read = String().readClipBoard().cleanRN()
        var read_out = [String]()
        var msg_str = "准备导入如下的软件源\n".localized()
        for item in read.split(separator: "\n") where item.hasPrefix("http") && exists_check_pr(item.to_String()) {
            var read = item.to_String().drop_space()
            if !read.hasSuffix("/") {
                read += "/"
            }
            read_out.append(read)
            msg_str.append(read)
            msg_str.append("\n")
        }
        if read_out.count < 1 {
            presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "没有在剪贴板中找到有效的软件源地址".localized())
            return
        }
        
        let alert = UIAlertController(title: "即将导入".localized(), message: msg_str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "执行".localized(), style: .destructive, handler: { (_) in
            IHProgressHUD.show()
            UIApplication.shared.beginIgnoringInteractionEvents()
            LKRoot.queue_dispatch.async {
                var index = 0
                for item in read_out {
                    let new = DBMPackageRepos()
                    new.link = item
                    new.sort_id = LKRoot.container_package_repo_DBSync.count + index
                    index += 1
                    try? LKRoot.root_db?.insertOrReplace(objects: new, intoTable: common_data_handler.table_name.LKPackageRepos.rawValue)
                }
                LKRoot.ins_common_operator.PR_sync_and_download(sync_all: true) { (_) in
                    DispatchQueue.main.async {
                        LKRoot.manager_reg.pr.update_user_interface {
                            presentStatusAlert(imgName: "Done", title: "导入成功".localized(), msg: "请考虑手动检查导入的完整性".localized())
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .default, handler: nil))
        alert.presentToCurrentViewController()
    }
    
    @objc func switch_dark_mode(sender: UISwitch) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        LKRoot.settings?.use_dark_mode = sender.isOn
        let new = DBMSettings()
        new.use_dark_mode = sender.isOn
        try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKSettings.rawValue, on: [DBMSettings.Properties.use_dark_mode], with: new)
        let alert = UIAlertController(title: "成功".localized(), message: "你的操作已经保存，请考虑重新启动本软件来应用设置。".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重启".localized(), style: .destructive, handler: { (_) in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title: "稍后".localized(), style: .default, handler: nil))
        alert.presentToCurrentViewController()
    }
    
    @objc func set_gobal_round_rate() {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alert = UIAlertController(title: "全局圆角".localized(),
                                      message: "请在这里输入一个整数".localized(),
                                      preferredStyle: .alert)
        var inputTextField: UITextField?
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "8"
            inputTextField = textField
        })
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
            
        }))
        alert.addAction(UIAlertAction(title: "确认".localized(), style: .destructive, handler: { (_) in
            let read = inputTextField?.text ?? "8"
            if let int = Int(read) {
                if int > 20 || int < 0 {
                    presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "请输入一个小于 20 并大于 0 的值。".localized())
                } else {
                    let new = DBMSettings()
                    new.card_radius = int
                    try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKSettings.rawValue, on: [DBMSettings.Properties.card_radius], with: new)
                    let alert = UIAlertController(title: "成功".localized(), message: "你的操作已经保存，请考虑重新启动本软件来应用设置。".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "重启".localized(), style: .destructive, handler: { (_) in
                        exit(0)
                    }))
                    alert.addAction(UIAlertAction(title: "稍后".localized(), style: .default, handler: nil))
                    alert.presentToCurrentViewController()
                }
            } else {
                presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "请输入一个整数".localized())
            }
        }))
        alert.presentToCurrentViewController()
        
    }
    
    @objc func set_gobal_timeout() {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alert = UIAlertController(title: "网络超时".localized(),
                                      message: "请在这里输入一个整数".localized(),
                                      preferredStyle: .alert)
        var inputTextField: UITextField?
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "8"
            inputTextField = textField
        })
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
            
        }))
        alert.addAction(UIAlertAction(title: "确认".localized(), style: .destructive, handler: { (_) in
            let read = inputTextField?.text ?? "8"
            if let int = Int(read) {
                if int > 180 || int < 0 {
                    presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "请输入一个小于 20 并大于 0 的值。".localized())
                } else {
                    let new = DBMSettings()
                    new.network_timeout = int
                    try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKSettings.rawValue, on: [DBMSettings.Properties.network_timeout], with: new)
                    LKRoot.settings?.network_timeout = int
                    presentStatusAlert(imgName: "Done", title: "成功".localized(), msg: "你的操作已经保存。".localized())
                }
            } else {
                presentStatusAlert(imgName: "Warning", title: "失败".localized(), msg: "请输入一个整数".localized())
            }
        }))
        alert.presentToCurrentViewController()
    }
    
    @objc func force_unlock_dpkg() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let alert = UIAlertController(title: "⚠️".localized(),
                                      message: "这个操作将产生危险，你确定吗".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
        }))
        alert.addAction(UIAlertAction(title: "确认".localized(), style: .destructive, handler: { (_) in
            LKDaemonUtils.daemon_msg_pass(msg: "init:req:dpkg:forceUnlock")
            presentStatusAlert(imgName: "Done", title: "完成".localized(), msg: "已按照你的要求解锁dpkg".localized())
        }))
        alert.presentToCurrentViewController()
    }
    
    @objc func force_unlock_net() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let alert = UIAlertController(title: "⚠️".localized(),
                                      message: "这个操作将重启您的系统".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
        }))
        alert.addAction(UIAlertAction(title: "确认".localized(), style: .destructive, handler: { (_) in
            LKDaemonUtils.daemon_msg_pass(msg: "init:req:net:unlock")
            presentStatusAlert(imgName: "Done", title: "完成".localized(), msg: "".localized())
        }))
        alert.presentToCurrentViewController()
    }
    
    @objc func force_uicache() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let alert = UIAlertController(title: "⚠️".localized(),
                                      message: "这回花费一些时间".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }))
        alert.addAction(UIAlertAction(title: "确认".localized(), style: .destructive, handler: { (_) in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            UIApplication.shared.beginIgnoringInteractionEvents()
            IHProgressHUD.show()
            LKRoot.queue_dispatch.async {
                LKDaemonUtils.daemon_msg_pass(msg: "init:req:uicache")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                UIApplication.shared.endIgnoringInteractionEvents()
                IHProgressHUD.dismiss()
                presentStatusAlert(imgName: "Done", title: "完成".localized(), msg: "".localized())
            }
        }))
        alert.presentToCurrentViewController()
    }
    
//    @objc func get_software_info() {
//
//    }
    
    @objc func get_help() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let alert: UIAlertController
        if LKRoot.is_iPad {
            alert = UIAlertController(title: "⚠️".localized(),
                                          message: "你想如何获得帮助？".localized(),
                                          preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "⚠️".localized(),
                                      message: "你想如何获得帮助？".localized(),
                                      preferredStyle: .actionSheet)
        }
        alert.addAction(UIAlertAction(title: "Twitter".localized(), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string: "https://twitter.com/Lakr233")!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Discord".localized(), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string: "https://discord.gg/3nKjap8")!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "E-Mail".localized(), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string: "mailto:master@233owo.com")!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "GitHub".localized(), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string: "https://github.com/Co2333/Saily-Store/issues")!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
        }))
        alert.presentToCurrentViewController()
    }
    
    @objc func share() {
        
    }
}


