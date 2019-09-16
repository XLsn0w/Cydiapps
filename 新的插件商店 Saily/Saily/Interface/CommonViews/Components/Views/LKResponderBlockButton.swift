//
//  LKResponderBlockButton.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/10.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension common_views {
    
    class LKResponderBlockButton: UIButton {
    
        private var father_view = UIView()
        
        func apart_init(father: UIView) {
            father.addSubview(self)
            setBackgroundImage(UIImage(named: "Dark"), for: .normal)
            snp.makeConstraints { (x) in
                x.top.equalTo(father.snp.top).offset(-122)
                x.bottom.equalTo(father.snp.bottom).offset(122)
                x.left.equalTo(father.snp.left).offset(-122)
                x.right.equalTo(father.snp.right).offset(122)
            }
            alpha = 0
            addTarget(self, action: #selector(dis_appear), for: .touchUpInside)
            UIApplication.shared.beginIgnoringInteractionEvents()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.alpha = 0.5
            }, completion: { (_) in
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
        
        @objc func dis_appear() {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.alpha = 0
                UIApplication.shared.beginIgnoringInteractionEvents()
            }, completion: { (_) in
                self.removeSubviews()
                self.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
        
    }
    
}
