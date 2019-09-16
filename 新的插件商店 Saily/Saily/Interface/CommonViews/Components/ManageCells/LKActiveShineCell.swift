//
//  LKActiveShineCell.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/13.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension manage_views {
    
    class LKActiveShineCell: UIView {
    
        var timer : Timer?
        
        let dark = UILabel()
        var status = true
        var shine_id = ""
        
        var father_view = UIView()
        
        func apart_init(father: UIView) {
            father_view = father
            dark.text = (LKRoot.container_string_store["STR_SIG_PROGRESS"]?.localized() ?? "")
//                + (LKRoot.container_string_store["STR_SIG_PROGRESS_NUM"]?.localized() ?? "")
            if dark.text == "SIGCLEAR" {
                dark.text = ""
            }
            dark.textAlignment = .center
            dark.font = .boldSystemFont(ofSize: 14)
            dark.textColor = LKRoot.ins_color_manager.read_a_color("main_operations_attention").darken(by: 0.01)
            dark.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            addSubview(dark)
            dark.snp.makeConstraints { (x) in
                x.top.equalTo(self.snp.top)
                x.bottom.equalTo(self.snp.bottom).offset(12)
                x.left.equalTo(self.snp.left)
                x.right.equalTo(self.snp.right)
            }
            animation(id: UUID().uuidString)
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timer_call), userInfo: nil, repeats: true)
            timer?.fire()
        }
        
        func animation(id: String) {
            if shine_id != id {
                return
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6) {
                    if self.status {
                        self.dark.alpha = 0.8
                    } else {
                        self.dark.alpha = 0
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                UIView.animate(withDuration: 0.6) {
                    if self.status {
                        self.dark.alpha = 1
                    } else {
                        self.dark.alpha = 0
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if self.status {
                    self.animation(id: id)
                }
            }
        }
        @objc func timer_call() {
            if LKRoot.container_string_store["STR_SIG_PROGRESS"] == "SIGCLEAR" {
                status = false
                let new = UUID().uuidString
                shine_id = new
                self.animation(id: new)
            } else {
                dark.text = (LKRoot.container_string_store["STR_SIG_PROGRESS"]?.localized() ?? "")
                status = true
                let new = UUID().uuidString
                shine_id = new
                self.animation(id: new)
            }
            
//            if last_SIG != LKRoot.container_string_store["STR_SIG_PROGRESS"] {
//                if LKRoot.current_page.isKind(of: UIManageS.self) || LKRoot.current_page.isKind(of: UIManageL.self) {
//                    LKRoot.container_string_store["REQ_REFRESH_UI_MANAGE"] = "FALSE"
//                    UIApplication.shared.beginIgnoringInteractionEvents()
//                    (father_view as? UITableView)?.beginUpdates()
//                    LKRoot.container_string_store["in_progress_UI_manage_update"] = "TRUE"
//                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
//                        (self.father_view as? UITableView)?.endUpdates()
//                    }, completion: { (_) in
//                        LKRoot.container_string_store["in_progress_UI_manage_update"] = "FALSE"
//                        UIApplication.shared.endIgnoringInteractionEvents()
//                    })
//                } else {
//                    LKRoot.container_string_store["REQ_REFRESH_UI_MANAGE"] = "TRUE"
//                }
//            }
        }
    }
    
}
