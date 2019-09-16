//
//  CardTypeControl.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

enum card_type: Int {
    
    case photo_full                             = 0x101
    case photo_full_with_banner_down_dark       = 0x102
    case photo_half_with_banner_down_light      = 0x111
    
    case river_view_animate                     = 0x201
    case river_view_static                      = 0x202
    
    // switch default 警告消除者
    case what_the_fuck_is_this                  = 0x666
}

enum card_detail_type: Int {
    
    case text                                   = 0x101
    case text_inherit_saying                    = 0x102
    case photo                                  = 0x201
    case photo_with_description                 = 0x202
    case news_repo                              = 0x301
    case package_repo                           = 0x302
    case package                                = 0x303
    
    // PRIVATE API - DO NOT USE IT PPPPLLLLEEEEAAAASSSSEEEE :P XD
    case LKPrivateAPI_RESVERED                  = 0x580
    case LKPrivateAPI_darkModeSwitcher          = 0x601
    case LKPrivateAPI_setting_page              = 0x620
    
}

