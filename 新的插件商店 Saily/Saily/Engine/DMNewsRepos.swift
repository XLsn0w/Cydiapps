//
//  DMNewsRepos.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// MARK: RAM
class DMNewsRepo {
    
    var name                 = String()
    var link                 = String()
    var language             = [String]()
    var title                = String()
    var sub_title            = String()
    var icon                 = String()
    
    var title_color          = String()
    var subtitle_color       = String()
    
    var cards                = [DMNewsCard]()
    
}

// MARK: DATABASE
class DBMNewsRepo: WCDBSwift.TableCodable {
    
    var link: String?
    var content: String?
    var sort_id: Int?
    
    enum CodingKeys: String, CodingTableKey { // swiftlint:disable:next nesting
        typealias Root = DBMNewsRepo
        
        case link
        case content
        case sort_id
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                link: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
    
}
