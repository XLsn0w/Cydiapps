//
//  ColorSheetCommon.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/28.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//



class color_sheet {
    
    var current_color_sheet: color_sheet_id = .light
    
    enum color_sheet_id: Int {
        case light = 0x00
        case dark_blue = 0x10
    }
    
    func reFit() {
        if LKRoot.settings?.use_dark_mode ?? false {
            current_color_sheet = .dark_blue
        } else {
            current_color_sheet = .light
        }
    }
    
    func read_a_color(_ which: String) -> UIColor {
        switch current_color_sheet {
        case .light:
            guard let ret = CS_light[which] else {
                return .black
            }
            return ret
        case .dark_blue:
            guard let ret = CS_dark_blue[which] else {
                return .black
            }
            return ret
//        default:
//            print("[***] 还没写实现，赶紧补一下吧。")
        }
//        return .black
    }
 
    let CS_light = [
        
        "DARK_ENABLED"                  : .clear,
        
        "main_tint_color"               : #colorLiteral(red: 0, green: 0.729731217, blue: 0.893548429, alpha: 1),    // UIColor(hex: 0x0AAADD),
        
        "tabbar_untint"                 : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),    // UIColor(hex: 0x999999),
        "tabbar_background"             : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),    // UIColor(hex: 0xFFFFFF),
        
        "table_view_title"              : #colorLiteral(red: 0.4117647059, green: 0.4117647059, blue: 0.4117647059, alpha: 1),    // UIColor(hex: 0x696969),
        "table_view_link"               : #colorLiteral(red: 0.6677469611, green: 0.6677629352, blue: 0.6677542925, alpha: 1),    // UIColor(hex: 0x9A9A9A),
        
        "main_background"               : #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1),    // UIColor(hex: 0xFFFFFF),
        
        "main_operations_attention"     : #colorLiteral(red: 1, green: 0.4896141291, blue: 0.4700677395, alpha: 1),    // UIColor(hex: 0xFF6565),
        "main_operations_allow"         : #colorLiteral(red: 0, green: 0.8103328347, blue: 0.3696507514, alpha: 1),    // UIColor(hex: 0x0AC94C),
        "main_title_one"                : #colorLiteral(red: 0.2860272825, green: 0.611161828, blue: 1, alpha: 1),    // UIColor(hex: 0x3B86FF),
        "main_title_two"                : #colorLiteral(red: 0.6999540329, green: 0.7014504075, blue: 0.9883304238, alpha: 1),    // UIColor(hex: 0xA3A0FB),
        "main_title_three"              : #colorLiteral(red: 0.3324531913, green: 0.3323239088, blue: 0.4404206276, alpha: 1),    // UIColor(hex: 0x43425D),
        "main_title_four"               : #colorLiteral(red: 0.9294117647, green: 0.6274509804, blue: 0.9843137255, alpha: 1),    // UIColor(hex: 0xEDA0FB),
        
        "main_text"                     : #colorLiteral(red: 0.3324531913, green: 0.3323239088, blue: 0.4404206276, alpha: 1),    // UIColor(hex: 0x43425D),
        "sub_text"                      : #colorLiteral(red: 0.739910701, green: 0.7917402324, blue: 0.8039215803, alpha: 1),    // UIColor(hex: 0xBDCACD),
        
        "button_tint_color"             : #colorLiteral(red: 0, green: 0.7235050797, blue: 0.893548429, alpha: 1),    // UIColor(hex: 0x0AAADD),
        "button_touched_color"          : #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1),    // UIColor(hex: 0xA9A9A9),
        
        "submain_title_one"             : #colorLiteral(red: 0.6677469611, green: 0.6677629352, blue: 0.6677542925, alpha: 1),    // UIColor(hex: 0x9A9A9A),
        "shadow"                        : #colorLiteral(red: 0.6677469611, green: 0.6677629352, blue: 0.6677542925, alpha: 1),    // UIColor(hex: 0x9A9A9A),
        "icon_ring_tint"                : #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)     // UIColor(hex: 0xFFFFFF),
    ]
    
    let CS_dark_blue = [
        
        "DARK_ENABLED"                  : .black,
        
        "main_tint_color"               : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),    // UIColor(hex: 0x0AAADD),
        
        "tabbar_untint"                 : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),    // UIColor(hex: 0x41464D),
        "tabbar_background"             : #colorLiteral(red: 0.01888785272, green: 0.05792274944, blue: 0.07932898116, alpha: 1),    // UIColor(hex: 0x050F14),
        
        "table_view_title"              : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),    // UIColor(hex: 0xFFFFFF),
        "table_view_link"               : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),    // UIColor(hex: 0xFFFFFF),
        
        "main_background"               : #colorLiteral(red: 0.01888785272, green: 0.05792274944, blue: 0.07932898116, alpha: 1),    // UIColor(hex: 0x050F14),
        
        "main_operations_attention"     : #colorLiteral(red: 1, green: 0.6846027185, blue: 0.6725238611, alpha: 1),    // UIColor(hex: 0xFF6565),
        "main_operations_allow"         : #colorLiteral(red: 0.4886365964, green: 0.8103328347, blue: 0.6353852546, alpha: 1),    // UIColor(hex: 0x0AC94C),
        "main_title_one"                : #colorLiteral(red: 0.6019103168, green: 0.7831955467, blue: 1, alpha: 1),    // UIColor(hex: 0x3B86FF),
        "main_title_two"                : #colorLiteral(red: 0.7969101558, green: 0.7979034286, blue: 0.9883304238, alpha: 1),    // UIColor(hex: 0xA3A0FB),
        "main_title_three"              : #colorLiteral(red: 0.7168041425, green: 0.7165253958, blue: 0.9495933219, alpha: 1),    // UIColor(hex: 0x43425D),
        "main_title_four"               : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),    // UIColor(hex: 0x43425D),
        
        "main_text"                     : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),    // UIColor(hex: 0xFFFFFF),
        "sub_text"                      : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),    // UIColor(hex: 0xFFFFFF),
        
        "button_tint_color"             : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),    // UIColor(hex: 0x0AAADD),
        "button_touched_color"          : #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),    // UIColor(hex: 0xA9A9A9),
        
        "submain_title_one"             : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),    // UIColor(hex: 0x9A9A9A),
        "shadow"                        : .clear,
        "icon_ring_tint"                : #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)     // UIColor(hex: 0xFFFFFF),
    ]
    
    
}
