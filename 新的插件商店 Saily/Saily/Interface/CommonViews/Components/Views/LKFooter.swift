//
//  LKFooter.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/22.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension common_views {

    class LKFooter: UIView {
        
        let sep = UIView()
        let label = UILabel()
        let label2 = UILabel()
        let button = UIButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(sep)
            addSubview(label)
            addSubview(label2)
            addSubview(button)
            
            sep.backgroundColor = .gray
            sep.alpha = 0.5
            sep.snp.makeConstraints { (x) in
                x.left.equalTo(self.snp.left)
                x.right.equalTo(self.snp.right)
                x.height.equalTo(0.5)
                x.top.equalTo(self.snp.top)
            }
            
            label.font = .systemFont(ofSize: 16)
            label.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
            label.text = LKRoot.shared_device._id() + " - " + LKRoot.shared_device.systemVersion
            label.snp.makeConstraints { (x) in
                x.top.equalTo(sep.snp.bottom).offset(12)
                x.left.equalTo(sep.snp.left)
                x.height.equalTo(18)
            }
            
            label2.font = .systemFont(ofSize: 16)
            label2.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
            var v = ""
            if LKRoot.settings?.real_UDID != nil && LKRoot.settings?.real_UDID != "" {
                v = ""
            } else {
                v = " - v"
            }
            label2.text = "[ " + (LKRoot.settings?.readUDID())!.uppercased().dropLast(16) + " ] + 16" + v
            label2.snp.makeConstraints { (x) in
                x.top.equalTo(label.snp.bottom).offset(12)
                x.left.equalTo(sep.snp.left)
                x.height.equalTo(18)
            }
            
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.setTitleColor(LKRoot.ins_color_manager.read_a_color("sub_text"), for: .normal)
            button.setTitle("条件与条款".localized(), for: .normal)
            button.addTarget(self, action: #selector(license(sender:)), for: .touchUpInside)
            button.snp.makeConstraints { (x) in
                x.top.equalTo(label2.snp.bottom).offset(12)
                x.left.equalTo(sep.snp.left)
                x.height.equalTo(18)
            }
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        @objc func license(sender: Any) {
            UIApplication.shared.open(URL(string: "https://github.com/Co2333/NoCoolStarLicense")!, options: [:], completionHandler: nil)
        }
        
    }
    
}
