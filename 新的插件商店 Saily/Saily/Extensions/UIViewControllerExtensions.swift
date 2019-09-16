//
//  UIViewControllerExtension.swift
//  Saily
//
//  Created by mac on 2019/5/11.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UIViewController {
    
    func twitter_animte() {
        // logo mask
        self.view.layer.mask = CALayer()
        self.view.layer.mask?.contents = UIImage(named: "icon_white")!.cgImage
        self.view.layer.mask?.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.view.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view.layer.mask?.position = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        
        // logo mask background view
        let maskBgView = UIView(frame: self.view.frame)
        maskBgView.backgroundColor = UIColor.white
        self.view.addSubview(maskBgView)
        self.view.bringSubviewToFront(maskBgView)
        
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue.init(cgRect: (self.view.layer.mask?.bounds)!)
        let secondBounds = NSValue.init(cgRect: CGRect(x: 0, y: 0, width: 75, height: 75))
        let finalBounds = NSValue.init(cgRect: CGRect(x: 0, y: 0, width: 3888, height: 3888))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut), CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = CAMediaTimingFillMode.forwards
        self.view.layer.mask?.add(transformAnimation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.5,
                       delay: 1.35,
                       options: .curveEaseIn,
                       animations: {
                        maskBgView.alpha = 0.0
        },
                       completion: { _ in
                        self.view.layer.mask?.removeAnimation(forKey: "maskAnimation")
                        self.view.layer.mask = nil
                        maskBgView.removeFromSuperview()
                        UIApplication.shared.keyWindow?.backgroundColor = .white
        })
    }
    
}
