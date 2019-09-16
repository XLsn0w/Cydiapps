//
//  ViewController.swift
//  UnitTest
//
//  Created by Lakr Aream on 2019/7/26.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

let sharedObject = Listener()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedObject.regLinstenersOnMsgPass()
        
    }


}
