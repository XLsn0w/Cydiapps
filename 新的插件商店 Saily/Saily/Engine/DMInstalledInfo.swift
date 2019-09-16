//
//  DMInstalledInfo.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/22.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

enum operation_type_t: String {
    case required_install       // Will Install
    case required_reinstall     // Will reinstall
    case required_remove        // Will remove
    case required_config        // Install failed, will need to reconfig
    case required_modify_dcrp   // Dependency Conflict Replace Provide
//    case required_purge_install // Fuck This Package And Remove Everythings Possible And Reinstall
    case auto_install           // Dependencies...
    case DNG_auto_remove        // Ask user before execute
    case unknown
}

// MARK: Current Info
enum current_info: String {
    case installed_ok
    case installed_bad
    case not_installed
    case unknown
}

struct dpkg_file {
    var filename: String
    var filepath: String
    var filemd5s: String
}



class DMOperationInfo {

    var priority: Int
    var package: DBMPackage
    var operation_type: operation_type_t
    var current_info: current_info
    
    var dowload: dld_info?
    
    init() {
        priority = 0
        package = DBMPackage()
        operation_type = .unknown
        current_info = .unknown
        fatalError("[E] DMOperationInfo 不允许被空初始化")
    }
    
    required init(pack: DBMPackage, operation: operation_type_t) {
        priority = 0
        package = pack
        operation_type = operation
        current_info = LKRoot.ins_common_operator.PAK_read_current_install_status(packID: pack.id)
    }
    
//    required init()
    
}

