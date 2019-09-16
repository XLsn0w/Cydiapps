//
//  DMCommon.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class common_data_handler {
    
}

extension common_data_handler {
    
    enum table_name: String {
        case LKSettings
        case LKNewsRepos
        case LKPackageRepos
        case LKPackages
        case LKRecentInstalled
        case LKRootLessInstalledTrace
    }
    
}

//
//struct Sileo_Depiction_Root: Codable {
//    
//    var minVersion: String
//    var headerImage: String
//    var tintColor: String
//    var tabs: [Sileo_Depiction_Tabs]
//    var backgroundColor: String
//    
//    private enum CodingKeys: String, CodingKey {
//        case minVersion
//        case headerImage
//        case tintColor
//        case tabs
//        case backgroundColor
//    }
//    
//}
//
//struct Sileo_Depiction_Tabs: Codable {
//    
//    var tabname: String
//    var views: [Sileo_Depiction_Views]
//    var orientation: String
//    var xPadding: String
//    
//    private enum CodingKeys: String, CodingKey {
//        case tabname
//        case views
//        case orientation
//        case xPadding
//    }
//    
//}
//
//struct Sileo_Depiction_Views: Codable {
//    // Bridging...
//}
//struct Sileo_Depiction_Views_Headers: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Subheaders: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Labels: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Markdown: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Videos: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Images: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Screenshots: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_TableText: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_TableButton: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Button: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Separator: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Spacer: Codable {
//    
//}
//
//// I don't want AdMob Integration :)
//
//struct Sileo_Depiction_Views_Ratings: Codable {
//    
//}
//
//struct Sileo_Depiction_Views_Reviews: Codable {
//    
//}
//
//enum Sileo_Depiction_Alignment: String, Codable {
//    case left
//    case center
//    case right
//}
//    
