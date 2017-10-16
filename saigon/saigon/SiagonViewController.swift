//
//  ViewController.swift
//  saïgon
//
//  Created by Abraham Masri @cheesecakeufo
//  Copyright © 2017 Abraham Masri. Thanks Ian Beer & Adam Donenfeld!!
//

import UIKit
import Foundation

struct Logging {
    static var message = ""
}

@objc class SiagonViewController: UIViewController {
    
    
    @IBOutlet weak var tryButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var jbButtonWidth: NSLayoutConstraint!
    
    
    var autoRespring = false
    var mach_port : mach_port_t = mach_port_t(MACH_PORT_NULL)
    
    let gradient = CAGradientLayer()
    
    let gradientOne = UIColor(red:0.24, green:0.04, blue:0.29, alpha:1.0).cgColor
    let gradientTwo = UIColor(red:0.77, green:0.00, blue:0.34, alpha:1.0).cgColor
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        // Gradient background
        let gradient = CAGradientLayer()
        
        gradient.frame = view.bounds
        gradient.colors = [gradientOne, gradientTwo]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        if ami_jailbroken() == 1 {
            tryButton.isEnabled = false;
            jbButtonWidth.constant += 100
            tryButton.frame = CGRect(x: self.tryButton.frame.origin.x, y: self.tryButton.frame.origin.y, width: self.tryButton.frame.width + 60, height: self.tryButton.frame.height)
            tryButton.setTitle("you're already jailbroken",for: .disabled)
            tryButton.alpha = 0.4
            tryButton.backgroundColor = UIColor(white: 1, alpha: 0.0)
            return;
        }
    
        if offsets_init() == 1 {
            tryButton.isEnabled = false;
            jbButtonWidth.constant += 100
            tryButton.frame = CGRect(x: self.tryButton.frame.origin.x, y: self.tryButton.frame.origin.y, width: self.tryButton.frame.width + 60, height: self.tryButton.frame.height)
            tryButton.setTitle("device not supported",for: .disabled)
            tryButton.alpha = 0.4
            tryButton.backgroundColor = UIColor(white: 1, alpha: 0.0)
        }
        
    }
    
    
    func run() {
        
        let queue = DispatchQueue.global()
        let workItem = DispatchWorkItem(qos: .userInitiated, flags: .assignCurrentContext) {
            
            // Do stuff
            self.mach_port = mach_port_t(do_exploit())
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if self.mach_port == mach_port_t(MACH_PORT_NULL) {
                    
                    // We failed :(
                    Logging.message = "escaping sandbox"
                    self.present(UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "FailedViewController"), animated:true, completion:nil)
                    
                } else {
                    self.post_run()
                }
            })
        }
        queue.async(execute: workItem)
    }
    
    func post_run() {
        
        self.progressView.setProgress(0.3, animated: true)
        self.tryButton.setTitle("patching amfid..",for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            
            
            self.progressView.setProgress(1.0, animated: true)
            
            if prepare_amfid(self.mach_port) == 1 {
                
                self.progressView.setProgress(0.5, animated: true)
                self.tryButton.setTitle("privilege escalation..",for: .normal)
                
                // Run ziVA
                if ziva_go(self.mach_port) == 1 {
                    
                    self.progressView.setProgress(0.9, animated: true)
                    self.tryButton.setTitle("bypassing kpp..",for: .normal)
                    
                    // Run extra_recipe (final step)
                    if go_extra_recipe() == 1 {
                        self.progressView.setProgress(1.0, animated: true)
                        self.tryButton.isEnabled = false
                        self.tryButton.setTitle("done 🎉",for: .disabled)
                    } else {
                        Logging.message = "bypassing KPP"
                        self.showFailure()
                    }
                    
                } else {
                    Logging.message = "privilege escalation"
                    self.showFailure()
                }
            } else {
                Logging.message = "patching amfid"
                self.showFailure()
            }
        })
        
    }
    
    @IBAction func runbutton_hit(_ sender: UIButton) {
        
        jbButtonWidth.constant += 100
        sender.frame = CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y, width: sender.frame.width + 60, height: sender.frame.height)
        sender.isEnabled = false
        sender.setTitle("escaping sandbox..",for: .normal)
        sender.alpha = 0.4
        sender.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
        progressView.isHidden = false
        progressView.setProgress(0.1, animated: true)
        
        run()
        
    }
    
    func showFailure() {
        // We failed badly :(
        self.present(UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "FailedViewController")    , animated:true, completion:nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


