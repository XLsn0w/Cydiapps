//
//  UIViewCacheContainer.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/28.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//


enum view_tags: Int {
    case must_have                              = 0x101
    case indicator                              = 0x102
    case can_remove                             = 0x103
    case must_remove                            = 0x233
    
    case pop_up                                 = 0x234
    
    case main_scroll_view_in_view_controller    = 0x111
    
}

class common_views {
    // 啥都不用干
}

class manage_views {
    // 啥都不用干
}

class manage_view_reg {
    let nr = manage_views.LKIconGroupDetailView_NewsRepoSP()
    let pr = manage_views.LKIconGroupDetailView_PackageRepoSP()
    let ya = manage_views.LKIconGroupDetailView_RecentInstalled()
    let ru = manage_views.LKIconGroupDetailView_RecentUpdate()
    let rp = manage_views.LKIconGroupDetailView_RandomPackage()
    let se = manage_views.LKIconGroupDetailView_Settings()
}

class cell_views {
    // 啥都不用干
}

func readTopViewController() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let selectedViewController = (topController as? UITabBarController)?.selectedViewController {
            topController = selectedViewController
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        if let lastViewController = (topController as? UINavigationController)?.viewControllers.last {
            topController = lastViewController
        }
        return topController
    }
    return nil
}

func presentStatusAlert(imgName: String, title: String, msg: String) {
    DispatchQueue.main.async {
        if LKRoot.settings?.use_dark_mode ?? false {
            let statusAlert = StatusAlertDark()
            statusAlert.image = UIImage(named: imgName)
            statusAlert.title = title
            statusAlert.message = msg
            statusAlert.canBePickedOrDismissed = true
            statusAlert.showInKeyWindow()
        } else {
            let statusAlert = StatusAlert()
            statusAlert.image = UIImage(named: imgName)
            statusAlert.title = title
            statusAlert.message = msg
            statusAlert.canBePickedOrDismissed = true
            statusAlert.showInKeyWindow()
        }
    }
}

func presentSwiftMessageSuccess(title: String, body: String) {
    var config = SwiftMessages.Config()
    config.presentationStyle = .top
    config.presentationContext = .window(windowLevel: .normal)
    config.interactiveHide = true
    let view = MessageView.viewFromNib(layout: .cardView)
    view.configureTheme(.success)
    view.configureDropShadow()
    view.configureContent(title: title, body: body)
    view.button?.isHidden = true
    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    //    (view.backgroundView as? CornerRoundingView)?.cornerRadius = CGFloat(LKRoot.settings?.card_radius ?? 8)
    SwiftMessages.show(config: config, view: view)
}

func presentSwiftMessageError(title: String, body: String) {
    var config = SwiftMessages.Config()
    config.presentationStyle = .top
    config.presentationContext = .window(windowLevel: .normal)
    config.interactiveHide = true
    let view = MessageView.viewFromNib(layout: .cardView)
    view.configureTheme(.error)
    view.configureDropShadow()
    view.configureContent(title: title, body: body)
    view.button?.isHidden = true
    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    //    (view.backgroundView as? CornerRoundingView)?.cornerRadius = CGFloat(LKRoot.settings?.card_radius ?? 8)
    SwiftMessages.show(config: config, view: view)
}

func presentPackage(pack: DBMPackage) {
    
    let pack = pack.copy()
    
    UIApplication.shared.beginIgnoringInteractionEvents()
    let new = LKPackageDetail()
    
    LKRoot.queue_dispatch.async {
        
        // [String : [String : String]] 最新版本号下的 软件源 ：详细信息
        let ver = LKRoot.ins_common_operator.PAK_read_newest_version(pack: pack)
        
        // 丢弃旧版本
        pack.version.removeAll()
        pack.version[ver.0] = ver.1
        
        // 检查软件包合法性
        if ver.1.count < 1 || ver.1.first?.key == "-1" || ver.1.first?.key == "" {
            presentStatusAlert(imgName: "Warning", title: "错误".localized(), msg: "软件包不合法，请尝试刷新数据。".localized())
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            return
        }
        
        if ver.1.count == 1 {
            // 只有一个软件源提供这个软件包
            pack.version.removeAll()
            pack.version[ver.0] = ver.1
            new.item = pack
            
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                IHProgressHUD.dismiss()
                if let nav = readTopViewController()?.navigationController {
                    nav.pushViewController(new, animated: true)
                } else {
                    readTopViewController()?.present(new, animated: true, completion: {
                        
                    })
                }
            }
            
        } else {
            // 有多个软件源提供这个软件包
            var alert = UIAlertController(title: "⚠️", message: "这个软件包同时被多个软件源提供。请选择一个查看详情".localized(), preferredStyle: .alert)
            if !LKRoot.is_iPad {
                alert = UIAlertController(title: "⚠️", message: "这个软件包同时被多个软件源提供。请选择一个查看详情".localized(), preferredStyle: .actionSheet)
            }
            for item in ver.1 {
                let link = item.key
                var name = ""
                for repo in LKRoot.container_package_repo where repo.link == link {
                    name = repo.name
                    if name == "未知错误".localized() {
                        name = link
                    }
                }
                alert.addAction(UIAlertAction(title: name, style: .default, handler: { (_) in
                    // 合成软件包并发送到新 vc
                    let new = LKPackageDetail()
                    let packer = pack
                    packer.version.removeAll()
                    packer.version[ver.0] = [item.key : item.value]
                    new.item = packer
                    if let nav = readTopViewController()?.navigationController {
                        nav.pushViewController(new, animated: true)
                    } else {
                        readTopViewController()?.present(new, animated: true, completion: {
                            
                        })
                    }
                }))
            }
            alert.addAction(UIAlertAction(title: "取消".localized(), style: .default, handler: { (_) in
                
            }))
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                IHProgressHUD.dismiss()
                readTopViewController()?.present(alert, animated: true, completion: {
                    
                })
            }
        }
    }

}

func presentViewController(some: UIViewController, animated: Bool = true) {
    if let nav = readTopViewController()?.navigationController {
        if some.isKind(of: UIAlertController.self) {
            readTopViewController()?.present(some, animated: animated, completion: {
            })
        } else {
            nav.pushViewController(some, animated: animated)
        }
    } else {
        readTopViewController()?.present(some, animated: animated, completion: {
        })
    }
}

func presentSwiftMessageController(some: UIViewController, interActinoEnabled: Bool = true) {
    
    let target: UIViewController
    
    if let nav = readTopViewController()?.navigationController {
        target = nav
    } else {
        guard let t = readTopViewController() else {
            return
        }
        target = t
    }
    
    if interActinoEnabled {
        let segue = centerSMSegue(identifier: nil, source: target, destination: some)
        segue.perform()
    } else {
        let segue = centerSMSegueNoInterAction(identifier: nil, source: target, destination: some)
        segue.perform()
    }
    
    
}

class centerSMSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        interactiveHide = false
        // 不好看
        //        if LKRoot.settings?.use_dark_mode ?? false {
        //            dimMode = .blur(style: .dark, alpha: 0.8, interactive: true)
        //        } else {
        //            dimMode = .blur(style: .light, alpha: 0.5, interactive: true)
        //        }
        dimMode = .gray(interactive: true)
        messageView.configureNoDropShadow()
    }
}

class centerSMSegueNoInterAction: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        interactiveHide = false
        dimMode = .gray(interactive: false)
        messageView.configureNoDropShadow()
    }
}
