//
//  LKRepoView.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/10.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension common_views {
    
    class LKNewsRepoDetails: UIView {
        
        let arrow = UIImageView()
        
        func apart_init() {
            arrow.image = UIImage(named: "arrowUp")
            arrow.contentMode = .scaleAspectFit
            addSubview(arrow)
            arrow.snp.makeConstraints { (x) in
                x.bottom.equalTo(self.snp.top).offset(18)
                x.width.equalTo(33)
                x.height.equalTo(33)
                x.centerX.equalTo(self.snp.centerX)
            }
        }
        
    }
    
}
