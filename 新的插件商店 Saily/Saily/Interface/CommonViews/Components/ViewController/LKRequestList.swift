//
//  LKRequestList.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/23.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class LKRequestList: UIViewController {
    
    let table_view = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        
        table_view.register(cell_views.LKOperationStatusTVCell.self, forCellReuseIdentifier: "LKRequestList_TVCellID")
        table_view.delegate = self
        table_view.dataSource = self
        table_view.separatorColor = .clear
        table_view.backgroundColor = .clear
        
        let title = UILabel(text: "操作队列".localized().uppercased())
        title.font = .boldSystemFont(ofSize: 20)
        title.textColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        title.textAlignment = .left
        view.addSubview(title)
        title.snp.makeConstraints { (x) in
            x.top.equalTo(self.view.snp.top)
            x.left.equalTo(self.view.snp.left).offset(18)
            x.right.equalTo(self.view.snp.right)
            x.height.equalTo(66)
        }

        // 不好看
//        let sep = UIView()
//        sep.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
//        view.addSubview(sep)
//        sep.snp.makeConstraints { (x) in
//            x.top.equalTo(title.snp.top)
//            x.left.equalTo(self.view.snp.left).offset(-12)
//            x.right.equalTo(self.view.snp.right).offset(12)
//            x.height.equalTo(4)
//        }
        
        let sep2 = UIView()
        sep2.alpha = 0.5
        sep2.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        view.addSubview(sep2)
        sep2.snp.makeConstraints { (x) in
            x.top.equalTo(title.snp.bottom)
            x.left.equalTo(self.view.snp.left).offset(-12)
            x.right.equalTo(self.view.snp.right).offset(12)
            x.height.equalTo(0.5)
        }
        
        view.addSubview(table_view)
        table_view.snp.makeConstraints { (x) in
            x.top.equalTo(sep2.snp.bottom)
            x.left.equalTo(self.view.snp.left)
            x.right.equalTo(self.view.snp.right)
            x.bottom.equalTo(self.view.snp.bottom)
        }
        
        let submitter = UIButton()
        submitter.setTitle("提交".localized(), for: .normal)
        submitter.setTitleColor(LKRoot.ins_color_manager.read_a_color("main_tint_color"), for: .normal)
        submitter.setTitleColor(.gray, for: .highlighted)
        submitter.titleLabel?.font = .boldSystemFont(ofSize: 16)
        submitter.addTarget(self, action: #selector(submit), for: .touchUpInside)
        view.addSubview(submitter)
        submitter.snp.makeConstraints { (x) in
            x.centerY.equalTo(title.snp.centerY)
            x.right.equalTo(self.view.snp.right).offset(-24)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.233) {
            self.table_view.reloadData()
        }
        
    }
    
    @objc func submit(sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if LKDaemonUtils.ins_operation_delegate.unsolved_condition.count > 0 {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "您有的提交列表有未解决的先决条件问题".localized())
            return
        }
        if LKDaemonUtils.ins_operation_delegate.operation_queue.count < 1 {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "您的操作队列没有请求".localized())
            return
        }
        
        let ret = LKDaemonUtils.submit()
        if ret.0 != .success {
            presentStatusAlert(imgName: "Warning", title: "未知错误".localized(), msg: "该错误与以下软件包有关：".localized() + ret.1)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension LKRequestList: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var num = LKDaemonUtils.ins_operation_delegate.unsolved_condition.count
            if num < 1 {
                num = 1
            }
            return num
        }
        var num = LKDaemonUtils.ins_operation_delegate.operation_queue.count
        if num < 1 {
            num = 1
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = LKRoot.ins_color_manager.read_a_color("main_text")
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        header?.backgroundView?.alpha = 0.233
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "先决条件".localized()
        }
        return "即将执行".localized()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret = tableView.dequeueReusableCell(withIdentifier: "LKRequestList_TVCellID") as? cell_views.LKOperationStatusTVCell ?? cell_views.LKOperationStatusTVCell()
        
        // 重置 cell
        ret.icon.image = UIImage()
        ret.title.text = ""
        ret.link.text = ""
        ret.prog.text = ""
        
        ret.backgroundColor = .clear
        
        if indexPath.section == 0 {
            if LKDaemonUtils.ins_operation_delegate.unsolved_condition.count < 1 {
                ret.icon.image = UIImage(named: "Clear")
                ret.title.text = "这个栏目没有内容".localized()
                ret.link.text = "暂时没有无法解决的先决条件".localized()
                ret.sep.alpha = 0
            } else {
                let item = LKDaemonUtils.ins_operation_delegate.unsolved_condition[indexPath.row]
                ret.icon.image = UIImage(named: "Error")
                ret.title.text = item.ID
                switch item.type {
                case .depends: ret.link.text = "无法找到这个依赖".localized()
                case .conflist: ret.link.text = "软件包与已安装或将安装的项目冲突".localized()
                }
            }
        } else {
            if LKDaemonUtils.ins_operation_delegate.operation_queue.count < 1 {
                ret.icon.image = UIImage(named: "Clear")
                ret.title.text = "这个栏目没有内容".localized()
                ret.link.text = "请考虑添加一些安装或卸载的软件包".localized()
                ret.sep.alpha = 0
            } else {
                let item = LKDaemonUtils.ins_operation_delegate.operation_queue[indexPath.row]
                let version = LKRoot.ins_common_operator.PAK_read_newest_version(pack: item.package.copy())
                let icon_link = LKRoot.ins_common_operator.PAK_read_icon_addr(version: version.1)
                ret.title.text = LKRoot.ins_common_operator.PAK_read_name(version: version.1)
                ret.sep.alpha = 0
                
                var isRemove = false
                switch item.operation_type {
                case .auto_install:
                    ret.link.text = "这个软件包被其他软件包要求安装".localized()
                    ret.downloadMonitor(dldinfo: item.dowload)
                case .required_install:
                    ret.link.text = "这个软件包被您要求安装".localized()
                    ret.downloadMonitor(dldinfo: item.dowload)
                case .required_reinstall:
                    ret.link.text = "这个软件包被您要求重新安装".localized()
                    ret.downloadMonitor(dldinfo: item.dowload)
                case .required_config:
                    ret.link.text = "这个软件包被要求重新配置".localized()
                case .required_remove:
                    ret.link.text = "这个软件包被您要求删除".localized()
                    isRemove = true
                case .required_modify_dcrp:
                    ret.link.text = "这个软件包在安装前被要求修改依赖".localized()
                case .DNG_auto_remove:
                    ret.link.text = "将为您执行软件包清理".localized()
                    ret.link.textColor = .red
                case .unknown: ret.link.text = "未知错误".localized()
                }
                
                if LKRoot.isRootLess && isRemove {
                    ret.icon.image = UIImage(named: "xerusdesign")
                    ret.title.text = item.package.id
                } else {
                    if icon_link.hasPrefix("http") {
                        ret.icon.sd_setImage(with: URL(string: icon_link), placeholderImage: UIImage(named: "Gary")) { (img, err, _, _) in
                            if err != nil || img == nil {
                                ret.icon.image = UIImage(named: "Error")
                            }
                        }
                    } else if icon_link.hasPrefix("NAMED:") {
                        let link = icon_link.dropFirst("NAMED:".count).to_String()
                        ret.icon.sd_setImage(with: URL(string: link), placeholderImage: UIImage(named: "Gary")) { (img, err, _, _) in
                            if err != nil || img == nil {
                                ret.icon.image = UIImage(named: "Error")
                            }
                        }
                    } else {
                        if let some = UIImage(contentsOfFile: icon_link) {
                            ret.icon.image = some
                        } else {
                            ret.icon.image = UIImage(named: TWEAK_DEFAULT_IMG_NAME)
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if LKDaemonUtils.ins_operation_delegate.unsolved_condition.count < 1 {
                return false
            } else {
                return false
            }
        } else {
            if LKDaemonUtils.ins_operation_delegate.operation_queue.count < 1 {
                return false
            } else {
                if LKDaemonUtils.ins_operation_delegate.operation_queue[indexPath.row].operation_type == .auto_install {
                    return false
                } else {
                    return true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if LKDaemonUtils.ins_operation_delegate.unsolved_condition.count < 1 {
                return
            } else {
                return
            }
        } else {
            if LKDaemonUtils.ins_operation_delegate.operation_queue.count < 1 {
                return
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                let pack = LKDaemonUtils.ins_operation_delegate.operation_queue[indexPath.row].package
                self.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        presentPackage(pack: pack)
                    })
                }
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
//        let share = UITableViewRowAction(style: .normal, title: "分享".localized()) { _, index in
//
//            presentStatusAlert(imgName: "Done", title: "成功".localized(), msg: (LKRoot.container_news_repo_DBSync[index.row].name) + " 的地址已经复制到剪贴板".localized())
//        }
//        share.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_title_two")
        
        let delete = UITableViewRowAction(style: .normal, title: "删除".localized()) { _, index in
            if indexPath.section == 0 {
                if LKDaemonUtils.ins_operation_delegate.unsolved_condition.count < 1 {
                    return
                } else {
                    return
                }
            } else {
                if LKDaemonUtils.ins_operation_delegate.operation_queue.count < 1 {
                    return
                } else {
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    IHProgressHUD.show()
                    LKRoot.queue_dispatch.async {
                        let pack = LKDaemonUtils.ins_operation_delegate.operation_queue[index.row]
                        LKDaemonUtils.ins_operation_delegate.cancel_add_install(packID: pack.package.id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.233) {
                            self.table_view.reloadData()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            IHProgressHUD.dismiss()
                        }
                    }
                    return
                }
            }
        }
        delete.backgroundColor = .red
        return [delete]
    }
    
}
