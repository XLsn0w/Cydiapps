//
//  UIMineS.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/17.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class UIMineS: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        
        let label = UILabel(text: "即将开放".localized())
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        view.addSubview(label)
        label.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(66)
            x.centerY.equalTo(self.view.snp.centerY).offset(-58)
            x.width.equalTo(288)
            x.height.equalTo(30)
        }
        let label2 = UILabel(text: "我们将重新定义首页分享".localized())
        label2.font = .boldSystemFont(ofSize: 18)
        label2.textColor = LKRoot.ins_color_manager.read_a_color("sub_text")
        view.addSubview(label2)
        label2.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(66)
            x.top.equalTo(label.snp.bottom)
            x.width.equalTo(288)
            x.height.equalTo(44)
        }
        
    }
    
}
