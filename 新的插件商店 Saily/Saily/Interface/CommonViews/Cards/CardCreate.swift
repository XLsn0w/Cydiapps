//
//  CardCreate.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/30.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class UICardView: UIView {
    
    var top_insert: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("???")
    }
    
}

extension common_views {
    
    func NRCD_create_card(info: DMNewsCard, should_border_if_dark: Bool) -> UICardView {
        let ret = UICardView()
        ret.clipsToBounds = true
        let top_v_insert = UIView()
        ret.addSubview(top_v_insert)
        top_v_insert.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        ret.top_insert = top_v_insert
        switch info.type {
        case .photo_full:
            do {
                // 图片底
                if let image_url = URL(string: info.image_container.first ?? "") {
                    let bg = UIImageView()
                    bg.sd_setImage(with: image_url, placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
                    bg.contentMode = .scaleAspectFill
                    bg.clipsToBounds = true
                    
                    ret.addSubview(bg)
                    bg.snp.makeConstraints { (x) in
                        x.edges.equalTo(ret.snp.edges)
                    }
                } else {
                    let bg = UIView()
                    bg.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                    ret.addSubview(bg)
                    bg.snp.makeConstraints { (x) in
                        x.edges.equalTo(ret.snp.edges)
                    }
                    
                }
                // 俩标题
                let sub_title = UILabel(text: info.sub_title_string)
                sub_title.font = .boldSystemFont(ofSize: 12)
                if let color = UIColor(hexString: info.sub_title_string_color) {
                    sub_title.textColor = color
                } else {
                    sub_title.textColor = .white
                }
                let title = UILabel(text: info.main_title_string)
                title.font = .boldSystemFont(ofSize: 22)
                if let color = UIColor(hexString: info.main_title_string) {
                    title.textColor = color
                } else {
                    title.textColor = .white
                }
                ret.addSubview(sub_title)
                ret.addSubview(title)
                sub_title.snp.makeConstraints { (x) in
                    x.top.equalTo(top_v_insert.snp.bottom).offset(18)
                    x.left.equalTo(ret.snp.left).offset(18)
                }
                title.snp.makeConstraints { (x) in
                    x.top.equalTo(sub_title.snp.bottom).offset(2)
                    x.left.equalTo(sub_title.snp.left).offset(0)
                }
                // 底下的文字
                let des_str = UITextView()
                des_str.text = info.description_string
                des_str.font = .boldSystemFont(ofSize: 12)
                des_str.isUserInteractionEnabled = false
                des_str.backgroundColor = .clear
                if let color = UIColor(hexString: info.description_string_color) {
                    des_str.textColor = color
                } else {
                    des_str.textColor = .white
                }
                
                ret.addSubview(des_str)
                des_str.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left).offset(18)
                    x.right.equalTo(ret.snp.right).offset(-18)
                    x.bottom.equalTo(ret.snp.bottom).offset(-18)
                    x.height.equalTo(48)
                }
            }
        case .photo_half_with_banner_down_light:
            do {
                
                if (LKRoot.settings?.use_dark_mode ?? false) && should_border_if_dark {
                    ret.borderWidth = 1
                    ret.borderColor = .gray
                }
                
                ret.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
                // 底下的文字
                let des_str = UILabel()
                des_str.text = info.description_string
                des_str.font = .boldSystemFont(ofSize: 12)
                if let color = UIColor(hexString: info.description_string_color) {
                    des_str.textColor = color
                } else {
                    des_str.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
                }
                
                ret.addSubview(des_str)
                des_str.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left).offset(18)
                    x.right.equalTo(ret.snp.right).offset(-18)
                    x.bottom.equalTo(ret.snp.bottom).offset(-12)
                    x.height.equalTo(18)
                }
                // 俩标题
                let sub_title = UILabel(text: info.sub_title_string)
                sub_title.font = .boldSystemFont(ofSize: 12)
                if let color = UIColor(hexString: info.sub_title_string_color) {
                    sub_title.textColor = color
                } else {
                    sub_title.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
                }
                let title = UITextView()
                title.text = info.main_title_string
                title.isUserInteractionEnabled = false
                title.font = .boldSystemFont(ofSize: 26)
                title.backgroundColor = .clear
                if let color = UIColor(hexString: info.main_title_string) {
                    title.textColor = color
                } else {
                    title.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
                }
                title.textContainer.maximumNumberOfLines = 2
                title.textContainer.lineBreakMode = .byWordWrapping
                ret.addSubview(sub_title)
                ret.addSubview(title)
                sub_title.snp.makeConstraints { (x) in
                    x.bottom.equalTo(title.snp.top).offset(-4)
                    x.left.equalTo(ret.snp.left).offset(18)
                    x.height.equalTo(18)
                }
                title.snp.makeConstraints { (x) in
                    x.bottom.equalTo(des_str.snp.top).offset(-4)
                    x.left.equalTo(ret.snp.left).offset(12)
                    x.right.equalTo(ret.snp.right).offset(-12)
                    x.height.equalTo(75)
                }
                // 图片底
                if let image_url = URL(string: info.image_container.first ?? "") {
                    let bg = UIImageView()
                    bg.sd_setImage(with: image_url, placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
                    bg.contentMode = .scaleAspectFill
                    bg.clipsToBounds = true
                    ret.addSubview(bg)
                    bg.snp.makeConstraints { (x) in
                        x.top.equalTo(ret.snp.top)
                        x.left.equalTo(ret.snp.left)
                        x.bottom.equalTo(sub_title.snp.top).offset(-18)
                        x.right.equalTo(ret.snp.right)
                    }
                } else {
                    let bg = UIView()
                    bg.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                    ret.addSubview(bg)
                    bg.snp.makeConstraints { (x) in
                        x.top.equalTo(ret.snp.top)
                        x.left.equalTo(ret.snp.left)
                        x.bottom.equalTo(ret.snp.centerY).offset(28)
                        x.right.equalTo(ret.snp.right)
                    }
                    
                }
            }
        case .photo_full_with_banner_down_dark:
            do {
                // 图片底
                if let image_url = URL(string: info.image_container.first ?? "") {
                    let bg = UIImageView()
                    bg.sd_setImage(with: image_url, placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
                    bg.contentMode = .scaleAspectFill
                    bg.clipsToBounds = true
                    ret.addSubview(bg)
                    bg.snp.makeConstraints { (x) in
                        x.edges.equalTo(ret.snp.edges)
                    }
                } else {
                    let bg = UIView()
                    bg.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                    ret.addSubview(bg)
                    bg.snp.makeConstraints { (x) in
                        x.edges.equalTo(ret.snp.edges)
                    }
                    
                }
                // 黑色底
                let dummy = UIView()
                dummy.backgroundColor = .black
                dummy.alpha = 0.75
                ret.addSubview(dummy)
                dummy.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left)
                    x.right.equalTo(ret.snp.right)
                    x.bottom.equalTo(ret.snp.bottom)
                    x.height.equalTo(98)
                }
                // 俩标题
                let sub_title = UILabel(text: info.sub_title_string)
                sub_title.font = .boldSystemFont(ofSize: 12)
                if let color = UIColor(hexString: info.sub_title_string_color) {
                    sub_title.textColor = color
                } else {
                    sub_title.textColor = .white
                }
                let title = UILabel(text: info.main_title_string)
                title.font = .boldSystemFont(ofSize: 22)
                if let color = UIColor(hexString: info.main_title_string) {
                    title.textColor = color
                } else {
                    title.textColor = .white
                }
                ret.addSubview(sub_title)
                ret.addSubview(title)
                sub_title.snp.makeConstraints { (x) in
                    x.top.equalTo(dummy.snp.top).offset(18)
                    x.left.equalTo(ret.snp.left).offset(18)
                }
                title.snp.makeConstraints { (x) in
                    x.top.equalTo(sub_title.snp.bottom).offset(2)
                    x.left.equalTo(sub_title.snp.left).offset(0)
                }
                // 底下的文字
                let des_str = UILabel()
                des_str.text = info.description_string
                des_str.font = .boldSystemFont(ofSize: 12)
                if let color = UIColor(hexString: info.description_string_color) {
                    des_str.textColor = color
                } else {
                    des_str.textColor = .gray
                }
                
                ret.addSubview(des_str)
                des_str.snp.makeConstraints { (x) in
                    x.left.equalTo(ret.snp.left).offset(18)
                    x.right.equalTo(ret.snp.right).offset(-18)
                    x.top.equalTo(title.snp.bottom).offset(2)
                }
            }
        case .river_view_static, .river_view_animate:
            do {
                
                if (LKRoot.settings?.use_dark_mode ?? false) && should_border_if_dark {
                    ret.borderWidth = 1
                    ret.borderColor = .gray
                }
                
                ret.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
                // 俩标题
                let sub_title = UILabel(text: info.sub_title_string)
                sub_title.font = .boldSystemFont(ofSize: 12)
                if let color = UIColor(hexString: info.sub_title_string_color) {
                    sub_title.textColor = color
                } else {
                    sub_title.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
                }
                let title = UITextView()
                title.text = info.main_title_string
                title.isUserInteractionEnabled = false
                title.font = .boldSystemFont(ofSize: 26)
                title.backgroundColor = .clear
                if let color = UIColor(hexString: info.main_title_string) {
                    title.textColor = color
                } else {
                    title.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
                }
                title.textContainer.maximumNumberOfLines = 2
                title.textContainer.lineBreakMode = .byWordWrapping
                ret.addSubview(sub_title)
                ret.addSubview(title)
                sub_title.snp.makeConstraints { (x) in
                    x.top.equalTo(top_v_insert.snp.bottom).offset(18)
                    x.left.equalTo(ret.snp.left).offset(18)
                }
                title.snp.makeConstraints { (x) in
                    x.top.equalTo(sub_title.snp.bottom).offset(0)
                    x.left.equalTo(sub_title.snp.left).offset(-4)
                    x.right.equalTo(ret.snp.right).offset(-14)
                    x.height.equalTo(42)
                }
                // 创建ASMultiAppsRiver
                var animate_request = false
                if info.type == .river_view_animate {
                    animate_request = true
                }
                let new_river = ASMultiAppsView()
                new_river.apart_init(card_width: 333, card_hight: 188,
                                     images: info.image_container,
                                     animate: animate_request,
                                     image_width: 88, image_hight: 88,
                                     image_angle: -23.33,
                                     image_gap: 20, image_radius: 14)
                let river_holder = UIView()
                river_holder.clipsToBounds = true
                ret.addSubview(river_holder)
                river_holder.addSubview(new_river)
                river_holder.snp.makeConstraints { (x) in
                    x.top.equalTo(title.snp.bottom).offset(18)
                    x.left.equalTo(ret.snp.left)
                    x.right.equalTo(ret.snp.right)
                    x.bottom.equalTo(ret.snp.bottom)
                }
                new_river.snp.makeConstraints { (x) in
                    x.top.equalTo(river_holder.snp.top)
                    x.left.equalTo(river_holder.snp.left)
                    x.right.equalTo(river_holder.snp.right)
                    x.bottom.equalTo(river_holder.snp.bottom)
                }
                
            }
        default:
            print("[*] 这啥玩意哦？")
        }
        return ret
    }
    
}
