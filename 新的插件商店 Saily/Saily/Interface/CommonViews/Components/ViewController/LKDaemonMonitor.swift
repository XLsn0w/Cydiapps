//
//  LKDaemonMonitor.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/24.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import JJFloatingActionButton

class LKDaemonMonitor: UIViewController {
    
    let textView = UITextView()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        
        textView.backgroundColor = .clear
        textView.font = .boldSystemFont(ofSize: 12)
        textView.isEditable = false
        textView.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        view.addSubview(textView)
        
        titleLabel.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.text = "- 正在执行 -".localized()
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (x) in
            x.top.equalTo(self.view.snp.top).offset(6)
            x.centerX.equalTo(self.view.snp.centerX)
            x.height.equalTo(38)
        }
        
        let sep = UIView()
        sep.alpha = 0.5
        sep.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        view.addSubview(sep)
        sep.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(-12)
            x.right.equalTo(self.view.snp.right).offset(12)
            x.top.equalTo(titleLabel.snp.bottom).offset(6)
            x.height.equalTo(0.5)
        }
        
        textView.snp.makeConstraints { (x) in
            x.left.equalTo(self.view.snp.left).offset(12)
            x.right.equalTo(self.view.snp.right).offset(-12)
            x.top.equalTo(sep.snp.bottom)
            x.bottom.equalTo(self.view.snp.bottom)
        }
        
        updateText()
        
    }
    
    var checkTimeOut = 256 // like some 60s?
    func updateText(round: Int = 0) {
        let str = (try? String(contentsOfFile: LKRoot.root_path! + "/daemon.call/out.txt")) ?? ""
        textView.scrollToBottom()
        textView.text = str
        if round == checkTimeOut {
            presentStatusAlert(imgName: "Warning", title: "⚠️", msg: "执行任务的时间超出了预期\n你可以选择手动退出")
            exitCall(isTimeOut: true)
        }
        if str.contains("Saily::internal_session_finished::Signal") && round < checkTimeOut {
            presentStatusAlert(imgName: "Done", title: "完成".localized(), msg: "你的操作已经完成".localized())
            exitCall()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.233) {
            if !str.contains("Saily::internal_session_finished::Signal") {
                self.updateText(round: round + 1)
            }
        }
    }
    
    func exitCall(isTimeOut: Bool = false) {
        
        if !isTimeOut {
            titleLabel.text = "- 任务完成 -".localized()
        }
        
        let actionButton = JJFloatingActionButton()
        actionButton.addItem(title: "退出".localized(), image: UIImage(named: "Exit"), action: { (_) in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            let alert = UIAlertController(title: "注销？".localized(), message: "几乎所有的插件都需要注销才能被加载".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "执行".localized(), style: .default, handler: { (_) in
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                print("[*] 开始更新已安装")
                UIApplication.shared.beginIgnoringInteractionEvents()
                IHProgressHUD.show()
                LKRoot.queue_dispatch.async {
                    let new_session = UUID().uuidString
                    LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE_SESSION"] = new_session
                    let sss = DispatchSemaphore(value: 0)
                    LKRoot.ins_common_operator.YA_build_installed_list(session: new_session) { (_) in
                        sss.signal()
                    }
                    sss.wait()
                    LKDaemonUtils.daemon_msg_pass(msg: "init:req:reSpring")
                    DispatchQueue.main.async {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        IHProgressHUD.dismiss()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { (_) in
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                UIApplication.shared.beginIgnoringInteractionEvents()
                IHProgressHUD.show()
                LKRoot.queue_dispatch.async {
                    
                    for obj in LKDaemonUtils.ins_operation_delegate.operation_queue {
                        obj.dowload?.dlReq.suspend()
                        LKDaemonUtils.ins_operation_delegate.unfired_download_req[obj.package.id] = obj.dowload
                    }
                    
                    LKDaemonUtils.ins_operation_delegate.operation_queue.removeAll()
                    LKDaemonUtils.ins_operation_delegate.unsolved_condition.removeAll()
                    print("[*] 开始更新已安装")
                    let new_session = UUID().uuidString
                    LKRoot.container_string_store["IN_PROGRESS_INSTALLED_PACKAGE_UPDATE_SESSION"] = new_session
                    let sss = DispatchSemaphore(value: 0)
                    LKRoot.ins_common_operator.YA_build_installed_list(session: new_session) { (_) in
                        sss.signal()
                    }
                    sss.wait()
                    DispatchQueue.main.async {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        IHProgressHUD.dismiss()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        })
        actionButton.setRadiusCGF(radius: 22.5)
        actionButton.addShadow(ofColor: LKRoot.ins_color_manager.read_a_color("shadow"))
        var bak_color = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        if LKRoot.settings?.use_dark_mode ?? false {
            bak_color = bak_color.darken(by: 0.5)
        }
        actionButton.backgroundColor = bak_color
        actionButton.buttonColor = bak_color
        view.addSubview(actionButton)
        view.bringSubviewToFront(actionButton)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            actionButton.imageView.snp.remakeConstraints({ (x) in
                x.edges.equalTo(actionButton.snp.edges).inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
            })
            actionButton.snp.remakeConstraints({ (x) in
                x.right.equalTo(self.view.snp.right).offset(-18)
                if #available(iOS 11.0, *) {
                    x.bottom.equalTo(self.view.snp.bottom).offset(0 - self.view.safeAreaInsets.bottom - 18)
                } else {
                    // Fallback on earlier versions
                    x.bottom.equalTo(self.view.snp.bottom).offset(-18)
                }
                x.height.equalTo(45)
                x.width.equalTo(45)
            })
            
        }
        
    }
    
}
