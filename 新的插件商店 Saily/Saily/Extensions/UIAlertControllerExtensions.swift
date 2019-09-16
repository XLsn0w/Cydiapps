//
//  UIAlertControllerExtensions.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/15.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func presentToCurrentViewController() {
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(self, animated: true, completion: nil)
            }
        }
    }
    
}
