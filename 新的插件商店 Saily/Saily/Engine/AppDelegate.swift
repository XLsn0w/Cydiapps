//
//  AppDelegate.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/28.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            LKRoot.is_iPad = true
        }
        
        LKRoot.initializing()
        
        LKDaemonUtils.initializing()
        
//        #if DEBUG
//        LKRoot.isRootLess = true
//        #endif
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = #colorLiteral(red: 0.2882809639, green: 0.5985316038, blue: 0.9432967305, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        var mainStoryboard: UIStoryboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
        if LKRoot.is_iPad {
            mainStoryboard = UIStoryboard(name: "Main_iPad", bundle: nil)
        }
        let navigationController = mainStoryboard.instantiateInitialViewController()!
        self.window!.rootViewController = navigationController
        
        if LKRoot.ins_color_manager.read_a_color("DARK_ENABLED") == .clear {
            // Twitter 动画
            navigationController.twitter_animte()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        LKRoot.ever_went_background = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        LKRoot.root_db?.close()
        if LKRoot.should_backup_when_exit {
            _ = LKDaemonUtils.requestBackup()
        }
    }

    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == nil {
            return true
        }
        
        DispatchQueue(label: "com.Lakr233.Saily.URLScheme.Dispatch").asyncAfter(deadline: .now() + 1) {
            //获取来源应用的Identifier
            print("[*] 来源App：\(options[UIApplication.OpenURLOptionsKey.sourceApplication]!)")
            
            //获取url以及参数
            let urlString = url.absoluteString
            print(urlString)
            
            if urlString.hasPrefix("sailypra://") {
                var ret = urlString.dropFirst("sailypra://".count).to_String().base64Decoded ?? ""
                if URL(string: ret) != nil {
                    if !ret.hasSuffix("/") {
                        ret += "/"
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "+?", message: ret, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确认".localized(), style: .default, handler: { (_) in
                            let url = URL(string: ret)!
                            let read = url.absoluteString
                            IHProgressHUD.show()
                            UIApplication.shared.beginIgnoringInteractionEvents()
                            LKRoot.queue_dispatch.async {
                                let new = DBMPackageRepos()
                                new.link = read
                                new.sort_id = LKRoot.container_package_repo_DBSync.count
                                try? LKRoot.root_db?.insertOrReplace(objects: new, intoTable: common_data_handler.table_name.LKPackageRepos.rawValue)
                                LKRoot.ins_common_operator.PR_sync_and_download(sync_all: false) { (_) in
                                    DispatchQueue.main.async {
                                        IHProgressHUD.dismiss()
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                        if LKRoot.manager_reg.pr.initd {
                                            LKRoot.manager_reg.pr.update_user_interface {
                                                IHProgressHUD.dismiss()
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                presentStatusAlert(imgName: "Done",
                                                                   title: "已尝试刷新软件源".localized(),
                                                                   msg: "软件包的更新将在后台进行。".localized())
                                            } // update_user_interface
                                        } else {
                                            IHProgressHUD.dismiss()
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            presentStatusAlert(imgName: "Done",
                                                               title: "已尝试刷新软件源".localized(),
                                                               msg: "软件包的更新将在后台进行。".localized())
                                        } // initd
                                    } // async
                                } // PR_sync_and_download
                            } // async
                        }))
                        alert.addAction(UIAlertAction(title: "取消".localized(), style: .default, handler: { (_) in
                            
                        }))
                        alert.presentToCurrentViewController()
                    }
                }
                return
            } // urlString.hasPrefix("sailypra://")
            if urlString.hasPrefix("sailynra://") {
                var ret = urlString.dropFirst("sailynra://".count).to_String().base64Decoded ?? ""
                if URL(string: ret) != nil {
                    if !ret.hasSuffix("/") {
                        ret += "/"
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "+?", message: ret, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确认".localized(), style: .default, handler: { (_) in
                            let read = ret
                            IHProgressHUD.show()
                            UIApplication.shared.beginIgnoringInteractionEvents()
                            LKRoot.queue_dispatch.async {
                                let new = DBMNewsRepo()
                                new.link = read
                                new.sort_id = LKRoot.container_news_repo_DBSync.count
                                try? LKRoot.root_db?.insertOrReplace(objects: new, intoTable: common_data_handler.table_name.LKNewsRepos.rawValue)
                                LKRoot.ins_common_operator.NR_sync_and_download { (ret) in
                                    DispatchQueue.main.async {
                                        if ret != 0 || (LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"] ?? "").contains(new.link ?? "") {
                                            LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"] = ""
                                            IHProgressHUD.dismiss()
                                            print("[*] 刷新失败")
                                            presentStatusAlert(imgName: "Warning",
                                                               title: "刷新失败".localized(),
                                                               msg: "请检查源地址或网络连接并在试一次。".localized())
                                            try? LKRoot.root_db?.delete(fromTable: common_data_handler.table_name.LKNewsRepos.rawValue, where: DBMNewsRepo.Properties.link == read)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            return
                                        }
                                        if LKRoot.manager_reg.nr.initd {
                                            LKRoot.manager_reg.nr.update_user_interface {
                                                IHProgressHUD.dismiss()
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                presentStatusAlert(imgName: "Done",
                                                                   title: "添加成功".localized(),
                                                                   msg: (LKRoot.container_news_repo_DBSync.last?.name ?? "") + " 已经添加到你的仓库".localized())
                                            }
                                        } else {
                                            IHProgressHUD.dismiss()
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            presentStatusAlert(imgName: "Done",
                                                               title: "添加成功".localized(),
                                                               msg: (LKRoot.container_news_repo_DBSync.last?.name ?? "") + " 已经添加到你的仓库".localized())
                                        }
                                        (LKRoot.tabbar_view_controller as? UIEnteryS)?.home.viewWillAppear(true)
//                                        (LKRoot.tabbar_view_controller as? UIEnteryL)
                                    }
                                }
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "取消".localized(), style: .default, handler: { (_) in
                            
                        }))
                        alert.presentToCurrentViewController()
                    }
                }
                return
            } // urlString.hasPrefix("sailynra://")
        }
        
        return true
    }
    
}
