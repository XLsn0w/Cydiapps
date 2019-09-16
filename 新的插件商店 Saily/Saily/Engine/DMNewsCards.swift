//
//  DMNewsCards.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// 卡片的 KEY 使用随机生成的 UUID
// 是主键，具有唯一性。

// MARK: RAM
class DMNewsCard {
    
    var type: card_type                     = .photo_full
    
    var content: String?                    = String()
    
    var image_container                     = [String]()
    
    var main_title_string                   = String()
    var sub_title_string:       String?
    var last_update_string:     String?
    var description_string:     String?
    
    var main_title_string_color             = String()
    var sub_title_string_color              = String()
    var last_update_string_color            = String()
    var description_string_color            = String()
    
}

// 卡片不予以缓存本地
