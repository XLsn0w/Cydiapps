//
//  LKIconGroupDetailView_RecentUpdate.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/15.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension manage_views {

    class LKIconGroupDetailView_RecentUpdate: UIView, UITableViewDataSource {

        var initd = false

        let contentView = UIView()
        let table_view_container = UIView()
        
        let all_button = UIButton()

        var from_father_view: UIView?

        let table_view = UITableView()
        var limit = 9

        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            table_view.register(cell_views.LKIconTVCell.self, forCellReuseIdentifier: "LKIconGroupDetailView_RecentUpdate_TVID")
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        func apart_init(father: UIView?) {

            initd = true

            let RN_ANCHOR_O = 0
            let RN_ANCHOR_I = 16

            if father != nil {
                from_father_view = father!
            }

            contentView.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
//            contentView.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
            addSubview(contentView)
            contentView.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top).offset(RN_ANCHOR_O - 8)
                x.bottom.equalTo(self.snp.bottom).offset(-RN_ANCHOR_O + 8)
                x.left.equalTo(self.snp.left).offset(RN_ANCHOR_O)
                x.right.equalTo(self.snp.right).offset(-RN_ANCHOR_O)
            }

            // 标题
            let title_view = UILabel()
            title_view.text = "最近更新".localized()
            title_view.textColor = LKRoot.ins_color_manager.read_a_color("main_title_one")
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
                x.top.equalTo(sub_title_view.snp.bottom).offset(2)
                x.left.equalTo(self.contentView.snp.left)
                x.right.equalTo(self.contentView.snp.right)
                x.height.equalTo(0.5)
            }

            contentView.addSubview(table_view_container)
            table_view_container.clipsToBounds = true
            table_view_container.snp.makeConstraints { (x) in
                x.top.equalTo(sep.snp.bottom).offset(4)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                x.bottom.equalTo(contentView.snp.bottom).offset(-8)
            }

            contentView.bringSubviewToFront(self)

            // 初始化数据
            re_sync()
            
            table_view.delegate = self
            table_view.dataSource = self
            table_view.isScrollEnabled = false
            table_view_container.addSubview(table_view)
            table_view.snp.makeConstraints { (x) in
                x.top.equalTo(self.table_view_container.snp.top)
                x.left.equalTo(contentView.snp.left).offset(8)
                x.right.equalTo(contentView.snp.right).offset(-8)
                var count = LKRoot.container_recent_update.count
                if count > limit {
                    count = limit
                }
                count += 1
                x.height.equalTo(count * 62)
            }
            table_view.separatorColor = .clear
            table_view.backgroundColor = .clear
            table_view.beginUpdates()
            table_view.reloadData()
            table_view.endUpdates()

        }

        func re_sync(lim: Int? = nil) {
            guard let pack: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKPackages.rawValue,
                                                                           orderBy: [DBMPackage.Properties.latest_update_time.asOrder(by: .descending),
                                                                                     DBMPackage.Properties.one_of_the_package_name_lol.asOrder(by: .ascending),
                                                                                     DBMPackage.Properties.id.asOrder(by: .ascending)],
                                                                           limit: lim ?? self.limit) else {
                                                                            print("[E] 无法从 LKPackages 中获得数据，终止同步。")
                                                                            return
            }
            LKRoot.container_recent_update = pack
        }
        
        func update_interface() {
            re_sync()
            DispatchQueue.main.async {
                (self.from_father_view as? UITableView)?.beginUpdates()
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                    (self.from_father_view as? UITableView)?.endUpdates()
                    if LKRoot.container_recent_update.count < 1 {
                        self.all_button.setTitle("最近没有软件包被更新".localized(), for: .normal)
                        self.all_button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_one"), for: .normal)
                    } else if LKRoot.container_recent_update.count < self.limit {
                        self.all_button.setTitle("- 无更多软件包 -".localized(), for: .normal)
                        self.all_button.setTitleColor(.lightGray, for: .normal)
                    } else {
                        self.all_button.setTitle("查看最近更新的全部软件包".localized(), for: .normal)
                        self.all_button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_one"), for: .normal)
                    }
                }, completion: { (_) in
                    self.table_view.reloadData()
                    self.table_view.snp.remakeConstraints { (x) in
                        x.top.equalTo(self.table_view_container.snp.top)
                        x.left.equalTo(self.contentView.snp.left).offset(8)
                        x.right.equalTo(self.contentView.snp.right).offset(-8)
                        var count = LKRoot.container_recent_update.count
                        if count > self.limit {
                            count = self.limit
                        }
                        count += 1
                        x.height.equalTo(count * 62)
                    }
                })
            }
        }

    }

}

extension manage_views.LKIconGroupDetailView_RecentUpdate: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var c = LKRoot.container_recent_update.count
        if c > limit {
            c = limit
        }
        return c + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= LKRoot.container_recent_update.count {
            let new = UITableViewCell()
            if LKRoot.container_recent_update.count < 1 {
                all_button.setTitle("最近没有软件包被更新".localized(), for: .normal)
                all_button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_one"), for: .normal)
            } else if LKRoot.container_recent_update.count < limit {
                all_button.setTitle("- 无更多软件包 -".localized(), for: .normal)
                all_button.setTitleColor(.lightGray, for: .normal)
            } else {
                all_button.setTitle("查看最近更新的全部软件包".localized(), for: .normal)
                all_button.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_title_one"), for: .normal)
            }
            new.backgroundColor = .clear
            all_button.setTitleColor(.darkGray, for: .highlighted)
            all_button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            all_button.addTarget(self, action: #selector(send_to_list), for: .touchUpInside)
            new.addSubview(all_button)
            all_button.snp.makeConstraints { (x) in
                x.edges.equalTo(new.snp.edges)
            }
            return new
        }
        let ret = tableView.dequeueReusableCell(withIdentifier: "LKIconGroupDetailView_RecentUpdate_TVID", for: indexPath) as? cell_views.LKIconTVCell ?? cell_views.LKIconTVCell()
        let pack = LKRoot.container_recent_update[indexPath.row]
        cell_views.LKTVCellPutPackage(cell: ret, pack: pack)
        ret.backgroundColor = .clear
        return ret
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= LKRoot.container_recent_update.count {
            return 40
        }
        return 62
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table_view.deselectRow(at: indexPath, animated: true)
        if indexPath.row < LKRoot.container_recent_update.count {
            touched_cell(which: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let share = UITableViewRowAction(style: .normal, title: "分享".localized()) { _, index in
            LKRoot.container_recent_update[index.row].id.pushClipBoard()
            presentStatusAlert(imgName: "Done",
                               title: "成功".localized(),
                               msg: "这个软件包的名字已经复制到剪贴板".localized())
        }
        share.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_title_one")

        return [share]
    }

    func touched_cell(which: IndexPath) {
        let pack = LKRoot.container_recent_update[which.row]
        presentPackage(pack: pack)
    }
    
    @objc func send_to_list(sender: Any?) {
        if (sender as? UIButton)?.title(for: .normal) == "查看最近更新的全部软件包".localized() {
            // 准备发送新的 vc
            UIApplication.shared.beginIgnoringInteractionEvents()
            IHProgressHUD.show()
            let new = LKPackageListController()
            LKRoot.queue_dispatch.async {
                guard let read: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKPackages.rawValue,
                                                                               orderBy: [DBMPackage.Properties.latest_update_time.asOrder(by: .descending),
                                                                                         DBMPackage.Properties.one_of_the_package_name_lol.asOrder(by: .ascending),
                                                                                         DBMPackage.Properties.id.asOrder(by: .ascending)]) else {
                                                                                            print("[E] 无法取得最近更新的列表，我们撤。")
                                                                                            return
                }
                new.items = read
                DispatchQueue.main.async {
                    IHProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    new.title = "最近更新".localized()
                    (LKRoot.tabbar_view_controller as? UIEnteryS)?.nav3.pushViewController(new)
                }
            }
        }
    }

}


