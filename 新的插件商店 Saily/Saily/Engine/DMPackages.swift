//
//  DMPackages.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/14.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//


// MARK: DATABASE
class DBMPackage: WCDBSwift.TableCodable {
    
    var id = String()
    var latest_update_time = String()
    var one_of_the_package_name_lol = String()
    var one_of_the_package_section_lol = String()
    // 版本容器包含了 【版本号 ： 【软件源地址 ： 【属性 ： 属性值】】】
    var version = [String : [String : [String : String]]]()
    var signal = String()
    
    var status: String = current_info.unknown.rawValue
    
    enum CodingKeys: String, CodingTableKey { // swiftlint:disable:next nesting
        typealias Root = DBMPackage
        
        case id
        case latest_update_time
        case one_of_the_package_name_lol
        case one_of_the_package_section_lol
        case version
        case signal
        case status
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
    
    
    // 我可真去你大爷的
    func copy() -> DBMPackage {
        
        let ret = DBMPackage()
        ret.id = self.id
        ret.latest_update_time = self.latest_update_time
        ret.one_of_the_package_name_lol = self.one_of_the_package_name_lol
        ret.version = self.version
        ret.signal = self.signal
        ret.status = self.status
        return ret
        
    }
    
}

