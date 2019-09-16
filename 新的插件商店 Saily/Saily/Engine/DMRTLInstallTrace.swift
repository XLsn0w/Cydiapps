//
//  DMRTLInstallTrace.swift
//  Saily
//
//  Created by Lakr Aream on 2019/9/12.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// MARK: DATABASE
class DMRTLInstallTrace: WCDBSwift.TableCodable {
    
    var id: String?
    var list: [String]?
    var time: String?
    var usedDPKG: Bool?
    
    enum CodingKeys: String, CodingTableKey { // swiftlint:disable:next nesting
        typealias Root = DMRTLInstallTrace
        
        case id
        case list
        case time
        case usedDPKG
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isUnique: true)
            ]
        }
    }
    
    
}

