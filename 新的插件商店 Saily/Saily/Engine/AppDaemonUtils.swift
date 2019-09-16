//
//  AppDaemonUtils.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/20.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

enum daemon_status: String {
    case ready
    case busy
    case offline
}

let LKDaemonUtils = app_daemon_utils()

// swiftlint:disable:next type_body_length
class app_daemon_utils {
    
    var session = ""
    var sender_lock = false
    var initialized = false
    let object = LKCBObject()
    
    var status = daemon_status.offline
    
    // swiftlint:disable:next weak_delegate
    let ins_operation_delegate = AppOperationDelegate()
    // swiftlint:disable:next weak_delegate
    let ins_download_delegate = AppDownloadDelegate()
    
    func initializing() {
        if LKDaemonUtils.session != "" {
            fatalError("[E] LKDaemonUtils 只允许初始化一次 只允许拥有一个实例")
        }
        self.session = UUID().uuidString
        self.initialized = true
        print("[*] App_daemon_utils initialized.")
        LKRoot.queue_dispatch.async {
            self.checkDaemonOnline { (ret) in
                print("[*] 获取到 Dameon 状态： " + ret.rawValue)
                self.status = ret
                
                if self.status == .ready && LKRoot.firstOpen {
                    self.daemon_msg_pass(msg: "init:req:restoreCheck")
                    sleep(1)
                    if FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/shouldRestore") {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "恢复".localized(), message: "我们检测到系统重置了我们的存档目录，将尝试执行恢复。".localized(), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "执行".localized(), style: .default, handler: { (_) in
                                UIApplication.shared.beginIgnoringInteractionEvents()
                                IHProgressHUD.show()
                                LKRoot.queue_dispatch.async {
                                    LKRoot.root_db?.close()
                                    try? FileManager.default.removeItem(atPath: LKRoot.root_path!)
                                    try? FileManager.default.createDirectory(atPath: LKRoot.root_path!, withIntermediateDirectories: true, attributes: nil)
                                    try? FileManager.default.createDirectory(atPath: LKRoot.root_path! + "/daemon.call", withIntermediateDirectories: true, attributes: nil)
                                    self.daemon_msg_pass(msg: "init:req:restoreDocuments")
                                    while !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/resotreCompleted") {
                                        usleep(2333)
                                    }
                                    DispatchQueue.main.async {
                                        IHProgressHUD.dismiss()
                                        let alert = UIAlertController(title: "⚠️", message: "请重启程序".localized(), preferredStyle: .alert)
                                        presentViewController(some: alert)
                                        LKRoot.should_backup_when_exit = false
                                    }
                                }
                            }))
                            presentViewController(some: alert)
                        }
                    }
                }
                
                if self.status == .ready && FileManager.default.fileExists(atPath: LKRoot.root_path! + "/ud.id") {
                    if let udid = try? String(contentsOfFile: LKRoot.root_path! + "/ud.id") {
                        if udid != "" && LKRoot.settings?.real_UDID != udid {
                            let new = DBMSettings()
                            new.real_UDID = udid
                            try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKSettings.rawValue, on: [DBMSettings.Properties.real_UDID], with: new)
                            LKRoot.settings?.real_UDID = udid
                            DispatchQueue.main.async {
                                let home = (LKRoot.tabbar_view_controller as? UIEnteryS)?.home
                                for view in home?.view.subviews ?? [] {
                                    view.removeFromSuperview()
                                }
                                home?.container = nil
                                home?.viewDidLoad()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestBackup() -> operation_result {
        if status != .ready {
            LKDaemonUtils.checkDaemonOnline { (ret) in
                self.status = ret
            }
            return .failed
        }
        daemon_msg_pass(msg: "init:req:backupDocuments")
        return .success
    }
    
    func daemon_msg_pass(msg: String) {
        if sender_lock == true {
            print("[-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-]")
            print("[-] [-] [-] [-] [-] 发送器已上锁请检查线程安全!! [-] [-] [-] [-] [-] [-]")
            print("[-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-] [-]")
            presentSwiftMessageError(title: "未知错误".localized(), body: "向权限经理发送消息失败".localized())
            LKRoot.breakPoint()
            return
        }
        sender_lock = true
        object.call_to_daemon_(with: "com.Lakr233.Saily.MsgPass.read.Begin")
        usleep(2333)
        let charasets = msg.charactersArray
        for item in charasets {
            let cs = String(item)
            let str = "com.Lakr233.Saily.MsgPass.read." + cs
            object.call_to_daemon_(with: str)
            usleep(2333)
        }
        object.call_to_daemon_(with: "com.Lakr233.Saily.MsgPass.read.End")
        usleep(2333)
        print("[*] 向远端发送数据完成：" + msg)
        sender_lock = false
    }
    
    func checkDaemonOnline(_ complete: @escaping (daemon_status) -> Void) {
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/status.txt")
        try? "".write(toFile: LKRoot.root_path! + "/daemon.call/status.txt", atomically: true, encoding: .utf8)
        LKRoot.queue_dispatch.async {
            self.daemon_msg_pass(msg: "init:path:" + LKRoot.root_path!)
            usleep(2333)
            self.daemon_msg_pass(msg: "init:status:required_call_back")
            var cnt = 0
            while cnt < 666 {
                usleep(2333)
                if FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/status.txt") {
                    if let str_read = try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/status.txt") {
                        switch str_read {
                        case "ready\n": complete(daemon_status.ready); return
                        case "rootless\n":
                            presentSwiftMessageSuccess(title: "侦测到Rootless越狱".localized(), body: "插件依赖的安装可能会出现问题，请在安装前仔细检查。".localized())
                            LKRoot.isRootLess = true
                            complete(daemon_status.ready)
                            return
                        case "busy\n": complete(daemon_status.busy); return
                        default:
                            cnt += 1
                        }
                    }
                }
                cnt += 1
            }
            complete(daemon_status.offline)
        }
    }
    
    func submit() -> (operation_result, String) {
        
        // 再次检查表单 <- 晚点再写吧我对我自己粗查代码还是很自信的
        ins_operation_delegate.printStatus()
        
        if LKRoot.isRootLess {
            print("[*] RootLess init...")
            try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/out.txt")
            try? "RootLess Installer - @Lakr233".write(toFile: LKRoot.root_path! + "/daemon.call/out.txt", atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    presentSwiftMessageController(some: LKDaemonMonitor(), interActinoEnabled: false)
                }
                LKRoot.queue_dispatch.asyncAfter(deadline: .now() + 1) {
                    self.rootlessSubmit()
                }
            }
        } else {
            
            var auto_install = [String]()
            var required_install = [String]()
            var required_reinstall = [String]()
            var required_remove = [String]()
            
            for item in ins_operation_delegate.operation_queue {
                var thisSection = ""
                switch item.operation_type {
                case .required_install, .required_reinstall:
                    // 拷贝安装资源
                    if let path = item.dowload?.path {
                        if FileManager.default.fileExists(atPath: path) {
                            let target = LKRoot.root_path! + "/daemon.call/debs/" + UUID().uuidString + ".deb"
                            try? FileManager.default.copyItem(atPath: path, toPath: target)
                            thisSection = "dpkg -i " + target
                            if item.operation_type == .required_install {
                                required_install.append(thisSection)
                            } else {
                                required_reinstall.append(thisSection)
                            }
                        } else {
                            return (.failed, item.package.id)
                        }
                    } else {
                        return (.failed, item.package.id)
                    }
                case .required_remove:
                    required_remove.append("dpkg --purge " + item.package.id)
                case .required_config:
                    print("required_config")
                case .required_modify_dcrp:
                    print("required_modify_dcrp")
                case .auto_install:
                    // 拷贝安装资源
                    if let path = item.dowload?.path {
                        if FileManager.default.fileExists(atPath: path) {
                            let target = LKRoot.root_path! + "/daemon.call/debs/" + UUID().uuidString + ".deb"
                            try? FileManager.default.copyItem(atPath: path, toPath: target)
                            thisSection = "dpkg -i " + target
                            auto_install.append(thisSection)
                        } else {
                            return (.failed, item.package.id)
                        }
                    } else {
                        return (.failed, item.package.id)
                    }
                case .DNG_auto_remove:
                    print("apt autoremove")
                case .unknown:
                    print("unknown")
                }
            }
            
            var script = ""
            for item in auto_install + required_reinstall + required_install + required_remove {
                script += item + " &>> " + LKRoot.root_path! + "/daemon.call/out.txt ;\n"
            }
            
            script += "dpkg --configure -a &>> " + LKRoot.root_path! + "/daemon.call/out.txt ;\n"
            script += "echo Saily::internal_session_finished::Signal &>> " + LKRoot.root_path! + "/daemon.call/out.txt ;\n"
            
            try? script.write(toFile: LKRoot.root_path! + "/daemon.call/requestScript.txt", atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/out.txt")
            try? "".write(toFile: LKRoot.root_path! + "/daemon.call/out.txt", atomically: true, encoding: .utf8)
            
            print("---- Script ----")
            print("")
            print(script)
            print("---- ------ ----")
            
            
            daemon_msg_pass(msg: "init:req:fromScript")
            
            if status != .ready {
                LKRoot.queue_dispatch.async {
                    self.checkDaemonOnline { (ret) in
                        print("[*] 获取到 Dameon 状态： " + ret.rawValue)
                        self.status = ret
                    }
                }
                return (.failed, "Saily.Daemon")
            }
            
            // 打开监视窗口
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentSwiftMessageController(some: LKDaemonMonitor(), interActinoEnabled: false)
            }
        }
        
        return (.success, "")
    }
    
    func appendLogToFile(log: String) {
        if var read = try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/out.txt") {
            read += "\n"
            read += log
            try? read.write(toFile: LKRoot.root_path! + "/daemon.call/out.txt", atomically: true, encoding: .utf8)
        } else {
            try? log.write(toFile: LKRoot.root_path! + "/daemon.call/out.txt", atomically: true, encoding: .utf8)
        }
    }
    
    func rootlessSubmit() {
        
        appendLogToFile(log: "Preparing submit...")
        
        // 创建安装队列
        var originalInstallFile = [String : String]()
        var rootLessQueue_Install = [String : String]()
        var rootLessQueue_unInstall = [String : [String]]()
        var rootLessQueue_unInstall_dpkg = [String]()
        
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/pendingExtract")
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/pendingInstall")
        try? FileManager.default.createDirectory(atPath: LKRoot.root_path! + "/daemon.call/pendingExtract", withIntermediateDirectories: true, attributes: nil)
        
        for item in ins_operation_delegate.operation_queue {
            switch item.operation_type {
            case .required_install, .required_reinstall, .auto_install:
                // 拷贝安装资源
                if let path = item.dowload?.path {
                    let to = LKRoot.root_path! + "/daemon.call/pendingExtract" + "/" + item.package.id + ".deb"
                    try? FileManager.default.copyItem(atPath: path, toPath: to)
                    originalInstallFile[item.package.id] = path
                    rootLessQueue_Install[item.package.id] = to
                    appendLogToFile(log: "Copying to " + to)
                } else {
                    print("[?] if let path = item.dowload?.path")
                }
            case .required_remove:
                // 获取文件列表
                let id = item.package.id
                if item.package.version.first?.value.first?.value["USEDDPKG"] == "YES" {
                    rootLessQueue_unInstall_dpkg.append(id)
                } else {
                    var fileList = [String]()
                    for line in item.package.version.first?.value.first?.value["FILELIST"]?.split(separator: "\n") ?? [] {
                        fileList.append(line.to_String())
                    }
                    rootLessQueue_unInstall[id] = fileList
//                    print(fileList)
                }
            default:
                print("[?] 这里有一个不被rootless支持的操作")
            }
        }
        
        // MARK: EXTRACT
        // 已经把数据准备好了 等待dpkg开始解压
        appendLogToFile(log: "Submit extract...")
        LKDaemonUtils.daemon_msg_pass(msg: "init:req:extractDEB")
        while !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/pendingExtract/Done") {
            usleep(233333)
        }
        sleep(1) // Fix Permission
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/pendingExtract/Done")
        appendLogToFile(log: "Daemon returned!")
        appendLogToFile(log: (try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/pendingExtract/Done")) ?? "")
        
        // 解压完成 等待修正
        try? FileManager.default.moveItem(atPath: LKRoot.root_path! + "/daemon.call/pendingExtract", toPath: LKRoot.root_path! + "/daemon.call/pendingPatch")
        appendLogToFile(log: "Creating patch scripts...")
        // 我管你🐎的全部屁吃！
        
        // 构建需要修正的软件包列表
        var fixListAll = [String]()
        let prefix = LKRoot.root_path! + "/daemon.call/pendingPatch"
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: prefix)) ?? []
        
        for package in contents {
            let path = prefix + "/" + package
            if FileManager.default.fileExists(atPath: path + "/" + ".LKRootLessSkipPatch") {
                appendLogToFile(log: "Skipping patch at " + package)
                try? FileManager.default.removeItem(atPath: path + "/" + ".LKRootLessSkipPatch")
            } else {
                fixListAll.append(path)
            }
        }
        
        // MARK: PATCH
        let origPatchScript = Bundle.main.url(forResource: "RootLessPatch", withExtension: ".sh")!
        let text = (try? String(contentsOfFile: origPatchScript.absoluteString.dropFirst("file://".count).to_String()))!

        var fine = "/var/containers/Bundle/iosbinpack64/bin/chmod -R 777 " + LKRoot.root_path! + "/daemon.call/pendingPatch/\n"
        
        for item in fixListAll {
            var patchOne = "export packagePath=" + item + "\n"
            patchOne += text
            try? patchOne.write(toFile: item + "/p.sh", atomically: true, encoding: .utf8)
            fine += "/var/containers/Bundle/iosbinpack64/bin/chmod +x '" + item + "/p.sh'\n"
            fine += "/var/containers/Bundle/iosbinpack64/bin/bash -c '" + item + "/p.sh >> " + LKRoot.root_path! + "/daemon.call/out.txt" + "'\n"
        }
        
        let patchScriptPath = LKRoot.root_path! + "/daemon.call/pendingPatch/LKRTLPatchScript.sh"
        try? fine.write(toFile: patchScriptPath, atomically: true, encoding: .utf8)
        
        appendLogToFile(log: "Submiting patches...\n")
        LKDaemonUtils.daemon_msg_pass(msg: "init:req:rtlPatch")
        while !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/pendingPatch/Done") {
            usleep(233333)
        }
        sleep(1) // Fix Permission
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/pendingPatch/Done")
        appendLogToFile(log: "Daemon returned!")
        appendLogToFile(log: (try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/pendingPatch/Done")) ?? "")
        
        // 记录软件包的文件
        var script_install = """
#!/var/containers/Bundle/iosbinpack64/bin/bash

export LANG=C
export LC_CTYPE=C
export LC_ALL=C

# -->_<--

"""
        // MARK: UNINSTALL
        // 卸载脚本
        for uninstall in rootLessQueue_unInstall {
            for remove in uninstall.value {
                script_install += "/var/containers/Bundle/iosbinpack64/bin/rm -f '/var/containers/Bundle/tweaksupport/" + remove + "'" + "\n"
            }
            try? LKRoot.rtlTrace_db?.delete(fromTable: common_data_handler.table_name.LKRootLessInstalledTrace.rawValue,
                                       where: DMRTLInstallTrace.Properties.id == uninstall.key)
        }
        for uninstall in rootLessQueue_unInstall_dpkg {
            script_install += "dpkg --purge " + uninstall + "\n"
            try? LKRoot.rtlTrace_db?.delete(fromTable: common_data_handler.table_name.LKRootLessInstalledTrace.rawValue,
                                            where: DMRTLInstallTrace.Properties.id == uninstall)
        }
        
        // 刷新已安装
        // WHY??? REMOVED
        
        // MARK: TRACE
        try? FileManager.default.moveItem(atPath: LKRoot.root_path! + "/daemon.call/pendingPatch", toPath: LKRoot.root_path! + "/daemon.call/pendingTrace")
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: LKRoot.root_path! + "/daemon.call/pendingTrace") {
            inner: for object in contents {
                var name = object.dropLast(4).to_String()
                if name == "LKRTLPatchScrip" {
                    continue inner
                }
                name = name.dropLast(4).to_String()
                appendLogToFile(log: "\nTracing installation on " + name)
                let dbRecord = DMRTLInstallTrace()
                dbRecord.id = name
                dbRecord.list = [String]()
                let trace = (LKRoot.root_path! + "/daemon.call/pendingTrace/" + object).readAllFiles()
                let cnt = (LKRoot.root_path! + "/daemon.call/pendingTrace/" + object).count
                if !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/pendingTrace/" + object + "/var/LKRootLessForceDPKG") {
                    for longlongfile in trace {
                        let notabspath = longlongfile.dropFirst(cnt).to_String()
                        dbRecord.list?.append(notabspath)
                        var possibleDir = notabspath
                        while !possibleDir.hasSuffix("/") && possibleDir.count > 0 {
                            possibleDir = possibleDir.dropLast().to_String()
                        }
                        if possibleDir.count < 1 {
                            continue inner
                        }
                        script_install += "/var/containers/Bundle/iosbinpack64/bin/mkdir -p '/var/containers/Bundle/tweaksupport/" + possibleDir + "'" + "\n"
                        let replaced = longlongfile.replacingOccurrences(of: "pendingTrace", with: "pendingInstall")
                        script_install += "/var/containers/Bundle/iosbinpack64/bin/rm -f '/var/containers/Bundle/tweaksupport/" + notabspath + "'" + "\n"
                        script_install += "/var/containers/Bundle/iosbinpack64/bin/cp -rf '" + replaced + "' '/var/containers/Bundle/tweaksupport/" + notabspath + "'" + "\n"
                    }
                    dbRecord.usedDPKG = false
                    if FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/pendingTrace/" + object + "/installScript.sh") {
                        script_install += "echo [Execute] Post Install at Package " + name
                        script_install += " >> " + LKRoot.root_path! + "/daemon.call/out.txt\n"
                        script_install += "chmod +x " + LKRoot.root_path! + "/daemon.call/pendingInstall/" + object + "/installScript.sh\n"
                        script_install += "bash -c " + LKRoot.root_path! + "/daemon.call/pendingInstall/" + object + "/installScript.sh\n"
                    }
                } else {
                    // dpkg installation
                    dbRecord.usedDPKG = true
                    script_install += "echo [dpkg] Post Install at Package " + name
                    script_install += " >> " + LKRoot.root_path! + "/daemon.call/out.txt\n"
                    script_install += "rm -f /var/LKRootLessForceDPKG\n"
                    script_install += "dpkg -i " + (originalInstallFile[name] ?? UUID().uuidString) + "\n"
                    script_install += "rm -f /var/LKRootLessForceDPKG\n"
                }
                let currentDateTime = Date()
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                formatter.dateStyle = .long
                dbRecord.time = formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
                try? LKRoot.rtlTrace_db?.insertOrReplace(objects: dbRecord, intoTable: common_data_handler.table_name.LKRootLessInstalledTrace.rawValue)
            }
        } else {
            print("[?] pendingTrace ??????")
        }
        
        appendLogToFile(log: "\n<---Start-Install-unInstall-->\n")
        
        try? FileManager.default.moveItem(atPath: LKRoot.root_path! + "/daemon.call/pendingTrace", toPath: LKRoot.root_path! + "/daemon.call/pendingInstall")
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/pendingInstall/LKRTLPatchScript.sh")
        try? script_install.write(toFile: LKRoot.root_path! + "/daemon.call/pendingInstall/install.sh", atomically: true, encoding: .utf8)
        LKDaemonUtils.daemon_msg_pass(msg: "init:req:rtlInstall")
        while !FileManager.default.fileExists(atPath: LKRoot.root_path! + "/daemon.call/pendingInstall/Done") {
            if var read = try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/out.txt") {
                read += "."
                try? read.write(toFile: LKRoot.root_path! + "/daemon.call/out.txt", atomically: true, encoding: .utf8)
            }
            usleep(2333)
        }
        sleep(1) // Fix Permission
        try? FileManager.default.removeItem(atPath: LKRoot.root_path! + "/daemon.call/pendingInstall/Done")
        appendLogToFile(log: "Daemon returned!")
        appendLogToFile(log: (try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/pendingInstall/Done")) ?? "")
        
        appendLogToFile(log: "Saily::internal_session_finished::Signal")
        
    }
    
}
