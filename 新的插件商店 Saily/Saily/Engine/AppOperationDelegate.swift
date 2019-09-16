//
//  AppOperationDelegate.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/23.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

enum un_match_type_t: String {
    case depends
    case conflist
//    case replace
}

struct unMatched {
    let ID: String
    let type: un_match_type_t
    let dep: depends
}

class AppOperationDelegate {
    
    var operation_queue = [DMOperationInfo]()
    var unsolved_condition = [unMatched]()
    var unfired_download_req = [String : dld_info]()
    
    func printStatus() {
        print("--> 操作队列")
        for item in operation_queue {
            let name: String = item.package.id
            let curinfo: String = item.current_info.rawValue
            let to: String = item.operation_type.rawValue
            let p: String = String(item.priority)
            var printStr: String = "---> 软件包 - " + name
                printStr += "    " + curinfo
                printStr += " -> " + to
                printStr += " | " + p
            print(printStr)
        }
        for item in unsolved_condition {
            var printStr: String = "[*] ---> 未解决的问题 - " + item.ID
                printStr += " <-> " + item.dep.req.rawValue
                printStr += " " + item.dep.ver
            print(printStr)
        }
    }
    
    func add_install(pack: DBMPackage, required_install: Bool = true, printStatus: Bool = true) -> (operation_result, dld_info?) {
        
        // 校验软件包数据合法性
        if pack.version.count != 1 || pack.version.first!.value.count != 1 {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            return (.failed, nil)
        }
        
        guard let repolink = pack.version.first?.value.first?.key else {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            return (.failed, nil)
        }
        
        guard let filePath = pack.version.first?.value.first?.value["Filename".uppercased()] else {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            return (.failed, nil)
        }
        
        var exists = false
        for item in operation_queue where item.package.id == pack.id {
            exists = true
            break
        }
        var operation_info: DMOperationInfo?
        if !exists {
            if required_install {
                operation_info = DMOperationInfo(pack: pack, operation: .required_install)
                operation_queue.append(operation_info!)
            } else {
                operation_info = DMOperationInfo(pack: pack, operation: .auto_install)
                operation_queue.append(operation_info!)
            }
        } else if required_install {
            for item in operation_queue where item.package.id == pack.id {
                item.operation_type = .required_install // 升级了喵
                operation_info = item
                break
            }
        }
        
        if operation_info == nil {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "操作队列信息校验失败".localized())
            return (.failed, nil)
        }
        // 检查依赖并且添加
        if let dependStr = pack.version.first?.value.first?.value["DEPENDS"] {
            let checkResult = LKRoot.ins_common_operator.PAK_read_missing_dependency(dependStr: dependStr)
            inner: for missing_dep in checkResult {
                if let dep_package = LKRoot.container_packages[missing_dep.key] {
                    // 再次检查以免被内循环添加之后重复添加
                    for re_check in operation_queue where re_check.package.id == missing_dep.key {
                        // 内循环添加 跳过
                        continue inner
                    }
                    // 找到了软件包 接下来 处理软件包 只保留一个version
                    let _pack = dep_package.copy()
                    let targetVersion = LKRoot.ins_common_operator.PAK_read_newest_version(pack: _pack)
                    _pack.version.removeAll()
                    _pack.version[targetVersion.0] = [targetVersion.1.first?.key ?? "" : targetVersion.1.first?.value ?? ["" : ""]]
                    if add_install(pack: _pack, required_install: false, printStatus: false).0 == .failed {
                        // 添加失败 上报一个错误
                        let err = unMatched(ID: missing_dep.key, type: .depends, dep: missing_dep.value)
                        unsolved_condition.append(err)
                    }
                } else {
                    // 没找到软件包 既然没有那怎么可能出现在安装队列呢？
                    // 忽略所有的版本问题
                    if missing_dep.key == "firmware" {
                        continue inner
                    }
                    // 但是我们要先检查一下这个错误是不是已经被上报了
                    for reported in unsolved_condition where reported.ID == missing_dep.key {
                        // 已经被上报 不管要求怎样肯定不对 就先不管她了
                        continue inner
                    }
                    // 上报一个错误
                    let err = unMatched(ID: missing_dep.key, type: .depends, dep: missing_dep.value)
                    unsolved_condition.append(err)
                }
            }
        }
        
        if printStatus {
            self.printStatus()
        }
        
        
        var ret: (operation_result, dld_info?) = (operation_result.failed, nil)
        if unfired_download_req[pack.id] != nil {
            operation_info?.dowload = unfired_download_req[pack.id]
            operation_info?.dowload?.dlReq.resume()
            // 创建新的 unfired
            var new = [String : dld_info]()
            for item in unfired_download_req where item.key != pack.id {
                new[item.key] = item.value
            }
            unfired_download_req = new
            ret = (.success, operation_info?.dowload)
        } else {
            if let sha256 = pack.version.first?.value.first?.value["SHA256"] {
                ret = LKDaemonUtils.ins_download_delegate.submit_download(packID: pack.id, operation_info: operation_info!, fromRepo: repolink, networkPath: repolink + filePath, UA_required: true, sha256: sha256)
            } else {
                ret = LKDaemonUtils.ins_download_delegate.submit_download(packID: pack.id, operation_info: operation_info!, fromRepo: repolink, networkPath: repolink + filePath, UA_required: true, sha256: nil)
            }
        }
        return ret
        
    }
    
    func cancel_add_install(packID: String) {
        // 从 delegate 获取要安装的所有软件包
        var required_packages = [DBMPackage]()
        // 除了要被删除的软件包
        for item in operation_queue where item.package.id != packID && item.operation_type != .auto_install {
            required_packages.append(item.package)
        }
        // 这里是全部的需要的依赖 我们来看看撒
        var all_depens = [String : depends]()
        for item in required_packages {
            for dep in LKRoot.ins_common_operator.PAK_read_looped_depends(packID: item.id) {
                all_depens[dep.key] = dep.value
            }
        }
        // 既然我们之前已经处理过循环的依赖 我们现在就只处理
        var index = 0
        for obj in operation_queue { // 循环检查任务
            var should_go = false
            inner: for item in required_packages where item.id == obj.package.id {
                should_go = true
                break inner
            }
            inner: for item in all_depens where item.key == obj.package.id {
                should_go = true
                break inner
            }
            if should_go {
                index += 1
            } else {
                obj.dowload?.dlReq.suspend()
                unfired_download_req[obj.package.id] = obj.dowload
                operation_queue.remove(at: index)
            }
        }
        
        // 删除不存在的依赖 unmatched
        index = 0
        for item in unsolved_condition {
            if item.type == .depends {
                var exists = false
                inner: for required in all_depens where required.key == item.ID {
                    exists = true
                    break inner
                }
                if exists {
                    index += 1
                } else {
                    unsolved_condition.remove(at: index)
                }
            } else {
                index += 1
            }
        }
        printStatus()
    }
    
    func add_uninstall(pack: DBMPackage) -> (operation_result, String?) {
        
        let pack = pack.copy()
        let packID = pack.id
        // 从 delegate 获取要安装的所有软件包
        var required_packages = [DBMPackage]()
        for item in operation_queue where item.package.id != packID {
            required_packages.append(item.package)
        }
        for item in LKRoot.container_recent_installed where item.version.first?.value.first?.value["DEPENDS"] != nil {
            required_packages.append(item)
        }
        // 这里是全部的需要的依赖 我们来看看撒
        var all_depens = [String : depends]()
        for item in required_packages {
            for dep in LKRoot.ins_common_operator.PAK_read_looped_depends(packID: item.id, read_all: true) {
                all_depens[dep.key] = dep.value
            }
        }
        // 如果依赖中包含了这个玩意 那就返回错误
        for item in all_depens where item.key == packID {
            return (.failed, item.key)
        }
        
        let operation = DMOperationInfo(pack: pack, operation: .required_remove)
        LKDaemonUtils.ins_operation_delegate.operation_queue.append(operation)
        
        return (.success, nil)
    }
    
    func add_reinstall(pack: DBMPackage) -> (operation_result, dld_info?) {
        
        // 校验软件包数据合法性
        if pack.version.count != 1 || pack.version.first!.value.count != 1 {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            return (.failed, nil)
        }
        
        guard let repolink = pack.version.first?.value.first?.key else {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            return (.failed, nil)
        }
        
        guard let filePath = pack.version.first?.value.first?.value["Filename".uppercased()] else {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包信息校验失败，请尝试刷新。".localized())
            return (.failed, nil)
        }
        
        var exists = false
        for item in operation_queue where item.package.id == pack.id {
            exists = true
            break
        }
        var operation_info: DMOperationInfo?
        if !exists {
            operation_info = DMOperationInfo(pack: pack, operation: .required_reinstall)
        } else {
            return (.failed, nil)
        }
        
        if operation_info == nil {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "操作队列信息校验失败".localized())
            return (.failed, nil)
        }
        operation_queue.append(operation_info!)
        // 不需要检查依赖哟 因为是重新安装
        printStatus()
        var ret: (operation_result, dld_info?) = (operation_result.failed, nil)
        if unfired_download_req[pack.id] != nil {
            operation_info?.dowload = unfired_download_req[pack.id]
            operation_info?.dowload?.dlReq.resume()
            // 创建新的 unfired
            var new = [String : dld_info]()
            for item in unfired_download_req where item.key != pack.id {
                new[item.key] = item.value
            }
            unfired_download_req = new
            ret = (.success, operation_info?.dowload)
        } else {
            if let sha256 = pack.version.first?.value.first?.value["SHA256"] {
                ret = LKDaemonUtils.ins_download_delegate.submit_download(packID: pack.id, operation_info: operation_info!, fromRepo: repolink, networkPath: repolink + filePath, UA_required: true, sha256: sha256)
            } else {
                ret = LKDaemonUtils.ins_download_delegate.submit_download(packID: pack.id, operation_info: operation_info!, fromRepo: repolink, networkPath: repolink + filePath, UA_required: true, sha256: nil)
            }
        }
        operation_info?.dowload = ret.1
        return ret
        
    }
    
}

