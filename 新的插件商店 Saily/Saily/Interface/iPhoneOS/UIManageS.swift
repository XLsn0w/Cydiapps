//
//  UIManageS.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import JJFloatingActionButton

// swiftlint:disable:next type_body_length
class UIManageS: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var table_view: UITableView = UITableView()
    var header_view: UIView?
    var timer : Timer?
    
    var contentView = UIScrollView()
    
    // 控制 NAV
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if LKRoot.container_string_store["REQ_REFRESH_UI_MANAGE"] == "FALSE" {
            LKRoot.container_string_store["REQ_REFRESH_UI_MANAGE"] = "FALSE"
            UIApplication.shared.beginIgnoringInteractionEvents()
            DispatchQueue.main.async {
                self.table_view.beginUpdates()
                UIView.animate(withDuration: 0.5, animations: {
                    self.table_view.endUpdates()
                }, completion: { (_) in
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 防止导航抽风
        let dummy = UIView()
        view.addSubview(dummy)
        dummy.snp.makeConstraints { (x) in
            x.edges.equalTo(self.view.snp.edges)
        }
        
        table_view.separatorColor = .clear
        table_view.clipsToBounds = false
        table_view.delegate = self
        table_view.dataSource = self
        table_view.allowsSelection = false
        table_view.backgroundView?.backgroundColor = .clear
        table_view.backgroundColor = .clear
        self.view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        contentView.contentSize.height = sum_the_height()
        contentView.contentSize.width = UIScreen.main.bounds.width
        table_view.isScrollEnabled = false
        table_view.bounces = false
        contentView.delegate = self
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.decelerationRate = .fast
        view.addSubview(contentView)
        contentView.addSubview(table_view)
        contentView.snp.makeConstraints { (x) in
            x.edges.equalTo(self.view.snp.edges)
        }
        
        table_view.snp.makeConstraints { (x) in
            x.edges.equalTo(self.contentView.snp.edges)
        }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timer_call), userInfo: nil, repeats: true)
        timer?.fire()
        DispatchQueue.main.async {
            self.timer_call()
        }
        
        let actionButton = JJFloatingActionButton()
        actionButton.addItem(title: "请求队列".localized(), image: UIImage(named: "List"), action: { (_) in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            presentSwiftMessageController(some: LKRequestList())
        })
        actionButton.setRadiusCGF(radius: 22.5)
        actionButton.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
        var bak_color = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        if LKRoot.settings?.use_dark_mode ?? false {
            bak_color = bak_color.darken(by: 0.5)
        }
        actionButton.backgroundColor = bak_color
        actionButton.buttonColor = bak_color
        view.addSubview(actionButton)
        view.bringSubviewToFront(actionButton)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            actionButton.imageView.snp.remakeConstraints({ (x) in
                x.edges.equalTo(actionButton.snp.edges).inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
            })
            actionButton.snp.remakeConstraints({ (x) in
                x.right.equalTo(self.view.snp.right).offset(-18)
                if #available(iOS 11.0, *) {
                    x.bottom.equalTo(self.view.snp.bottom).offset(0 - self.view.safeAreaInsets.bottom - 18)
                } else {
                    // Fallback on earlier versions
                    x.bottom.equalTo(self.view.snp.bottom).offset(-66)
                }
                x.height.equalTo(45)
                x.width.equalTo(45)
            })
            
        }
    }
    
    var last_size = CGFloat(0)
    @objc func timer_call() {
        if last_size != sum_the_height() {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.contentView.contentSize.height = self.sum_the_height()
                self.table_view.snp.remakeConstraints({ (x) in
                    x.edges.equalTo(self.contentView)
                    x.width.equalTo(UIScreen.main.bounds.width)
                    x.height.equalTo(self.sum_the_height())
                })
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return do_the_height_math(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return do_the_height_math(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table_view.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret = UITableViewCell()
        switch indexPath.row {
        case 0:        // 处理一下头条
            let header = LKRoot.ins_view_manager.create_AS_home_header_view(title_str: "管理中心".localized(),
                                                                            sub_str: "在这里，你和你的全部".localized(),
                                                                            image_str: "NAMED:AccountHeadIconPlaceHolder")
            ret.contentView.addSubview(header)
            header.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges).inset(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        case 1:
            let header = manage_views.LKActiveShineCell()
            header.apart_init(father: table_view)
            ret.contentView.addSubview(header)
            header.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        case 2:
            ret.backgroundColor = .clear
        case 3:
            let news_repo_manager = LKRoot.manager_reg.nr
            news_repo_manager.apart_init(father: tableView)
            ret.contentView.addSubview(news_repo_manager)
            news_repo_manager.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        case 4:
            let package_repo_manager = LKRoot.manager_reg.pr
            package_repo_manager.apart_init(father: tableView)
            ret.contentView.addSubview(package_repo_manager)
            package_repo_manager.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        case 5:
            let recent_installed = LKRoot.manager_reg.ya
            recent_installed.apart_init(father: tableView)
            ret.contentView.addSubview(recent_installed)
            recent_installed.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        case 6:
            let plh = UIView()
            ret.contentView.addSubview(plh)
            plh.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
            plh.setRadiusINT(radius: 19)
            plh.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
            let button = UIButton()
            ret.contentView.addSubview(button)
            button.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            plh.snp.makeConstraints { (x) in
                x.center.equalTo(ret.contentView.snp.center)
                x.width.equalTo(38)
                x.height.equalTo(38)
            }
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.image = UIImage(named: "Settings")
            plh.addSubview(image)
            image.snp.makeConstraints { (x) in
                x.edges.equalTo(button.snp.edges).inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            }
            let realButton = UIButton()
            ret.contentView.addSubview(realButton)
            realButton.snp.makeConstraints { (x) in
                x.edges.equalTo(plh.snp.edges)
            }
            realButton.addTarget(self, action: #selector(sendSettingController(sender:)), for: .touchUpInside)
            ret.contentView.layoutAll()
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        default:
            ret.backgroundColor = .clear
        }
        return ret
    }
    
    @objc func sendSettingController(sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let setting = LKSettingsController()
        presentViewController(some: setting)
    }
    
    func sum_the_height() -> CGFloat {
        var ret = CGFloat(0)
        for i in 0...6 {
            ret += do_the_height_math(indexPath: IndexPath(row: i, section: 0))
        }
//        if LKRoot.safe_area_needed {
            ret += 38
//        }
        return ret
    }
    
    func do_the_height_math(indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 150
        case 1:
            return 16
//            if (LKRoot.container_string_store["STR_SIG_PROGRESS"] ?? "SIGCLEAR") == "SIGCLEAR" {
//                return 0
//            } else {
//                return 22
//            }
        case 2:
            return 0
        case 3:
            if LKRoot.container_manage_cell_status["NP_IS_COLLAPSED"] ?? true {
                return 164
            } else {
                return 164 + CGFloat(LKRoot.container_news_repo_DBSync.count + 1) * 62 - 32
            }
        case 4:
            if LKRoot.container_manage_cell_status["PR_IS_COLLAPSED"] ?? true {
                return 171
            } else {
                return 171 + CGFloat(LKRoot.container_package_repo_DBSync.count + 1) * 62 - 32
            }
        case 5:
            if LKRoot.container_manage_cell_status["YA_IS_COLLAPSED"] ?? true {
                return 157
            } else {
                return 157 + CGFloat(LKRoot.container_recent_installed.count + 1) * 62 - 32
            }
        case 6:
            return 68
        default: return 180
        }
    }
    
}
