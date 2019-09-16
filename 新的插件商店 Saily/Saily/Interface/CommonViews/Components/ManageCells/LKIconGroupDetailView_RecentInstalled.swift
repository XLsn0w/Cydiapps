//
//  LKIconGroupDetailView_RecentInstalled.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/16.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension manage_views {
    
    class LKIconGroupDetailView_RecentInstalled: UIView, UITableViewDataSource {
        
        var initd = false
        
        var is_collapsed = true
        let contentView = UIView()
        let table_view_container = UIView()
        
        var from_father_view: UIView?
        
        let expend_button = UIButton()
        let collapse_button = UIButton()
        let table_view = UITableView()
        let icon_stack = common_views.LKIconStack()
        
        var son_of_bith_vc = UIViewController()
        
        let limit = 5
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            table_view.register(cell_views.LKIconTVCell.self, forCellReuseIdentifier: "LKIconGroupDetailView_RecentInstalled_TVID")
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func apart_init(father: UIView?) {
            
            initd = true
            
            LKRoot.container_manage_cell_status["YA_IS_COLLAPSED"] = is_collapsed
            
            let RN_ANCHOR_O = 24
            let RN_ANCHOR_I = 16
            
            if father != nil {
                from_father_view = father!
            }
            
            re_sync()
            
            contentView.setRadiusINT(radius: LKRoot.settings?.card_radius)
            contentView.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
            contentView.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
            addSubview(contentView)
            contentView.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top).offset(RN_ANCHOR_O - 8)
                x.bottom.equalTo(self.snp.bottom).offset(-RN_ANCHOR_O + 8)
                x.left.equalTo(self.snp.left).offset(RN_ANCHOR_O)
                x.right.equalTo(self.snp.right).offset(-RN_ANCHOR_O)
            }
            
            // 标题
            let title_view = UILabel()
            title_view.text = "最近安装".localized()
            title_view.textColor = LKRoot.ins_color_manager.read_a_color("main_title_four")
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
            sub_title_view.text = "这里包含了您在系统中已经安装的软件包。".localized()
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

            icon_stack.images_address = ["NAMED:" + TWEAK_DEFAULT_IMG_NAME]
            icon_stack.apart_init()
            contentView.addSubview(icon_stack)
            icon_stack.snp.makeConstraints { (x) in
                x.right.equalTo(self.contentView.snp.right).offset(RN_ANCHOR_I)
                x.top.equalTo(self.contentView.snp.top).offset(12)
                x.width.equalTo(2)
                x.height.equalTo(33)
            }
            
            contentView.addSubview(table_view_container)
            table_view_container.clipsToBounds = true
            table_view_container.snp.makeConstraints { (x) in
                x.top.equalTo(sep.snp.bottom).offset(18)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                x.bottom.equalTo(contentView.snp.bottom).offset(-8)
            }
            
            // 展开按钮
            expend_button.setTitle("点击来展开一些最近的安装 ▼".localized(), for: .normal)
            expend_button.titleLabel?.font = .boldSystemFont(ofSize: 12)
            expend_button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_four"), for: .normal)
            expend_button.setTitleColor(.gray, for: .highlighted)
            contentView.addSubview(expend_button)
            expend_button.snp.remakeConstraints { (x) in
                //            x.bottom.equalTo(self.contentView.snp.bottom)
                x.height.equalTo(30)
                x.top.equalTo(sep.snp.bottom).offset(2)
                x.left.equalTo(self.contentView.snp.left)
                x.right.equalTo(self.contentView.snp.right)
            }
            
            // 关闭按钮
            collapse_button.setTitle("收起 ▲".localized(), for: .normal)
            collapse_button.titleLabel?.font = .boldSystemFont(ofSize: 12)
            collapse_button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_four"), for: .normal)
            collapse_button.setTitleColor(.gray, for: .highlighted)
            collapse_button.isHidden = true
            contentView.addSubview(collapse_button)
            collapse_button.snp.makeConstraints { (x) in
                x.centerY.equalTo(title_view.snp.centerY)
                x.right.equalTo(self.contentView.snp.right).offset(-RN_ANCHOR_I)
            }
            
            collapse_button.bringSubviewToFront(contentView)
            contentView.bringSubviewToFront(self)
            
            table_view.delegate = self
            table_view.dataSource = self
            table_view.isHidden = true
            table_view.isScrollEnabled = false
            table_view_container.addSubview(table_view)
            table_view.snp.remakeConstraints { (x) in
                x.top.equalTo(self.table_view_container.snp.top)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                x.height.equalTo(LKRoot.container_news_repo.count * 62)
            }
            table_view.separatorColor = .clear
            table_view.backgroundColor = .clear
            table_view.beginUpdates()
            table_view.reloadData()
            table_view.endUpdates()
            
            expend_button.addTarget(self, action: #selector(expend_self), for: .touchUpInside)
            collapse_button.addTarget(self, action: #selector(collapse_self), for: .touchUpInside)
            
        }
        
        func re_sync(lim: Int? = nil) {
            if LKRoot.isRootLess {
                return
            }
            guard let pack: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue,
                                                                           orderBy: [DBMPackage.Properties.latest_update_time.asOrder(by: .descending),
                                                                                     DBMPackage.Properties.one_of_the_package_name_lol.asOrder(by: .ascending),
                                                                                     DBMPackage.Properties.id.asOrder(by: .ascending)],
                                                                           limit: lim ?? self.limit) else {
                                                                            print("[E] 无法从 LKPackages 中获得数据，终止同步。")
                                                                            return
            }
            LKRoot.container_recent_installed = pack
        }
        
        func update_status() {
            LKRoot.container_manage_cell_status["YA_IS_COLLAPSED"] = is_collapsed
        }
        
        var 😂 = true
        @objc func expend_self() {
            
            re_sync()
            table_view.reloadData()
            table_view.snp.remakeConstraints { (x) in
                x.top.equalTo(self.table_view_container.snp.top)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                x.height.equalTo((LKRoot.container_recent_installed.count + 1) * 62 + 5 - 32)
            }

            if !is_collapsed {
                update_status()
                return
            }
            is_collapsed = false
            update_status()
            // 起始状态
            collapse_button.alpha = 0
            collapse_button.isHidden = false
            table_view.alpha = 0
            table_view.isHidden = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            if 😂 {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            } else {
                😂 = true
            }
            DispatchQueue.main.async {
                (self.from_father_view as? UITableView)?.beginUpdates()
                LKRoot.container_string_store["in_progress_UI_manage_update"] = "TRUE"
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                    (self.from_father_view as? UITableView)?.endUpdates()
                    self.expend_button.alpha = 0
                    self.collapse_button.alpha = 1
                    self.icon_stack.alpha = 0
                    self.table_view.alpha = 1
                }, completion: { (_) in
                    LKRoot.container_string_store["in_progress_UI_manage_update"] = "FALSE"
                    self.expend_button.isHidden = true
                    self.icon_stack.isHidden = true
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
        }
        
        @objc func collapse_self() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            if is_collapsed {
                update_status()
                return
            }
            is_collapsed = true
            update_status()
            // 起始状态
            expend_button.alpha = 0
            expend_button.isHidden = false
            icon_stack.alpha = 0
            icon_stack.isHidden = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            DispatchQueue.main.async {
                (self.from_father_view as? UITableView)?.beginUpdates()
                LKRoot.container_string_store["in_progress_UI_manage_update"] = "TRUE"
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                    (self.from_father_view as? UITableView)?.endUpdates()
                    self.collapse_button.alpha = 0
                    self.expend_button.alpha = 1
                    self.icon_stack.alpha = 1
                    self.table_view.alpha = 0
                }, completion: { (_) in
                    LKRoot.container_string_store["in_progress_UI_manage_update"] = "FALSE"
                    self.collapse_button.isHidden = true
                    self.table_view.isHidden = true
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
        }
    }
    
}

extension manage_views.LKIconGroupDetailView_RecentInstalled: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LKRoot.container_recent_installed.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= LKRoot.container_recent_installed.count {
            let ret = cell_views.LK2ButtonStackTVCell()
            ret.button1.setTitle("导出全部".localized(), for: .normal)
            ret.button2.setTitle("查看全部".localized(), for: .normal)
            ret.button1.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_four"), for: .normal)
            ret.button2.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_four"), for: .normal)
            ret.button1.addTarget(self, action: #selector(export_button_recall(sender:)), for: .touchUpInside)
            ret.button2.addTarget(self, action: #selector(see_all), for: .touchUpInside)
            ret.backgroundColor = .clear
            return ret
        }
        let ret = tableView.dequeueReusableCell(withIdentifier: "LKIconGroupDetailView_RecentInstalled_TVID", for: indexPath) as? cell_views.LKIconTVCell ?? cell_views.LKIconTVCell()
        let pack = LKRoot.container_recent_installed[indexPath.row]
        if LKRoot.isRootLess {
            ret.icon.image = UIImage(named: "xerusdesign")
            ret.title.text = pack.id
            ret.link.text = "ROOTLESS JB LOCALHOST"
        } else {
            cell_views.LKTVCellPutPackage(cell: ret, pack: pack)
        }
        ret.backgroundColor = .clear
        return ret
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= LKRoot.container_recent_installed.count {
            return 43
        }
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table_view.deselectRow(at: indexPath, animated: true)
        if indexPath.row < LKRoot.container_recent_installed.count {
            touched_cell(which: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < LKRoot.container_recent_installed.count {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let share = UITableViewRowAction(style: .normal, title: "分享".localized()) { _, index in
            LKRoot.container_recent_installed[index.row].id.pushClipBoard()
            presentStatusAlert(imgName: "Done",
                               title: "成功".localized(),
                               msg: "这个软件包的名字已经复制到剪贴板".localized())
        }
        share.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_title_four")
        
        let delete = UITableViewRowAction(style: .normal, title: "卸载".localized()) { _, index in
            let pack = LKRoot.container_recent_installed[index.row]
            let ret = LKDaemonUtils.ins_operation_delegate.add_uninstall(pack: pack)
            if ret.0 != .success {
                let msg = "该软件包可能被其他软件包所依赖".localized() + "\n" + (ret.1 ?? "")
                presentStatusAlert(imgName: "Warning", title: "未知错误".localized(), msg: msg)
            } else {
                presentStatusAlert(imgName: "Done", title: "成功".localized(), msg: "删除操作已经添加到队列".localized())
            }
        }
        delete.backgroundColor = .red
        return [share, delete]
    }
    
    func update_interface(isSentFromRootLess: Bool = false, _ CallB: @escaping () -> Void) {
        // 刷新成功了 先展开表格，再更新iconStack，最后reload自己
        if !isSentFromRootLess {
            re_sync()
        } else {
            try? LKRoot.root_db?.delete(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue)
        }
        table_view.reloadData()
        DispatchQueue.main.async {
            (self.from_father_view as? UITableView)?.beginUpdates()
            LKRoot.container_string_store["in_progress_UI_manage_update"] = "TRUE"
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                (self.from_father_view as? UITableView)?.endUpdates()
            }, completion: { (_) in
                LKRoot.container_string_store["in_progress_UI_manage_update"] = "FALSE"
                self.table_view.snp.remakeConstraints { (x) in
                    x.top.equalTo(self.table_view_container.snp.top)
                    x.left.equalTo(self.contentView.snp.left).offset(8)
                    x.right.equalTo(self.contentView.snp.right).offset(-8)
                    x.height.equalTo((LKRoot.container_recent_installed.count + 1) * 62 + 5 - 32)
                }
                self.icon_stack.apart_init()
                UIApplication.shared.endIgnoringInteractionEvents()
                IHProgressHUD.dismiss()
                CallB()
            })
        }
    }
    
    @objc func export_button_recall(sender: Any?) {
        var read = ""
        var rs = [String]()
        for item in LKRoot.container_packages_installed_DBSync {
            rs.append(item.key)
        }
        rs.sort()
        for item in rs {
            read.append("- " + item)
            var vn = LKRoot.container_packages[item]?.one_of_the_package_name_lol ?? "none"
            vn = "Visible name: " + vn
            var ver = LKRoot.container_packages_installed_DBSync[item]?.version.first?.value.first?.value["VERSION"] ?? "NaN"
            ver = "Version: " + ver
            read.append("\n")
            read.append(vn)
            read.append("\n")
            read.append(ver)
            read.append("\n")
            read.append("\n")
        }
        read.pushClipBoard()
        presentStatusAlert(imgName: "Done", title: "完成".localized(), msg: "你的全部软件包列表已复制到剪贴板。".localized())
    }
    
    func touched_cell(which: IndexPath) {
        var pack = LKRoot.container_recent_installed[which.row]
        if LKRoot.isRootLess {
            let alert = UIAlertController(title: "删除".localized(), message: "你确定要这么做吗".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认".localized(), style: .destructive, handler: { (_) in
                let operation = DMOperationInfo(pack: pack, operation: .required_remove)
                LKDaemonUtils.ins_operation_delegate.operation_queue.append(operation)
            }))
            alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: nil))
            alert.presentToCurrentViewController()
            return
        }
        if let packer = LKRoot.container_packages[pack.id] {
            pack = packer
        }
        presentPackage(pack: pack)
    }
    
    @objc func see_all() {
        // 准备发送新的 vc
        UIApplication.shared.beginIgnoringInteractionEvents()
        IHProgressHUD.show()
        let new = LKPackageListController()
        new.rtl_sentFromRecentInstalled = true
        LKRoot.queue_dispatch.async {
            guard let read: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue,
                                                                           orderBy: [DBMPackage.Properties.latest_update_time.asOrder(by: .descending),
                                                                                     DBMPackage.Properties.one_of_the_package_name_lol.asOrder(by: .ascending),
                                                                                     DBMPackage.Properties.id.asOrder(by: .ascending)]) else {
                                                                                        print("[E] 无法取得最近更新的列表，我们撤。")
                                                                                        return
            }
            var list = [DBMPackage]()
            for item in read {
                if let newer = LKRoot.container_packages[item.id] {
                    list.append(newer)
                } else {
                    list.append(item)
                }
            }
            new.items = list
            DispatchQueue.main.async {
                IHProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
                new.title = "已安装".localized()
                new.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "排序".localized(), style: .plain, target: self, action: #selector(self.sort_call))
                self.son_of_bith_vc = new
                (LKRoot.tabbar_view_controller as? UIEnteryS)?.nav2.pushViewController(new)
            }
        }
    }
    
    @objc func sort_call() {
        let alert = UIAlertController(title: "排序方法".localized(), message: "您希望以怎样的方法进行排序？".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "日期".localized(), style: .default, handler: { (_) in
            UIApplication.shared.beginIgnoringInteractionEvents()
            IHProgressHUD.show()
            LKRoot.queue_dispatch.async {
                guard let read: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue,
                                                                               orderBy: [DBMPackage.Properties.latest_update_time.asOrder(by: .descending),
                                                                                         DBMPackage.Properties.one_of_the_package_name_lol.asOrder(by: .ascending),
                                                                                         DBMPackage.Properties.id.asOrder(by: .ascending)]) else {
                                                                                            print("[E] 无法取得最近更新的列表，我们撤。")
                                                                                            return
                }
                var list = [DBMPackage]()
                for item in read {
                    if let newer = LKRoot.container_packages[item.id] {
                        list.append(newer)
                    } else {
                        list.append(item)
                    }
                }
                DispatchQueue.main.async {
                    IHProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let vc = (self.son_of_bith_vc as? LKPackageListController) {
                        vc.items = list
                        vc.table_view.reloadData()
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "名称".localized(), style: .default, handler: { (_) in
            UIApplication.shared.beginIgnoringInteractionEvents()
            IHProgressHUD.show()
            LKRoot.queue_dispatch.async {
                guard let read: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue,
                                                                               orderBy: [DBMPackage.Properties.one_of_the_package_name_lol.asOrder(by: .ascending),
                                                                                         DBMPackage.Properties.id.asOrder(by: .ascending)]) else {
                                                                                            print("[E] 无法取得最近更新的列表，我们撤。")
                                                                                            return
                }
                var list = [DBMPackage]()
                for item in read {
                    if let newer = LKRoot.container_packages[item.id] {
                        list.append(newer)
                    } else {
                        list.append(item)
                    }
                }
                DispatchQueue.main.async {
                    IHProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let vc = (self.son_of_bith_vc as? LKPackageListController) {
                        vc.items = list
                        vc.table_view.reloadData()
                    }
                }
            }
            
        }))
        readTopViewController()?.present(alert, animated: true, completion: {
            
        })
    }
}

