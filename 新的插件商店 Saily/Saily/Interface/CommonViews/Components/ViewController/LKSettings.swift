//
//  LKSettings.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/18.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class LKSettingsController: UIViewController {
    
    let some = LKRoot.manager_reg.se
    let contentView = UIScrollView()
    
    var sum_height = UIScreen.main.bounds.height
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LKRoot.settings?.use_dark_mode ?? false {
            navigationController?.navigationBar.barStyle = .blackTranslucent
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.navigationBar.tintColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: LKRoot.ins_color_manager.read_a_color("main_tint_color")]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            let some = LKRoot.ins_color_manager.read_a_color("main_background")
            let red = some.redRead()
            let green = some.greenRead()
            let blue = some.blueRead()
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: red,
                                                                               green: green,
                                                                               blue: blue,
                                                                               alpha: 1)
        }, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        
        view.addSubview(contentView)
        contentView.addSubview(some)
        contentView.contentSize = CGSize(width: 0, height: sum_height)
        
        if !some.initd {
            some.apart_init(father: self.contentView)
        }
        
        contentView.snp.makeConstraints { (x) in
            x.edges.equalTo(self.view.snp.edges)
        }
        some.snp.makeConstraints { (x) in
            x.top.equalTo(self.contentView.snp.top)
            x.left.equalTo(self.view.snp.left)
            x.right.equalTo(self.view.snp.right)
            x.height.equalTo(sum_height)
        }
        
    }
    
    
    
}
