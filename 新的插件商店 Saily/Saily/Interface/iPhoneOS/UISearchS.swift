//
//  UISearchS.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/14.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class UISearchS: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var table_view: UITableView = UITableView()
    var header_view: UIView?
    var timer : Timer?
    
    var contentView = UIScrollView()
    
    // 控制 NAV
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        contentView.contentSize.height = sum_the_height() + 80
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
    
    func sum_the_height() -> CGFloat {
        var ret = CGFloat(0)
        for i in 0...5 {
            ret += do_the_height_math(indexPath: IndexPath(row: i, section: 0))
        }
        ret += 38
        return ret - 999
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
            let header = LKRoot.ins_view_manager.create_AS_home_header_view(title_str: "搜索中心".localized(),
                                                                            sub_str: "在这里，寻找可能".localized(),
                                                                            image_str: "NAMED:SearchIcon",
                                                                            sep_enabled: false)
            ret.contentView.addSubview(header)
            header.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges).inset(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
            }
            ret.backgroundColor = .clear
        case 1:
            let fake_search = common_views.LKNonWorkSearchBar()
            fake_search.apart_init(txt: "查找插件/文章".localized())
            let real_search = UIButton()
            ret.addSubview(fake_search)
            ret.addSubview(real_search)
            real_search.addTarget(self, action: #selector(real_search_call), for: .touchUpInside)
            fake_search.snp.makeConstraints { (x) in
                x.left.equalTo(ret.snp.left).offset(24)
                x.right.equalTo(ret.snp.right).offset(-24)
                x.top.equalTo(ret.snp.top) // .offset(2)
                x.bottom.equalTo(ret.snp.bottom) // .offset(-2)
            }
            real_search.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.snp.edges)
            }
            ret.backgroundColor = .clear
        case 2:
            let sep = UIView()
            sep.backgroundColor = LKRoot.ins_color_manager.read_a_color("tabbar_untint")
            sep.alpha = 0.3
            ret.addSubview(sep)
            sep.snp.makeConstraints { (x) in
                x.bottom.equalTo(ret.snp.bottom).offset(-2)
                x.height.equalTo(0.5)
                x.left.equalTo(ret.snp.left)
                x.right.equalTo(ret.snp.right)
            }
            ret.backgroundColor = .clear
        case 3:
            let package_repo_manager = LKRoot.manager_reg.rp
            package_repo_manager.apart_init(father: tableView)
            ret.contentView.addSubview(package_repo_manager)
            package_repo_manager.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        case 4:
            let sep = UIView()
            sep.backgroundColor = LKRoot.ins_color_manager.read_a_color("tabbar_untint")
            sep.alpha = 0.3
            ret.addSubview(sep)
            sep.snp.makeConstraints { (x) in
                x.centerY.equalTo(ret.snp.centerY)
                x.height.equalTo(0.5)
                x.left.equalTo(ret.snp.left)
                x.right.equalTo(ret.snp.right)
            }
            ret.backgroundColor = .clear
        case 5:
            let package_repo_manager = LKRoot.manager_reg.ru
            package_repo_manager.apart_init(father: tableView)
            ret.contentView.addSubview(package_repo_manager)
            package_repo_manager.snp.makeConstraints { (x) in
                x.edges.equalTo(ret.contentView.snp.edges)
            }
            ret.backgroundView?.backgroundColor = .clear
            ret.backgroundColor = .clear
        default:
            ret.backgroundColor = .clear
        }
        return ret
    }
    
    func do_the_height_math(indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 150
        case 1: return 35
        case 2: return 28
        case 3:
            if LKRoot.container_manage_cell_status["RP_IS_COLLAPSED"] ?? true {
                return 127
            } else {
                return 127 + CGFloat(LKRoot.container_packages_randomfun_DBSync.count) * 62
            }
        case 4: return 18
        case 5:
            var count = LKRoot.container_recent_update.count
            if count > LKRoot.manager_reg.ru.limit {
                count = LKRoot.manager_reg.ru.limit
            }
            count += 1
            return CGFloat(count) * 62 + 1024
        default: return 0
        }
    }
    
    @objc func real_search_call() {
        let new = LKPackageSearch()
        presentViewController(some: new)
    }
    
}
