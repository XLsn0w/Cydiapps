//
//  DMPackageRepos.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/11.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// MARK: RAM
class DMPackageRepos {
    
    var name                 = String()
    var link                 = String()
    var icon                 = String()
    var desstr               = String()
    var sort_ID              = Int()
    
    var item                 = [String : String]()
    
    func to_data_base() -> DBMPackageRepos {
        let new = DBMPackageRepos()
        new.name = name
        new.link = link
        new.icon = icon
        new.sort_id = sort_ID
        return new
    }
}

// MARK: DATABASE
class DBMPackageRepos: WCDBSwift.TableCodable {
    
    var name: String?
    var link: String?
    var icon: String?
    var sort_id: Int?
    
    enum CodingKeys: String, CodingTableKey { // swiftlint:disable:next nesting
        typealias Root = DBMPackageRepos
        
        case name 
        case link 
        case icon 
        case sort_id 
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                link: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
    
}
