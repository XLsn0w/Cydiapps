//
//  OperatorPackageRepo.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/11.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension app_opeerator {
    
    // 下载release -> 下载软件包 -> 更新软件包到内存 -> 写入硬盘
    
    func PR_print_ram_status() {
        var download_count = 0
        for item in LKRoot.container_package_repo_download where item.value != "" {
            download_count += 1
            print("[i] 软件源 " + item.key + " 已经下载完成")
        }
        print("[i] 内存中共有 " + LKRoot.container_package_repo.count.description + " 个软件源 已经下载了 " + download_count.description + "/" + LKRoot.container_package_repo.count.description)
    }
    
    func PR_sync_and_download(sync_all: Bool, _ CallB: @escaping (Int) -> Void) {

        if test_network() == operation_result.failed.rawValue {
            print("[E] 拒绝刷新软件源 - 网络不存在")
            LKRoot.container_string_store["STR_SIG_PROGRESS"] = ""
            CallB(operation_result.failed.rawValue)
            return
        }
        
        LKRoot.container_string_store["REFRESH_IN_POGRESS_PR"] = "TRUE"
        LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_PR"] = ""
        
        var repos: [DBMPackageRepos]
        guard let repo: [DBMPackageRepos] = try? LKRoot.root_db?.getObjects(on: [DBMPackageRepos.Properties.link,
                                                                                 DBMPackageRepos.Properties.icon,
                                                                                 DBMPackageRepos.Properties.name,
                                                                                 DBMPackageRepos.Properties.sort_id],
                                                                            fromTable: common_data_handler.table_name.LKPackageRepos.rawValue,
                                                                            orderBy: [DBMPackageRepos.Properties.sort_id.asOrder(by: .ascending)]) else {
                                                                                print("[E] 无法从 LKPackageRepos 中获得数据，终止同步。")
                                                                                LKRoot.container_string_store["REFRESH_IN_POGRESS_PR"] = "FALSE"
                                                                                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_PR"] = ""
                                                                                CallB(operation_result.failed.rawValue)
                                                                                return
        } // guard let
        
        if sync_all {
            repos = repo
            LKRoot.container_package_repo.removeAll()
        } else {
            repos = [DBMPackageRepos]()
            var exists_repos = [DMPackageRepos]()
            // 移除不存在了的源
            for item in LKRoot.container_package_repo {
                var exists = false
                exists_check: for exs in repo where exs.link == item.link {
                    exists = true
                    break exists_check
                }
                if exists {
                   exists_repos.append(item)
                }
            }
            LKRoot.container_package_repo = exists_repos
            // 添加将要刷新的源
            for item in repo {
                var exists = false
                exists_check: for exs in LKRoot.container_package_repo where exs.link == (item.link ?? UUID().uuidString) {
                    exists = true
                    break exists_check
                }
                if !exists {
                    repos.append(item)
                }
            }
        }
        
        inner_01: for item in repos where item.link != nil && item.link != "" {
            // 下载内容
            let release_url = (item.link ?? "") + "Release"
            guard let url = URL(string: release_url) else {
                print("[Resumable - fatalError] 无法内容创建下载链接:" + (item.link ?? ""))
                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_PR"]?.append(item.link!)
                continue inner_01
            }
            var read_release = ""
            let sem = DispatchSemaphore(value: 0)
            var finished = false
            print("[*] 准备从 " + url.absoluteString + " 请求数据。")
            AF.request(url, method: .get, headers: LKRoot.ins_networking.read_header()).response(queue: LKRoot.queue_dispatch) { (data) in
                if finished {
                    return
                }
                finished = true
                let str_data = data.data ?? Data()
                var str: String?
                str = String(data: str_data, encoding: .utf8)
                if str == nil {
                    str = String(data: str_data, encoding: .ascii)
                    if str == nil {                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_PR"]?.append(item.link!)
                        str = """
                        Label: 未知错误
                        Description: 获取软件源元数据错误
                        """.localized()
                    }
                }
                read_release = str ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if LKRoot.manager_reg.pr.initd {
                        LKRoot.manager_reg.pr.update_user_interface {
                        }
                    }
                }
                sem.signal()
            }
            LKRoot.queue_dispatch.async {
                sleep(UInt32(LKRoot.settings?.network_timeout ?? 6))
                if !finished {
                    LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_PR"]?.append(item.link!)
                    read_release = """
                    Label: 未知错误
                    Description: 获取软件源元数据错误
                    """.localized()
                    finished = true
                    sem.signal()
                }
            }
            sem.wait()
            if read_release == "" {
                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_PR"]?.append(item.link!)
                continue inner_01
            }
            read_release = read_release.cleanRN()
            // 发送给wrapper
            let out = PR_release_wrapper(str: read_release)
            let new = DMPackageRepos()
            new.link = item.link ?? ""
//            new.icon = (item.link ?? "") + "CydiaIcon@3x.png"
            new.icon = (item.link ?? "") + "CydiaIcon.png"
            new.item = out
            new.name = out["ORIGIN"] ?? "未知错误".localized()
            new.desstr = out["DESCRIPTION"] ?? ""
            LKRoot.container_package_repo.append(new)
            let db = new.to_data_base()
            try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKPackageRepos.rawValue,
                                        on: [DBMPackageRepos.Properties.icon,
                                             DBMPackageRepos.Properties.name],
                                        with: db,
                                        where: DBMPackageRepos.Properties.link == item.link!)
        }
        LKRoot.container_string_store["REFRESH_IN_POGRESS_PR"] = "FALSE"
        let session = UUID().uuidString
        LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_SYNC"] = session
        CallB(operation_result.success.rawValue)
        LKRoot.queue_dispatch.asyncAfter(deadline: .now() + 1) {
            // 重新刷新以免失败的软件源继续参与刷新
            if let repo: [DBMPackageRepos] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKPackageRepos.rawValue,
                                                                             orderBy: [DBMPackageRepos.Properties.sort_id.asOrder(by: .ascending)]) {
                var new = [DMPackageRepos]()
                for item in LKRoot.container_package_repo where self.PR_should_add_this_repo(repo: item, root_db: repo) {
                    new.append(item)
                }
                LKRoot.container_package_repo = new
            }
            self.PR_download_all_package(session_id: session, sync_all: sync_all) { (_) in
                
            }
        }
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if LKRoot.manager_reg.pr.initd {
                LKRoot.manager_reg.pr.update_user_interface {
                }
            }
        }
        
    } // PR_sync_and_download
    
    func PR_release_wrapper(str: String) -> [String : String] {
        var ret = [String : String]()
        for item in str.split(separator: "\n") {
            if item.uppercased().hasPrefix("Origin:".uppercased()) {
                ret["ORIGIN"] = item.dropFirst("Origin:".count).to_String().drop_space()
            } else if item.uppercased().hasPrefix("Description:".uppercased()) {
                ret["DESCRIPTION"] = item.dropFirst("Description:".count).to_String().drop_space()
            }
        }
        return ret
    } // PR_release_wrapper
    
    // 在 call 之前要先更换 session 然后手动解锁 LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] = "NO"
    func PR_download_all_package(session_id: String, sync_all: Bool, _ CallB: @escaping (Int) -> Void) {
        if LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] == "YES" || session_id != LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_SYNC"] {
            CallB(operation_result.thread_locked.rawValue)
            return
        }
        
        var do_download = [DMPackageRepos]()
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = "正在下载软件包，这可能需要一些时间。".localized()
        
        if sync_all {
            LKRoot.container_package_repo_download.removeAll()
            do_download = LKRoot.container_package_repo
        } else {
            // 更新下载缓存 删除被删除的源的下载缓存
            var download_cache = [String : String]()
            for item in LKRoot.container_package_repo_download {
                var exists = false
                for exs in LKRoot.container_package_repo where item.key == exs.link && item.value != "" {
                    exists = true
                    break
                }
                if exists {
                    download_cache[item.key] = item.value
                }
            }
            LKRoot.container_package_repo_download = download_cache
            // 构建需要下载的列表
            for item in LKRoot.container_package_repo {
                if LKRoot.container_package_repo_download[item.link] == nil || LKRoot.container_package_repo_download[item.link] == "" {
                    do_download.append(item)
                }
            }
            
        }
        
        for item in do_download {
            var found = false
            inner_search: for search_url in LKRoot.ins_networking.release_search_path where !found {
                guard let url = URL(string: item.link + search_url) else {
                    continue inner_search
                }
                // 检查文件扩展名
                var backend = ""
                if search_url.contains(".") {
                    backend = String(search_url.split(separator: ".").last ?? "")
                }
                let ss = DispatchSemaphore(value: 0)
                var finished = false
                print("[*] 准备从 " + url.absoluteString + " 请求数据。")
                if session_id != LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_SYNC"] {
                    return
                }
                AF.request(url, method: .get, headers: LKRoot.ins_networking.read_header()).response(queue: LKRoot.queue_dispatch) { (respond) in
                    finished = true
                    if respond.data == nil || session_id != LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_SYNC"] {
                        ss.signal()
                        return
                    }
                    
                    let raw_data = respond.data!
                    let out_data: Data
                    
                    switch backend {
                    case "bz", "bz2":
                        if let decompress_data = try? BZip2.decompress(data: raw_data) {
                            out_data = decompress_data
                        } else {
                            out_data = raw_data
                        }
                    case "gz", "gz2":
                        if let decompress_data = try? BZip2.decompress(data: raw_data) {
                            out_data = decompress_data
                        } else {
                            out_data = raw_data
                        }
                    default:
                        out_data = raw_data
                    }
                    
                    var str: String? = String(data: out_data, encoding: .utf8)
                    if str == nil {
                        str = String(data: out_data, encoding: .ascii)
                    }
                    if str == nil || str == "" || str?.hasPrefix("<!DOCTYPE") ?? false || str?.hasPrefix("<html>") ?? false || str?.hasPrefix("<?xml version=") ?? false {
                        ss.signal()
                        return
                    }
                    // yo! 找到正确的数据了！
                    if session_id != LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_SYNC"] {
                        ss.signal()
                        return
                    }
                    LKRoot.container_package_repo_download[item.link] = str!
                    found = true
                    ss.signal()
                    return
                }
                LKRoot.queue_dispatch.async {
                    sleep(UInt32(LKRoot.settings?.network_timeout ?? 6))
                    if finished || session_id != LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_SYNC"] {
                        return
                    }
                    finished = true
                    ss.signal()
                }
                ss.wait()
            } // inner_search
        }
        LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] = "NO"
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = "SIGCLEAR"
        
        PR_print_ram_status()
        
        CallB(operation_result.success.rawValue)
        
        LKRoot.queue_dispatch.async {
            let session = UUID().uuidString
            LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_DATABASE"] = session
            self.PR_package_wrapper(session: session) { (_) in
            }
        }
    } // PR_download_all_package
    
    func PR_package_wrapper(session: String, _ CallB: @escaping (Int) -> Void) {
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = "正在刷新软件包列表，这可能需要一些时间。".localized()
        // 上锁
        if LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] == "TRUE" || LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_DATABASE"] != session {
            return
        }
        LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] = "TRUE"
        guard let package_from_database: [DBMPackage] = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKPackages.rawValue) else {
            print("[E] 无法从 LKPackages 中获得数据，终止同步。")
            LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] = "FALSE"
            CallB(operation_result.failed.rawValue)
            return
        }
        
        // 获取时间
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let now = formatter.string(from: date)
        
        let update_sig = DBMPackage()
        update_sig.signal = "BEGIN_UPDATE"
        try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKPackages.rawValue,
                                    on: [DBMPackage.Properties.signal],
                                    with: update_sig)
        
        // 炒鸡快炸膘！   id          内容咯
        var packages = [String : DBMPackage]()
        // 更新快查表
        print("[*] 开始更新软件包快查表")
        for item in package_from_database {
            let new = item
            //                  v1        v2       v3
            var new_version = [String : [String : [String : String]]]()
            for v1 in new.version {
                for v2 in v1.value {
                    var new_value = v2.value
                    new_value["_internal_SIG_begin_update"] = "0x0"
                    new_version[v1.key] = [v2.key : new_value]
                }
            }
            new.version = new_version
            packages[item.id] = new
        }
        
        var thread_cache = [String : String]()
        for item in LKRoot.container_package_repo_download {
            thread_cache[item.key] = item.value
        }
        
        print("[*] 开始更新软件包")
        for item in thread_cache where item.value != "" {
            var read_in = item.value
            read_in.append("\n\n")
            // 进行解包
            do {
                // 临时结构体
                var info_head = ""
                var info_body = ""
                var in_head = true
                var line_break = false
                var has_a_maohao = false
                var this_package = [String : String]()
                // 开始遍历数据
                for char in read_in {
                    let c = char.description
                    inner: if c == ":" {
                        line_break = false
                        in_head = false
                        if has_a_maohao {
                            info_body += ":"
                        } else {
                            has_a_maohao = true
                        }
                    } else if c == "\n" {
                        if line_break == true {
                            // 两行空行，新数据包 判断软件包是否存在 如果存在则更新version字段
                            // 先加一个属性
                            this_package["_internal_SIG_begin_update"] = "0x1"
                            
                            
                            
                            if this_package["PACKAGE"] == nil || this_package["VERSION"] == nil {
                                //                            print("[*] 丢弃没有id的软件包")
                            } else if packages[this_package["PACKAGE"]!] != nil {
                                this_package["PACKAGE"] = this_package["PACKAGE"]!.lowercased()
                                // 存在软件包
                                if packages[this_package["PACKAGE"]!]!.version[this_package["VERSION"]!] == nil {
                                    // 不存在！
                                    packages[this_package["PACKAGE"]!]!.latest_update_time = now
                                }
                                // 直接添加 version 不检查 version 是否存在因为它不存在就奇怪了
                                let v1 = [item.key: this_package] // 【软件源地址 ： 【属性 ： 属性值】】
                                if packages[this_package["PACKAGE"]!]!.version[this_package["VERSION"]!] != nil {
                                    // 存在 version 先对比一下存不存在这个源地址
//                                    if packages[this_package["PACKAGE"]!]!.version[this_package["VERSION"]!]![item.key] != nil {
                                       // 同一个源 咱们覆盖
                                        packages[this_package["PACKAGE"]!]!.version[this_package["VERSION"]!]![item.key] = this_package
//                                    } else {
//                                        // 不是同一个源 添加 操作相同所以就一起呗
//                                        packages[this_package["PACKAGE"]!]!.version[this_package["VERSION"]!]![item.key] = this_package
//                                    }
                                } else {
                                    // 不存在这个 version 咯
                                    packages[this_package["PACKAGE"]!]!.version[this_package["VERSION"]!] = v1
                                }
                                // 因为存在软件包 所以我们更新一下 SIG 字段
                                packages[this_package["PACKAGE"]!]!.signal = ""
                                packages[this_package["PACKAGE"]!]!.one_of_the_package_name_lol = this_package["NAME"] ?? ""
                                packages[this_package["PACKAGE"]!]!.one_of_the_package_section_lol = this_package["SECTION"] ?? ""
                            } else {
                                this_package["PACKAGE"] = this_package["PACKAGE"]!.lowercased()
                                // 不存在软件包 创建软件包
                                let new = DBMPackage()
                                new.id = this_package["PACKAGE"]!
                                // latest_update_time 我们去写入数据库的时候更新
                                let v1 = [item.key: this_package] // 【软件源地址 ： 【属性 ： 属性值】】
                                // 新软件包的更新 sig 不需要修改
                                new.latest_update_time = now
                                new.version[this_package["VERSION"]!] = v1
                                new.one_of_the_package_name_lol = this_package["NAME"] ?? ""
                                packages[this_package["PACKAGE"]!] = new
                            }
                            this_package = [String : String]()
                            has_a_maohao = false
                            break inner
                        }
                        line_break = true
                        in_head = true
                        if info_head == "" || info_body == "" {
                            has_a_maohao = false
                            break inner
                        }
                        while info_head.hasPrefix("\n") {
                            info_head = String(info_head.dropFirst())
                        }
                        info_body = String(info_body.dropFirst())
                        while info_body.hasPrefix(" ") {
                            info_body = String(info_body.dropFirst())
                        }
                        this_package[info_head.uppercased()] = info_body
                        info_head = ""
                        info_body = ""
                        if in_head {
                            info_head += c
                        }
                    } else {
                        line_break = false
                        if in_head {
                            info_head += c
                        } else {
                            info_body += c
                        }
                    }
                }
                
            } // do
            if LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_DATABASE"] != session {
                return
            }
        }
        // 终于完成了啊哈哈哈哈哈哈哈哈 咳咳准备数据库
        
        // 写入更新
        if LKRoot.container_string_store["SESSION_ID_PACKAGE_REPO_DATABASE"] != session {
            return
        }
        LKRoot.container_packages.removeAll()
        for key_pair_value in packages where PR_should_add_this(package: key_pair_value.value) {
            LKRoot.container_packages[key_pair_value.key] = key_pair_value.value
            try? LKRoot.root_db?.insertOrReplace(objects: key_pair_value.value, intoTable: common_data_handler.table_name.LKPackages.rawValue)
        }
        // 删除全部没有找到的软件包
        try? LKRoot.root_db?.delete(fromTable: common_data_handler.table_name.LKPackages.rawValue,
                                    where: DBMPackage.Properties.signal == "BEGIN_UPDATE")
        
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = "SIGCLEAR"
        LKRoot.container_string_store["IN_PROGRESS_DOWNLOAD_PACKAGE_REPOS"] = "FALSE"
        LKRoot.container_string_store["REQUEST_SEARCH_TAB_REBUILD"] = "TRUE"
        
        LKRoot.manager_reg.ru.re_sync()
        if LKRoot.manager_reg.ru.initd {
            DispatchQueue.main.async {
                LKRoot.manager_reg.ru.update_interface()
            }
        }
        if LKRoot.manager_reg.rp.initd {
            DispatchQueue.main.async {
                LKRoot.manager_reg.rp.update_interface()
            }
        }
        
        
        print("[*] 开始更新已安装")
        let new_session = UUID().uuidString
        LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE_SESSION"] = new_session
        YA_build_installed_list(session: new_session) { (_) in
            
        }
        
        // 同步一次数据
        let read_again: [DBMPackage]? = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKPackages.rawValue)
        var sync_again = [String : DBMPackage]()
        for item in read_again ?? [] {
            sync_again[item.id] = item
        }
        LKRoot.container_packages = sync_again
        
        DispatchQueue.main.async {
            presentSwiftMessageSuccess(title: "提示".localized(), body: "软件包刷新已经完成！".localized())
        }
        
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = ""
        print("[*] 更新软件包完成")
        CallB(operation_result.success.rawValue)
    }
    
    func PR_should_add_this_repo(repo: DMPackageRepos, root_db: [DBMPackageRepos]) -> Bool {
        for item in root_db where (item.link ?? UUID().uuidString) == repo.link {
            return true
        }
        return false
    }
    
    func PR_should_add_this(package: DBMPackage) -> Bool {
        for v1 in package.version {
            for v2 in v1.value where v2.value["_internal_SIG_begin_update"] == "0x1" {
                return true
            }
        }
        return false
    }
    
}

/*
 
 9 to 8 I feel so grate
 7 to 6 need my hair fix
 5 to 4 what you waiting for
 3 2 1 let go have fun

 just don't get mad when you trying to do things with database
 tell yourself you love it, you can habdle it!
 
 操你妈了个逼的数据库老子再也不想碰一下
 
 */
