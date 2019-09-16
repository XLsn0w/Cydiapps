//
//  LKPackageCLCell.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/20.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//


extension cell_views {
    
    class LKPackageCLCell: UICollectionViewCell {
        
        let icon = UIImageView()
        let title = UILabel()
        let auth = UILabel()
        let link = UILabel()
        
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            
            icon.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            link.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(icon)
            contentView.addSubview(title)
            contentView.addSubview(auth)
            contentView.addSubview(link)
            
            icon.setRadiusINT(radius: 6)
            icon.contentMode = .scaleAspectFit
            icon.snp.remakeConstraints { (x) in
                x.centerY.equalTo(contentView.snp.centerY)
                x.left.equalTo(contentView.snp.left).offset(12)
                x.height.equalTo(45)
                x.width.equalTo(45)
            }
            
            title.font = .boldSystemFont(ofSize: 18)
            title.textColor = LKRoot.ins_color_manager.read_a_color("table_view_title")
            title.snp.remakeConstraints { (x) in
                x.left.equalTo(icon.snp.right).offset(12)
                x.right.equalTo(contentView.snp.right).offset(-12)
                x.top.equalTo(contentView.snp.top).offset(16)
                x.height.equalTo(18)
            }
            
            auth.font = .boldSystemFont(ofSize: 12)
            auth.textColor = LKRoot.ins_color_manager.read_a_color("table_view_link")
            auth.snp.remakeConstraints { (x) in
                x.top.equalTo(title.snp.bottom).offset(2)
                x.left.equalTo(icon.snp.right).offset(12)
                x.right.equalTo(contentView.snp.right).offset(-12)
                x.height.equalTo(14)
            }
            
            link.font = .boldSystemFont(ofSize: 12)
            link.textColor = LKRoot.ins_color_manager.read_a_color("table_view_link")
            link.snp.remakeConstraints { (x) in
                x.top.equalTo(auth.snp.bottom).offset(2)
                x.left.equalTo(icon.snp.right).offset(12)
                x.right.equalTo(contentView.snp.right).offset(-12)
                x.height.equalTo(14)
            }
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
    
}
