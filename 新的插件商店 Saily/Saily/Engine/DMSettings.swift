//
//  DMSettings.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// MARK: RAM
// 不要啊啊啊啊啊啊啊

// MARK: DATABASE
class DBMSettings: WCDBSwift.TableCodable {
    
    var fake_UDID: String?
    var real_UDID: String?
    
    var use_dark_mode = false
    
    var network_timeout: Int?
    var card_radius: Int = 8
    
    enum CodingKeys: String, CodingTableKey { // swiftlint:disable:next nesting
        typealias Root = DBMSettings
        
        case fake_UDID 
        case real_UDID 
        case network_timeout 
        case card_radius
        case use_dark_mode
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
    }
    
    func readUDID() -> String {
        if real_UDID != nil {
            return real_UDID!
        }
        return fake_UDID ?? UUID().uuidString
    }
    
}
