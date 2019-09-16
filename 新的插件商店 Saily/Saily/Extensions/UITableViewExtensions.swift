//
//  UITableViewExtensions.swift
//  Saily
//
//  Created by mac on 2019/5/11.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            let s = DispatchSemaphore(value: 666)
            DispatchQueue.main.async {
                self.reloadData()
                s.signal()
            }
            s.wait()
        }, completion: { _ in
            completion()
        })
    }
    
}

