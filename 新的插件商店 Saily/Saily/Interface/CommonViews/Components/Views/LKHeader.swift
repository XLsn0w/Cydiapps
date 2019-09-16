//
//  UIHommyView.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/28.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension common_views {
    
    func create_AS_home_header_view(title_str: String, sub_str: String, image_str: String, sep_enabled: Bool = true) -> UIView {
                                                    // 创建 View
        let ret_view = UIView()
        let sub_title = UILabel()
        let main_title = UILabel()
        let head_icon = UIImageView()
        let seperator = UIView()
        ret_view.addSubview(sub_title)
        ret_view.addSubview(main_title)
        ret_view.addSubview(head_icon)
        if sep_enabled {
            ret_view.addSubview(seperator)
        }
                                                    // 写入内容
        var sub_title_text = sub_str
        
        if sub_str == "LKSIG-DATE" {
            sub_title_text = ""
            // 获取日期
            let today = Date()
            let formatter = DateFormatter()
            // 获取MM
            formatter.dateFormat = "M"
            sub_title_text = formatter.string(from: today) + "月".localized()
            // 获取DD
            formatter.dateFormat = "dd"
            sub_title_text += formatter.string(from: today) + "日".localized() + " "
            // 写日期到副标题
            formatter.dateFormat = "EEE"
            sub_title_text += formatter.string(from: today).localized()
        }

        sub_title.text = sub_title_text
        sub_title.textColor = LKRoot.ins_color_manager.read_a_color("submain_title_one")
        sub_title.font = .boldSystemFont(ofSize: 13)
        sub_title.snp.makeConstraints { (x) in
            x.top.equalTo(ret_view.snp.top).offset(28)
            x.left.equalTo(ret_view.snp.left).offset(23)
            x.right.equalTo(ret_view.snp.right).offset(-28)
            x.height.equalTo(18)
        }
        
        
        main_title.text = title_str.localized()
        main_title.textColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        main_title.font = .boldSystemFont(ofSize: 34)
        main_title.snp.makeConstraints { (x) in
            x.top.equalTo(sub_title.snp.bottom).offset(0)
            x.left.equalTo(sub_title.snp.left).offset(-1)
            x.width.equalTo(288)
            x.height.equalTo(48)
        }
        
        if image_str.hasPrefix("NAMED:") {
            head_icon.image = UIImage(named: image_str.split(separator: ":").last?.to_String() ?? "")
        } else {
            head_icon.sd_setImage(with: URL(string: image_str), placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
        }
        head_icon.setRadiusCGF()
        head_icon.snp.makeConstraints { (x) in
            x.centerY.equalTo(main_title.snp.centerY).offset(0)
            x.right.equalTo(ret_view.snp.right).offset(-18)
            x.width.equalTo(28)
            x.height.equalTo(28)
        }
        
        if sep_enabled {
            seperator.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
            seperator.alpha = 0.5
            seperator.snp.makeConstraints { (x) in
                x.left.equalTo(main_title.snp.left)
                x.right.equalTo(head_icon.snp.right)
                x.top.equalTo(main_title.snp.bottom).offset(12)
                x.height.equalTo(0.5)
            }
        }
        
        return ret_view
    }
    
}
