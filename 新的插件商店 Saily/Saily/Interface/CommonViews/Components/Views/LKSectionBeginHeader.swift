//
//  LKSectionBeginHeader.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/18.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension common_views {
    
    class LKSectionBeginHeader: UIView {
        
        var theme_color: UIColor?
        
        private let label = UILabel()
        private let line = UIView()
        
        func apart_init(section_name: String) {
            addSubview(label)
            addSubview(line)
            
            label.textColor = theme_color ?? LKRoot.ins_color_manager.read_a_color("main_tint_color")
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 22)
            label.text = section_name
            label.setRadiusINT(radius: 2)
            label.snp.makeConstraints { (x) in
                x.centerX.equalTo(self.snp.centerX)
                x.centerY.equalTo(self.snp.centerY)
                x.height.equalTo(25)
                x.width.equalTo(188)
            }
            
            line.backgroundColor = theme_color ?? LKRoot.ins_color_manager.read_a_color("main_tint_color")
            line.snp.makeConstraints { (x) in
                x.left.equalTo(self.snp.left)
                x.bottom.equalTo(self.snp.bottom)
                x.right.equalTo(self.snp.right)
                x.height.equalTo(0.5)
            }
            
            
        }
        
    }
    
}
