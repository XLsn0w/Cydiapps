//
//  AppRootClass.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/28.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

let LKRoot = app_root_class()

class app_root_class {
    
    var firstOpen = false
    
    #if DEBUG
    let is_debug = true
    #else
    let is_debug = false
    #endif
    
    var ever_went_background = false
    var should_backup_when_exit = true
    
    var is_iPad = false
    // swiftlint:disable:next discouraged_direct_init
    let shared_device = UIDevice()
    
    var root_path: String?
    var root_db: Database?
    var root_db_update_required = false
    var rtlTrace_db: Database?
    var rtlTrace_db_update_required = false
    
    var isRootLess: Bool = false
    
    var settings: DBMSettings?
    var safe_area_needed: Bool = false
    var current_page = UIViewController()
    var manager_reg = manage_view_reg()
    
    let queue_operation                                  = OperationQueue()
    let queue_operation_single_thread                    = OperationQueue()
    let queue_dispatch                                   = DispatchQueue(label: "com.lakr233.common.queue", qos: .utility, attributes: .concurrent)
    let queue_alamofire                                  = DispatchQueue(label: "com.lakr233.alamofire.queue", qos: .utility, attributes: .concurrent)
    
    // 缓存view好像没啥用
//    var container_cache_uiview = [UIView]()                               // 视图缓存咯
    var container_string_store              = [String : String]()           // ???
    var container_news_repo                 = [DMNewsRepo]()                // 新闻源缓存
    var container_news_repo_DBSync          = [DMNewsRepo]()                // 包含未刷新的源
    var container_package_repo              = [DMPackageRepos]()            // 软件源缓存
    var container_package_repo_DBSync       = [DMPackageRepos]()            // 包含未刷新的源
    var container_package_repo_download     = [String : String]()           // 软件源缓存
    var container_packages                  = [String : DBMPackage]()       // 软件包缓存
    var container_packages_DBSync           = [String : DBMPackage]()       // 软件包缓存
    var container_recent_update             = [DBMPackage]()                // 最近更新缓存
    var container_manage_cell_status        = [String : Bool]()             // 管理页面是否展开
    var container_packages_installed_DBSync = [String : DBMPackage]()       // 已安装软件包
    var container_recent_installed          = [DBMPackage]()                // 最近安装缓存
    var container_packages_randomfun_DBSync = [DBMPackage]()                // 已安装软件包
    
    var container_installed_provides        = [String : String?]()          // 被提供的软件包 识别码 : 版本
    
    let ins_color_manager = color_sheet()                   // 颜色表 - 以后拿来写主题
    let ins_view_manager = common_views()                   // 视图扩展
    let ins_networking = networking()                       // 网络处理
    let ins_user_manager = app_user_class()                 // 用户管理
    let ins_common_operator = app_opeerator()               // 通用处理
    
    //  接口
    var tabbar_view_controller: UITabBarController?
    
    // 初始化 App
    func initializing() {
        
        // 初始化变量
        queue_operation_single_thread.maxConcurrentOperationCount = 1
        
        // 初始化文件路径
        root_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        root_path! += "/com.OuO.Saily"
        if !FileManager.default.fileExists(atPath: root_path!) {
            do {
                try FileManager.default.createDirectory(atPath: root_path!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Failed to create document dir.")
            }
        }
        
        if root_path!.contains("CoreSimulator") {
            print("[*] 从模拟器启动应用程序 - " + (root_path ?? "wtf?"))
        } else if root_path!.contains("/Containers/Data/Application") {
            print("[*] 从沙盒启动应用程序。")
        }
        
        print("[*] 获取到沙箱目录：\n")
        print(root_path!)
        print("[*] App定义了最低兼容的数据库版本为 - " + DATEBASE_MINCAP_VERSION.description)
        
        if FileManager.default.fileExists(atPath: root_path! + "/db_version_trace.txt") {
            if let read = try? String(contentsOfFile: root_path! + "/db_version_trace.txt") {
                // Any Check?
                print("[*] 数据库版本为 - " + read)
            } else {
                print("[?] String(contentsOfFile: db_version_trace.txt)")
            }
        } else {
            try? DATEBASE_MINCAP_VERSION.description.write(toFile: root_path! + "/db_version_trace.txt", atomically: true, encoding: .utf8)
        }
        
        try? FileManager.default.removeItem(atPath: root_path! + "/daemon.call")
//        try? FileManager.default.removeItem(atPath: root_path! + "/Lakr233.db-wal") 操这玩意害惨我了
        try? FileManager.default.createDirectory(atPath: root_path! + "/daemon.call", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: root_path! + "/daemon.call/debs", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: root_path! + "/daemon.call/download_cache", withIntermediateDirectories: true, attributes: nil)
        root_db = Database(withPath: root_path! + "/" + "Lakr233.db")
        rtlTrace_db = Database(withPath: LKRoot.root_path! + "/" + "rtlInstall.db")
        try? FileManager.default.removeItem(atPath: root_path! + "/caches")
        
        // 检查数据库数据完整性
        let read_try: [DBMSettings]? = try? root_db?.getObjects(fromTable: common_data_handler.table_name.LKSettings.rawValue)
        if read_try == nil || read_try?.count != 1 {
            bootstrap_this_app()
        } else {
            settings = read_try?.first!
        }
        
        // 复制完整的 dpkg 记录信息
        let installed_update_session = UUID().uuidString
        LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE_SESSION"] = installed_update_session
        ins_common_operator.YA_build_installed_list(session: installed_update_session) { (ret) in
            if ret == operation_result.failed.rawValue {
                print("[E] 无法从 dpkg 获取安装的数据。")
            }
        }

        // 黑暗模式初始化
        ins_color_manager.reFit()
        
        // 启动时同步一次数据
        let package_from_database: [DBMPackage]? = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKPackages.rawValue)
        for item in package_from_database ?? [] {
            container_packages[item.id] = item
        }
        
        // 嘿嘿嘿
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // rootless JB working on it!
        if FileManager.default.fileExists(atPath: "/.rootlessJB.env.signal") /* x86 simulator */ {
            isRootLess = true
            print("------> 启用rootless版本 <------")
        }

        // Obviously not work cause amfid will block us searching for files at /var
//        if let rootlessSigs = try? FileManager.default.contentsOfDirectory(atPath: "/var/containers/Bundle/") {
//            for item in rootlessSigs where item.lowercased().contains("rootless") {
//                isRootLess = true
//            }
//        }
        
        // 发送到下载处理引擎
        queue_dispatch.async {
            self.ins_common_operator.PR_sync_and_download(sync_all: true) { (_) in
            }
        }
    }
    
    func bootstrap_this_app() {
        firstOpen = true
        // 开始初始化数据库
        try? rtlTrace_db?.create(table: common_data_handler.table_name.LKRootLessInstalledTrace.rawValue, of: DMRTLInstallTrace.self)
        try? root_db?.create(table: common_data_handler.table_name.LKNewsRepos.rawValue, of: DBMNewsRepo.self)
        try? root_db?.create(table: common_data_handler.table_name.LKSettings.rawValue, of: DBMSettings.self)
        try? root_db?.create(table: common_data_handler.table_name.LKPackageRepos.rawValue, of: DBMPackageRepos.self)
        try? root_db?.create(table: common_data_handler.table_name.LKPackages.rawValue, of: DBMPackage.self)
        try? root_db?.create(table: common_data_handler.table_name.LKRecentInstalled.rawValue, of: DBMPackage.self)
        let new_setting = DBMSettings()
        new_setting.card_radius = 8
        // 伪造UDID
        let fake_udid = UUID().uuidString
        var fake_udid_out = ""
        for item in fake_udid where item != "-" {
            fake_udid_out += item.description
        }
        fake_udid_out += UUID().uuidString.dropLast(28)
        fake_udid_out = fake_udid_out.lowercased()
        new_setting.fake_UDID = fake_udid_out
        new_setting.network_timeout = 16
        settings = new_setting
        try? root_db?.insert(objects: [new_setting], intoTable: common_data_handler.table_name.LKSettings.rawValue)
        // 写入新闻源地址
        let default_news_repos_saily = DBMNewsRepo()
        default_news_repos_saily.sort_id = 0
        let default_news_repos_aream = DBMNewsRepo()
        default_news_repos_aream.sort_id = 1

        let pre = Locale.preferredLanguages[0]
        default_news_repos_saily.link = "https://lakrowo.gitee.io/Saily/".localized()
        default_news_repos_aream.link = "https://lakrowo.gitee.io/AreamN/".localized()
        
        try? root_db?.insert(objects: [default_news_repos_saily, default_news_repos_aream], intoTable: common_data_handler.table_name.LKNewsRepos.rawValue)
//        #if DEBUG                                                                                       // 压力测试源
//        let default_links =  [
//            "http://qaq.loc/repos/",
//            "https://apt.bingner.com/",
//            "http://build.frida.re/",
//            "https://repo.chariz.io/",
//            "https://sparkdev.me/",
//            "https://repo.nepeta.me/",
//            "https://cydia.akemi.ai/",
//            "http://apt.keevi.cc/",
//            "https://repo.chimera.sh/",
//            "https://apt.uozi.org/",
//            "https://apt.wxhbts.com/",
//            "https://apt.cydiakk.com/",
//            "http://apt.hackcn.net/",
//            "http://repounclutter.coolstar.org/",
//            "https://cydia.kiiimo.org/",
//            "https://apt.abcydia.com/",
//            "http://julioverne.github.io/",
//            "http://jakeashacks.ga/cydia/",
//            "http://www.alonemonkey.com/cydiarepo/",
//            "https://repo.dynastic.co/"
//        ]
//        #else
        var default_links = [
            "https://repo.packix.com/", // Moved my baby?
            "https://repo.nepeta.me/",
            "https://repo.dynastic.co/"
        ]
//        #endif
        
        
        if FileManager.default.fileExists(atPath: "/.installed_unc0ver") {
            default_links.insert("https://apt.bingner.com/", at: 0)
        } else {
            default_links.insert("https://repo.chimera.sh/", at: 0)
        }
        
        if pre.contains("zh") {
            default_links.insert("https://LakrOwO.gitee.io/repo/", at: 0)
        } else {
            default_links.insert("https://OuOp.github.io/", at: 0)
        }
        
        var insert = [DBMPackageRepos]()
        var index = 0
        for item in default_links {
            let obj = DBMPackageRepos()
            obj.link = item
            obj.sort_id = index
            index += 1
            insert.append(obj)
        }
        try? root_db?.insert(objects: insert, intoTable: common_data_handler.table_name.LKPackageRepos.rawValue)
    }
    
    func breakPoint(_ str: String? = nil) {
        if str != nil {
            print("[LLDB] - " + str!)
        }
        #if DEBUG
        if amIBeingDebugged() {
            raise(SIGINT)
        }
        #else
//        asm("svc 0")
        #endif
    }
    
    func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
}


