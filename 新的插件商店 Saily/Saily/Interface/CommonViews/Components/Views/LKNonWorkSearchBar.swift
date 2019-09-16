//
//  LKNonWorkSearchBar.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/16.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// why this? We cover a button over it.

extension common_views {
    
    class LKNonWorkSearchBar: UIView {
        
        func apart_init(txt: String) {
            
            let border = UIView()
            let shadow = UIView()
            let icon = UIImageView(image: UIImage(named: "Search"))
            let text = UILabel(text: txt)
            
            shadow.setRadiusINT(radius: 8)
            border.setRadiusINT(radius: 4)
            shadow.backgroundColor = LKRoot.ins_color_manager.read_a_color("shadow")
            shadow.alpha = 0.2
            border.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
            border.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("main_background"))
            
            if LKRoot.settings?.use_dark_mode ?? false {
                border.backgroundColor = .darkGray
                border.alpha = 0.666
                border.setRadiusINT(radius: 8)
            }
            
            icon.contentMode = .scaleAspectFit
            
            text.font = .boldSystemFont(ofSize: 16)
            text.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
            
            addSubview(shadow)
            addSubview(border)
            addSubview(icon)
            addSubview(text)
            
            shadow.snp.makeConstraints { (x) in
                x.edges.equalTo(self.snp.edges)
            }
            
            let OFFSET = 2
            border.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top).offset(OFFSET)
                x.bottom.equalTo(self.snp.bottom).offset(-OFFSET)
                x.left.equalTo(self.snp.left).offset(OFFSET)
                x.right.equalTo(self.snp.right).offset(-OFFSET)
            }
            
            icon.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top).offset(2)
                x.bottom.equalTo(self.snp.bottom).offset(-2)
                x.left.equalTo(self.snp.left).offset(2)
                x.width.equalTo(40)
            }
            
            text.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top)
                x.bottom.equalTo(self.snp.bottom)
                x.left.equalTo(icon.snp.right).offset(8)
                x.right.equalTo(self.snp.right)
            }
            
        }
        
    }
    
}
