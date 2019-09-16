//
//  UIEntery.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/28.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class UIEnteryL: UITabBarController {

    var last_tapped_view_controller: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LKRoot.tabbar_view_controller = self
        
        print("[*] 将以 iPad 的方式加载故事版。")
        
        tabBar.tintColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        tabBar.backgroundColor = LKRoot.ins_color_manager.read_a_color("tabbar_background")
        tabBar.barTintColor = LKRoot.ins_color_manager.read_a_color("tabbar_background")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.last_tapped_view_controller = self.selectedViewController
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        let willing = selectedViewController
        if willing == last_tapped_view_controller {
            for this in willing?.view.subviews ?? [] where this as? UIScrollView != nil {
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                    (this as? UIScrollView)?.contentOffset = CGPoint(x: 0, y: -66)
                }, completion: { _ in
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
            return
        }
        last_tapped_view_controller = selectedViewController
        
        guard let view = item.value(forKey: "_view") as? UIView else { return   }
        for item in view.subviews {
            if let image = item as? UIImageView {
                image.shineAnimation()
                break
            }
        }
    }
    
}
