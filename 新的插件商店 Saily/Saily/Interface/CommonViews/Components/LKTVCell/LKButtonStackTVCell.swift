//
//  LKButtonStackTVCell.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/9.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension cell_views {
    
    class LK2ButtonStackTVCell: UITableViewCell {
        
        let button1 = UIButton()
        let button2 = UIButton()
        private let dummy = UIView()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            button1.translatesAutoresizingMaskIntoConstraints = false
            button2.translatesAutoresizingMaskIntoConstraints = false
            dummy.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(button1)
            contentView.addSubview(button2)
            contentView.addSubview(dummy)
            
            dummy.snp.makeConstraints { (x) in
                x.center.equalTo(contentView.snp.center)
                x.width.equalTo(1)
                x.height.equalTo(1)
            }
            
            button1.setTitle("Button1Title", for: .normal)
            button1.titleLabel?.font = .boldSystemFont(ofSize: 15)
            button1.setRadiusINT(radius: 8)
            //        button1.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
            button1.setTitleColor(.gray, for: .highlighted)
            button1.snp.makeConstraints { (x) in
                x.left.equalTo(contentView.snp.left).offset(12)
                x.right.equalTo(dummy.snp.left).offset(-12)
                x.top.equalTo(contentView.snp.top).offset(6)
                x.bottom.equalTo(contentView.snp.bottom).offset(-6)
            }
            
            button2.setTitle("Button2Title", for: .normal)
            button2.titleLabel?.font = .boldSystemFont(ofSize: 15)
            button2.setRadiusINT(radius: 8)
            //        button2.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
            button2.setTitleColor(.gray, for: .highlighted)
            button2.snp.makeConstraints { (x) in
                x.left.equalTo(dummy.snp.right).offset(12)
                x.right.equalTo(contentView.snp.right).offset(-12)
                x.top.equalTo(contentView.snp.top).offset(6)
                x.bottom.equalTo(contentView.snp.bottom).offset(-6)
            }
            
            contentView.backgroundColor = .clear
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
}
