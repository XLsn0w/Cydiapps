//
//  OperatorGetPackageInfo.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/14.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

enum dependReq: String {
    case biggerThen
    case smallerThen
    case BiggerOrEqualThen
    case smallerOrEqualThen
    case equal
    case any
}

struct depends {
    var req: dependReq
    var ver: String
}

extension app_opeerator {
    
    func PAK_read_name(version: [String : [String : String]]) -> String {
        let name = version.first?.value["NAME"] ?? version.first?.value["PACKAGE"] ?? ""
        if name.hasSuffix("for ShortLook") {
            return name.dropLast("for ShortLook".count).to_String()
        }
        return name
    }
    
    func PAK_read_auth_name(version: [String : [String : String]]) -> String {
        let name = version.first?.value["AUTHOR"] ?? version.first?.value["PACKAGE"] ?? ""
        if name.hasSuffix("for ShortLook") {
            return name.dropLast("for ShortLook".count).to_String()
        }
        return name
    }
    
    // 返回 名字 + 📧
    func PAK_read_auth(version: [String : [String : String]]) -> (String, String) {
        let v = version.first?.value["AUTHOR"]
        if v != nil && v != "" {
            if v!.contains("<") && v!.contains("@") && v!.contains(">") {
                let ret = v!.split(separator: "<").first?.to_String().drop_space() ?? "没有作者信息".localized()
                // 尝试获取email
                let some = v!.split(separator: "<").last?.split(separator: ">").last?.to_String().drop_space() ?? ""
                return (ret, some)
            }
            return (v!, "")
        }
        return ("没有作者信息".localized(), "")
    }
    
    func PAK_read_description(version: [String : [String : String]]) -> String {
        return version.first?.value["DESCRIPTION"] ?? ""
    }
    
    func PAK_read_icon_addr(version: [String : [String : String]]) -> String {
        return version.first?.value["ICON"] ?? ""
    }
    
    func PAK_read_newest_version(pack: DBMPackage) -> (String, [String : [String : String]]) {
        // 先获得全部 version 的数组
        var vers = [String]()
        for item in pack.version where PAK_internal_sig_check_did_pass(object: item.value) {
            vers.append(item.key)
        }
        let newest = version_cmp(vers: vers)
        return (newest, (pack.version[newest] ?? PAK_return_error_vision()))
    }
    
    func PAK_return_error_vision() -> [String : [String : String]] {
        return ["-1" : ["PACKAGE" : "错误的软件包识别码".localized(),
                        "NAME" : "未知错误".localized(),
                        "DESCRIPTION" : "在获取这个软件包时出现了意外错误。".localized(),
                        "ICON" : "NAMED:Error"]]
    }
    
    func PAK_versions_sort(versions: [String : [String : [String : String]]]) -> [String] {
        // 取出所有版本号
        var versionNum = [String]()
        for item in versions where PAK_internal_sig_check_did_pass(object: item.value) {
            versionNum.append(item.key)
        }
        // 校验数据合法性
        if versionNum.count < 2 {
            return versionNum
        }
        for v1 in 0..<versionNum.count {
            for v2 in v1..<(versionNum.count - 1) {
                if versionNum[v2] == version_cmp(vers: [versionNum[v2], versionNum[v2 + 1]]) {
                    versionNum.swapAt(v2, v2 + 1)
                }
            }
        }
        return versionNum
        
    }
    
    func PAK_internal_sig_check_did_pass(object: [String : [String : String]]) -> Bool {
        for item in object.values where item["_internal_SIG_begin_update"] != "0x1" {
            return false
        }
        return true
    }
    
    func PAK_read_current_install_status(packID: String) -> current_info {
        if let pack = LKRoot.container_packages_installed_DBSync[packID] {
            // 已经安装
            return current_info(rawValue: pack.status) ?? current_info.unknown
        }
        if LKRoot.container_packages[packID] != nil {
            return .not_installed
        }
        return .unknown
    }
    
    func PAK_read_current_download_info(packID: String) -> dld_info? {
        return LKDaemonUtils.ins_download_delegate.query_download_info(packID: packID).1
    }
    
    func PAK_read_all_dependency(dependStr: String) -> [String : depends] {
        
        if LKRoot.isRootLess {
            print("[R] PAK_read_looped_depends")
            return [:]
        }
        
        var ret = [String : depends]()
        
        // I'm fucking done with this kinds of depends.
        // 🦙 太难写了我放弃了
        // [11] = (key = "DEPENDS", value = "com.abcydia.anemone | com.abcydia.anemone3 | com.abcydia.anemone | com.anemonetheming.anemone | com.anemonetheming.anemone3 | com.spark.snowboard | com.abcydia.snowboard")
        
        inner: for item in dependStr.split(separator: ",") where !item.contains("|") {
            let itemStr = item.to_String().drop_space()
            if itemStr.contains("(") && itemStr.contains(")") {
                if let name = itemStr.split(separator: "(").first?.to_String().drop_space() {
                    let ver = itemStr.split(separator: "(").last?.split(separator: ")").first?.to_String()
                    let verstr = ver?.split(separator: " ").last?.to_String() ?? "0"
                    if YA_package_in_exclude_list(id: name) {
                        continue inner
                    }
                    if ver?.hasPrefix("=") ?? false {
                        ret[name] = depends(req: .equal, ver: verstr)
                    } else if ver?.hasPrefix(">=") ?? false {
                        ret[name] = depends(req: .BiggerOrEqualThen, ver: verstr)
                    } else if ver?.hasPrefix(">") ?? false {
                        ret[name] = depends(req: .biggerThen, ver: verstr)
                    } else if ver?.hasPrefix("<=") ?? false {
                        ret[name] = depends(req: .smallerOrEqualThen, ver: verstr)
                    } else if ver?.hasPrefix("<") ?? false {
                        ret[name] = depends(req: .smallerThen, ver: verstr)
                    } else {
                        ret[name] = depends(req: .any, ver: verstr)
                    }
                }
            } else {
                if YA_package_in_exclude_list(id: itemStr) {
                    continue inner
                }
                ret[itemStr] = depends(req: .any, ver: "0")
            }
        }
        var lowRet = [String : depends]()
        for item in ret {
            lowRet[item.key.lowercased()] = item.value
        }
        return lowRet
    }
    
    func PAK_read_looped_depends(packID: String, read_all: Bool = false, checkQueue: Bool = false, loopBreaker: [String : depends] = [:], loopDeepth: Int = 0) -> [String : depends] {
        
        if LKRoot.isRootLess {
            print("[R] PAK_read_looped_depends")
            return [:]
        }
        
        var ret = loopBreaker
        if loopDeepth > 2333 {
            // 退出可能的死循环
            return ret
        }
        if let depstr = LKRoot.container_packages[packID]?.version.first?.value.first?.value["DEPENDS"] {
            var deps = [String : depends]()
            if read_all {
                deps = PAK_read_all_dependency(dependStr: depstr)
            } else {
                deps = PAK_read_missing_dependency(dependStr: depstr, checkQueue: checkQueue)
            }
            // 在迷失的先决条件内排出已经被循环搜索的依赖
            for item in deps where ret[item.key] == nil {
                ret[item.key] = item.value
                for rets in PAK_read_looped_depends(packID: item.key, read_all: read_all, loopBreaker: ret, loopDeepth: loopDeepth + 1) where ret[rets.key] == nil {
                    ret[rets.key] = rets.value
                }
            }
        }
        
        return ret
    }

    func PAK_read_missing_dependency(dependStr: String, checkQueue: Bool = true) -> [String : depends] {
        
        if LKRoot.isRootLess {
            print("[R] PAK_read_looped_depends")
            return [:]
        }
        
        var ret = [String : depends]()
        let required = PAK_read_all_dependency(dependStr: dependStr)
        inner: for item in required {
            if LKRoot.container_installed_provides[item.key] != nil {
                // It was kind of tricky but we go back here to finish the rest of it.
                // let stru = LKRoot.container_installed_provides[item.key]
                continue inner
            } else {
                for install_queued in LKDaemonUtils.ins_operation_delegate.operation_queue where install_queued.package.id == item.key && checkQueue {
                    continue inner
                }
                ret[item.key] = item.value
            }
        }
        return ret
    }
    
//    func PAK_read_all_conflict(conflictStr: String) -> [String] {
//        
//    }
//    
//    func PAK_read_happened_conflict(conflictStrs: [String]) -> [String] {
//        
//    }
//    
//    func PAK_read_all_replace(conflictStr: String) -> [String] {
//        
//    }
//    
//    func PAK_read_happened_replace(conflictStrs: [String]) -> [String] {
//        
//    }
    
    func PAK_read_all_provides(provideStr: String) -> [String : String?] {
        var ret = [String : String?]()
        // Provides: org.thebigboss.libcolorpicker, org.thebigboss.libcolorpicker (= 1.6.1), libapt-pkg (= 1.4.8)
        for item in provideStr.split(separator: ",") {
            let itemStr = item.to_String().drop_space()
            if itemStr.contains("(") && itemStr.contains(")") {
                if let name = itemStr.split(separator: "(").first?.to_String().drop_space() {
                    let ver = itemStr.split(separator: "(").last?.split(separator: ")").first?.split(separator: "=").last?.to_String().drop_space()
                    ret[name] = ver
                }
            } else {
                ret[itemStr] = nil
            }
        }
        return ret
    }
}
