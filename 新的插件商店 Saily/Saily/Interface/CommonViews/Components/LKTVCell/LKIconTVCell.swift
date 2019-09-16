//
//  LKIconTVCell.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/8.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension cell_views {
    
    class LKIconTVCell: UITableViewCell {
        
        let icon = UIImageView()
        let title = UILabel()
        let link = UILabel()
        let sep = UIView()
        let arrow = UIImageView()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            icon.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            link.translatesAutoresizingMaskIntoConstraints = false
            sep.translatesAutoresizingMaskIntoConstraints = false
            arrow.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(icon)
            contentView.addSubview(title)
            contentView.addSubview(link)
            contentView.addSubview(sep)
            contentView.addSubview(arrow)
            
            icon.setRadiusINT(radius: 6)
            icon.contentMode = .scaleAspectFit
            icon.snp.makeConstraints { (x) in
                x.centerY.equalTo(contentView.snp.centerY)
                x.left.equalTo(contentView.snp.left).offset(12)
                x.height.equalTo(33)
                x.width.equalTo(33)
            }
            
            sep.backgroundColor = .lightGray
            sep.snp.makeConstraints { (x) in
                x.left.equalTo(icon.snp.right).offset(12)
                x.bottom.equalTo(contentView.snp.bottom)
                x.right.equalTo(contentView.snp.right)
                x.height.equalTo(0.5)
            }
            
            link.font = .boldSystemFont(ofSize: 12)
            link.textColor = LKRoot.ins_color_manager.read_a_color("table_view_link")
            link.snp.makeConstraints { (x) in
                x.bottom.equalTo(icon.snp.bottom).offset(2)
                x.left.equalTo(sep.snp.left).offset(4)
                x.right.equalTo(contentView.snp.right)
                x.height.equalTo(14)
            }
            
            title.font = .boldSystemFont(ofSize: 18)
            title.textColor = LKRoot.ins_color_manager.read_a_color("table_view_title")
            title.snp.makeConstraints { (x) in
                x.bottom.equalTo(link.snp.top).offset(0)
                x.left.equalTo(link.snp.left)
                x.right.equalTo(contentView.snp.right)
                x.top.equalTo(contentView.snp.top).offset(6)
            }
            
//            arrow.image = UIImage(named: "info")
            arrow.contentMode = .scaleAspectFit
            arrow.snp.makeConstraints { (x) in
                x.centerY.equalTo(contentView.snp.centerY)
                x.right.equalTo(contentView.snp.right).offset(-6)
                x.height.equalTo(20)
                x.width.equalTo(20)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
}
