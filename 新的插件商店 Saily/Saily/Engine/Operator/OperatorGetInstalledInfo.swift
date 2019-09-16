//
//  OperatorGetInstalledInfo.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/16.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension app_opeerator {
    
    // YA means 已安装 Yi An Zhuang
    // Because when I tried to use AI or II or sth like that,
    // It always like fucked by ilIL1
    // Thanks for understanding
    
    func YA_sync_dpkg_info() -> Int {
        if LKRoot.isRootLess {
            return operation_result.failed.rawValue
        }
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/dpkg")
        if FileManager.default.fileExists(atPath: LKRoot.root_path! + "/dpkg") {
            print("[?] dpkg 同步出错了？")
        }
        try? FileManager.default.copyItem(atPath: "/Library/dpkg", toPath: LKRoot.root_path! + "/dpkg")
        if !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/dpkg") {
            print("[?] 无法直接拷贝 dpkg 存档，尝试拷贝 status")
            try? FileManager.default.createDirectory(atPath: LKRoot.root_path! + "/dpkg", withIntermediateDirectories: true, attributes: nil)
        }
        try? FileManager.default.copyItem(atPath: "/Library/dpkg/status", toPath: LKRoot.root_path! + "/dpkg/status")
        if !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/dpkg/status") {
            return operation_result.failed.rawValue
        }
        return operation_result.success.rawValue
    }
    
    func YA_build_installed_list(session: String, _ CallB: @escaping (Int) -> Void) {
        LKRoot.queue_dispatch.async {
            sleep(1)
            if FileManager.default.fileExists(atPath: LKRoot.root_path! + "/dpkg/status")  && !LKRoot.isRootLess {
                return
            }
            self.YA_build_installed_list_rootless()
        }
        if YA_sync_dpkg_info() == operation_result.failed.rawValue {
            CallB(operation_result.failed.rawValue)
            return
        }
        let read_status = (try? String(contentsOfFile:  LKRoot.root_path! + "/dpkg/status")) ?? "ERR_READ"
        // 尝试从存档获取
        
        LKRoot.container_string_store["STR_SIG_PROGRESS"] = "正在刷新软件包列表，这可能需要一些时间。".localized()
        if LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE"] == "TRUE" || session != LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE_SESSION"] {
            LKRoot.container_string_store["STR_SIG_PROGRESS"] = ""
            return
        }
        LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE"] = "TRUE"
        
        print("[*] 开始更新已安装")
        
        var package = [String : DBMPackage]()
        let read_db: [DBMPackage]? = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue)
        for item in read_db ?? [] {
            package[item.id] = item
            item.version.removeAll()
            item.signal = "BEGIN_UPDATE"
        }
        
        LKRoot.container_installed_provides.removeAll()
        
        // 获取时间
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let now = formatter.string(from: date)
        
        let update_sig = DBMPackage()
        update_sig.signal = "BEGIN_UPDATE"
        try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKRecentInstalled.rawValue,
                                    on: [DBMPackage.Properties.signal],
                                    with: update_sig)
        
        
        var read_in = read_status.cleanRN()
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
                        if this_package["PACKAGE"] == nil || YA_package_in_exclude_list(id: this_package["PACKAGE"]!) {
                            //                            print("[*] 丢弃没有id的软件包")
                        } else if package[this_package["PACKAGE"]!] != nil {
                            this_package["PACKAGE"] = this_package["PACKAGE"]!.lowercased()
                            // 存在软件包
                            this_package["_internal_SIG_begin_update"] = "0x1"
                            // 直接添加 version 不检查 version 是否存在因为它不存在就奇怪了
                            let v1 = ["LOCAL": this_package] // 【软件源地址 ： 【属性 ： 属性值】】
                            package[this_package["PACKAGE"]!]!.version[this_package["VERSION"] ?? "0"] = v1
                            // 因为存在软件包 所以我们更新一下 SIG 字段
                            package[this_package["PACKAGE"]!]!.signal = ""
                            package[this_package["PACKAGE"]!]!.one_of_the_package_name_lol = this_package["NAME"] ?? ""
                            if this_package["STATUS"] == "install ok installed" {
                                package[this_package["PACKAGE"]!]!.status = current_info.installed_ok.rawValue
                            } else if this_package["STATUS"] != nil && this_package["STATUS"] != "" {
                                package[this_package["PACKAGE"]!]!.status = current_info.installed_bad.rawValue
                            }
                            if let pro = this_package["PROVIDES"] {
                                var provides = PAK_read_all_provides(provideStr: pro)
                                provides[this_package["PACKAGE"]!] = this_package["Version"]
                                for item in provides {
                                    LKRoot.container_installed_provides[item.key] = item.value
                                }
                            } else {
                                LKRoot.container_installed_provides[this_package["PACKAGE"]!] = this_package["VERSION"]
                            }
                        } else {
                            this_package["PACKAGE"] = this_package["PACKAGE"]!.lowercased()
                            // 不存在软件包 创建软件包
                            this_package["_internal_SIG_begin_update"] = "0x1"
                            let new = DBMPackage()
                            new.id = this_package["PACKAGE"]!
                            // latest_update_time 我们去写入数据库的时候更新
                            let v1 = ["LOCAL": this_package] // 【软件源地址 ： 【属性 ： 属性值】】
                            new.version[this_package["VERSION"] ?? "0"] = v1
                            new.one_of_the_package_name_lol = this_package["NAME"] ?? ""
                            new.latest_update_time = now
                            package[this_package["PACKAGE"]!] = new
                            if this_package["STATUS"] == "install ok installed" {
                                package[this_package["PACKAGE"]!]!.status = current_info.installed_ok.rawValue
                            } else if this_package["STATUS"] != nil && this_package["STATUS"] != "" {
                                package[this_package["PACKAGE"]!]!.status = current_info.installed_bad.rawValue
                            }
                            if let pro = this_package["PROVIDES"] {
                                var provides = PAK_read_all_provides(provideStr: pro)
                                provides[this_package["PACKAGE"]!] = this_package["Version"]
                                for item in provides {
                                    LKRoot.container_installed_provides[item.key] = item.value
                                }
                            } else {
                                LKRoot.container_installed_provides[this_package["PACKAGE"]!] = this_package["VERSION"]
                            }
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
        
        for item in package where item.value.signal != "BEGIN_UPDATE" {
            item.value.signal = "LOCAL"
        }
        
        // 写入更新
        if LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE_SESSION"] != session {
            return
        }
        for key_pair_value in package  {
            try? LKRoot.root_db?.insertOrReplace(objects: key_pair_value.value, intoTable: common_data_handler.table_name.LKRecentInstalled.rawValue)
        }
        // 删除全部没有找到的软件包
        try? LKRoot.root_db?.delete(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue,
                                    where: DBMPackage.Properties.signal == "BEGIN_UPDATE")
        
        // 重新读取带有最后更新时间数据的数据 lololololol
        let read_again: [DBMPackage]? = try? LKRoot.root_db?.getObjects(fromTable: common_data_handler.table_name.LKRecentInstalled.rawValue)
        package.removeAll()
        for item in read_again ?? [] {
            package[item.id] = item
        }
        LKRoot.container_packages_installed_DBSync = package
        
        LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE"] = "FALSE"
        
        if LKRoot.manager_reg.ya.initd {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                LKRoot.manager_reg.ya.update_interface {
                    
                }
            }
        }
        
        print("[*] 更新已安装完成")
        CallB(operation_result.success.rawValue)
    }
    
    func YA_build_installed_list_rootless() {
        if !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/rtlInstall.db") {
            return
        }
        if let read: [DMRTLInstallTrace] = try? LKRoot.rtlTrace_db?.getObjects(fromTable: common_data_handler.table_name.LKRootLessInstalledTrace.rawValue) {
            var package = [String : DBMPackage]()
            for item in read {
                let new = DBMPackage()
                new.id = item.id ?? UUID().uuidString
                new.latest_update_time = item.time ?? "20011002"
                // 合成FileList
                var list = ""
                for f in item.list ?? [] {
                    list += f
                    list += "\n"
                }
                // 版本容器包含了 【版本号 ： 【软件源地址 ： 【属性 ： 属性值】】】
                var some = ""
                if item.usedDPKG ?? false {
                    some = "YES"
                } else {
                    some = "NO"
                }
                new.version = ["none" : ["rootLessInstall.id" : ["FILELIST" : list, "USEDDPKG" : some]]]
                new.signal = "rootless_installed"
                new.status = current_info.installed_ok.rawValue
                package[new.id] = new
            }
            LKRoot.container_packages_installed_DBSync = package
            LKRoot.container_recent_installed.removeAll()
            for item in package {
                LKRoot.container_recent_installed.append(item.value)
            }
            for key_pair_value in package  {
                try? LKRoot.root_db?.insertOrReplace(objects: key_pair_value.value, intoTable: common_data_handler.table_name.LKRecentInstalled.rawValue)
            }
            LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE"] = "FALSE"
            if LKRoot.manager_reg.ya.initd {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    LKRoot.manager_reg.ya.update_interface(isSentFromRootLess: true) {
                    }
                }
            }
        }
    }
    
    func YA_package_in_exclude_list(id: String) -> Bool {
        return EXCLUDE_INSTALLED_LIST.contains(id)
    }
    
}
