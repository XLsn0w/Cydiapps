//
//  AlertViewController.swift
//  saïgon
//
//  Created by Abraham Masri on 8/18/17.
//  Copyright © 2017 Abraham Masri. All rights reserved.
//

import UIKit
import Foundation

class AlertViewController: UIViewController {
    
    @IBOutlet weak var failedTitle: UILabel!

    override func viewDidLoad() {
        failedTitle.text = "Jailbreak failed at " + Logging.message
    }
    
    @IBAction func rebootButton_hit(_ sender: UIButton) {
        
        // goodbye, maybe?
        kernel_panic()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

