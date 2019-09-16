//
//  UIViewExtension.swift
//  Saily
//
//  Created by mac on 2019/5/11.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

extension UIView {
    
    func layoutAll() {
        for view in self.subviews {
            view.layoutIfNeeded()
            view.layoutAll()
        }
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach{ self.addSubview($0) }
    }
}

extension UIView {
    
    func setRadiusCGF(radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func setRadiusINT(radius: Int? = nil) {
        if radius == nil {
            self.layer.cornerRadius = self.frame.height / 2
        } else {
            let radius = CGFloat(radius ?? 8)
            self.layer.cornerRadius = radius
        }
        self.layer.masksToBounds = true
    }
}

extension UIView {
    public func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

extension UIView {
    
    func addShadow(ofColor color: UIColor = .clear, radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5) {
        if color == .clear {
            return
        } else {
            layer.shadowColor = color.cgColor
        }
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        self.clipsToBounds = false
    }
    
}

private let kTransform = "transform"
private let kStrokeStart = "strokeStart"
private let kStrokeEnd = "strokeEnd"
private let kOpacity = "opacity"

private class PPShineLayer: CAShapeLayer {
    
}

extension UIView {
    
    // jkpang dev
    
    func shineAnimation() {
        removeOldSubLayers()
        creatNewSubLayers()
    }
    
    fileprivate func animate(circleShape: CAShapeLayer, circleTransform: CAKeyframeAnimation, circleMask: CAShapeLayer, circleMaskTransform: CAKeyframeAnimation, imageShape: CAShapeLayer, imageTransform: CAKeyframeAnimation, lineShapes: [CAShapeLayer], lineStrokeStart: CAKeyframeAnimation, lineStrokeEnd: CAKeyframeAnimation, lineOpacity: CAKeyframeAnimation) {
        
        CATransaction.begin()
        layer.add(imageTransform, forKey: kTransform)
        imageShape.add(imageTransform, forKey: kTransform)
        circleShape.add(circleTransform, forKey: kTransform)
        circleMask.add(circleMaskTransform, forKey: kTransform)
        
        for lineShape in lineShapes {
            lineShape.add(lineOpacity, forKey: kOpacity)
            lineShape.add(lineStrokeEnd, forKey: kStrokeEnd)
            lineShape.add(lineStrokeStart, forKey: kStrokeStart)
        }
        CATransaction.commit()
    }
    
    /// 移除旧layer
    fileprivate func removeOldSubLayers() {
        // 移除上次添加到此layer上的subLayer
        if let subLayers = layer.sublayers {
            for subLayer in subLayers {
                if subLayer.isMember(of: PPShineLayer.classForCoder()) {
                    subLayer.removeFromSuperlayer()
                }
            }
        }
        
        // 移除上次添加在当前View Layer的父Layer上的PPShineLayer
        if let superSublayers = layer.superlayer?.sublayers {
            for subLayer in superSublayers {
                if subLayer.isMember(of: PPShineLayer.classForCoder()) {
                    subLayer.removeFromSuperlayer()
                    break
                }
            }
        }
    }
    
    
    /// 创建动画layer
    fileprivate func creatNewSubLayers(with duration: TimeInterval = 1.0) {
        
        let imageFrame = bounds
        let imgCenterPoint = CGPoint(x: imageFrame.midX, y: imageFrame.midY)
        let lineFrame = CGRect(x: imageFrame.origin.x - imageFrame.width / 4,
                               y: imageFrame.origin.y - imageFrame.height / 4,
                               width: imageFrame.width * 1.8,
                               height: imageFrame.height * 1.8)
        
        // 新建一个容器Layer，添加在当前View Layer的父Layer上，用来添加动画的子layer，避免当前View的layer动画对子layer的影响
        let backgroundLayer = PPShineLayer()
        backgroundLayer.frame = layer.frame
        layer.superlayer?.addSublayer(backgroundLayer)
        
        //===============
        // circle layer
        //===============
        let circleShape = PPShineLayer()
        circleShape.bounds = imageFrame
        circleShape.position = imgCenterPoint
        circleShape.path = UIBezierPath(ovalIn: imageFrame).cgPath
        circleShape.fillColor = LKRoot.ins_color_manager.read_a_color("main_tint_color").cgColor
        circleShape.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
        backgroundLayer.addSublayer(circleShape)
        
        let circleMask = PPShineLayer()
        circleMask.bounds = imageFrame
        circleMask.position = imgCenterPoint
        circleMask.fillRule = .evenOdd
        circleShape.mask = circleMask
        
        let maskPath = UIBezierPath(rect: imageFrame)
        maskPath.addArc(withCenter: imgCenterPoint, radius: 0.1, startAngle: CGFloat(0.0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleMask.path = maskPath.cgPath
        
        //===============
        // line layer
        //===============
        var lineShapes: [PPShineLayer] = []
        for i in 0 ..< 5 {
            let line = PPShineLayer()
            line.bounds = lineFrame
            line.position = imgCenterPoint
            line.masksToBounds = true
            line.actions = [kStrokeStart: NSNull(), kStrokeEnd: NSNull()]
            line.strokeColor = UIColor.random.cgColor
            line.lineWidth = 2
            line.miterLimit = 2
            line.path = {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: lineFrame.midX, y: lineFrame.midY))
                path.addLine(to: CGPoint(x: lineFrame.origin.x + lineFrame.width / 2, y: lineFrame.origin.y))
                return path
            }()
            line.lineCap = CAShapeLayerLineCap.round
            line.lineJoin = CAShapeLayerLineJoin.round
            line.strokeStart = 0.0
            line.strokeEnd = 0.0
            line.opacity = 0.0
            line.transform = CATransform3DMakeRotation(CGFloat(Double.pi) / 5 * (CGFloat(i) * 2 + 1), 0.0, 0.0, 1.0)
            backgroundLayer.addSublayer(line)
            lineShapes.append(line)
        }
        
        //===============
        // image layer
        //===============
        let imageShape = PPShineLayer()
        imageShape.bounds = imageFrame
        imageShape.position = imgCenterPoint
        imageShape.path = UIBezierPath(rect: imageFrame).cgPath
        imageShape.fillColor = UIColor.random.cgColor
        imageShape.actions = ["fillColor": NSNull()]
        backgroundLayer.addSublayer(imageShape)
        
        imageShape.mask = PPShineLayer()
        imageShape.mask?.bounds = imageFrame
        imageShape.mask?.position = imgCenterPoint
        
        //==============================
        // circle transform animation
        //==============================
        let circleTransform = CAKeyframeAnimation(keyPath: kTransform)
        circleTransform.duration = 0.333 * duration// 0.0333 * 10
        circleTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,  0.0,  1.0)),    //  0/10
            NSValue(caTransform3D: CATransform3DMakeScale(0.5,  0.5,  1.0)),    //  1/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.0,  1.0,  1.0)),    //  2/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,  1.2,  1.0)),    //  3/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.3,  1.3,  1.0)),    //  4/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.37, 1.37, 1.0)),    //  5/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0)),    //  6/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0))     // 10/10
        ]
        circleTransform.keyTimes = [
            0.0,    //  0/10
            0.1,    //  1/10
            0.2,    //  2/10
            0.3,    //  3/10
            0.4,    //  4/10
            0.5,    //  5/10
            0.6,    //  6/10
            1.0     // 10/10
        ]
        
        let circleMaskTransform = CAKeyframeAnimation(keyPath: kTransform)
        circleMaskTransform.duration = 0.333 * duration // 0.0333 * 10
        circleMaskTransform.values = [
            NSValue(caTransform3D: CATransform3DIdentity),                                                              //  0/10
            NSValue(caTransform3D: CATransform3DIdentity),                                                              //  2/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 1.25,  imageFrame.height * 1.25,  1.0)),   //  3/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 2.688, imageFrame.height * 2.688, 1.0)),   //  4/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 3.923, imageFrame.height * 3.923, 1.0)),   //  5/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 4.375, imageFrame.height * 4.375, 1.0)),   //  6/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 4.731, imageFrame.height * 4.731, 1.0)),   //  7/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 5.0,   imageFrame.height * 5.0,   1.0)),   //  9/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 5.0,   imageFrame.height * 5.0,   1.0))    // 10/10
        ]
        circleMaskTransform.keyTimes = [
            0.0,    //  0/10
            0.2,    //  2/10
            0.3,    //  3/10
            0.4,    //  4/10
            0.5,    //  5/10
            0.6,    //  6/10
            0.7,    //  7/10
            0.9,    //  9/10
            1.0     // 10/10
        ]
        
        //==============================
        // line stroke animation
        //==============================
        let lineStrokeStart = CAKeyframeAnimation(keyPath: kStrokeStart)
        lineStrokeStart.duration = 0.6 * duration //0.0333 * 18
        lineStrokeStart.values = [
            0.0,    //  0/18
            0.0,    //  1/18
            0.18,   //  2/18
            0.2,    //  3/18
            0.26,   //  4/18
            0.32,   //  5/18
            0.4,    //  6/18
            0.6,    //  7/18
            0.71,   //  8/18
            0.89,   // 17/18
            0.92    // 18/18
        ]
        lineStrokeStart.keyTimes = [
            0.0,    //  0/18
            0.056,  //  1/18
            0.111,  //  2/18
            0.167,  //  3/18
            0.222,  //  4/18
            0.278,  //  5/18
            0.333,  //  6/18
            0.389,  //  7/18
            0.444,  //  8/18
            0.944,  // 17/18
            1.0     // 18/18
        ]
        
        let lineStrokeEnd = CAKeyframeAnimation(keyPath: kStrokeEnd)
        lineStrokeEnd.duration = 0.6 * duration //0.0333 * 18
        lineStrokeEnd.values = [
            0.0,    //  0/18
            0.0,    //  1/18
            0.32,   //  2/18
            0.48,   //  3/18
            0.64,   //  4/18
            0.68,   //  5/18
            0.92,   // 17/18
            0.92    // 18/18
        ]
        lineStrokeEnd.keyTimes = [
            0.0,    //  0/18
            0.056,  //  1/18
            0.111,  //  2/18
            0.167,  //  3/18
            0.222,  //  4/18
            0.278,  //  5/18
            0.944,  // 17/18
            1.0     // 18/18
        ]
        
        let lineOpacity = CAKeyframeAnimation(keyPath: kOpacity)
        lineOpacity.duration = 1.0 * duration //0.0333 * 30
        lineOpacity.values = [
            1.0,    //  0/30
            1.0,    // 12/30
            0.0     // 17/30
        ]
        lineOpacity.keyTimes = [
            0.0,    //  0/30
            0.4,    // 12/30
            0.567   // 17/30
        ]
        
        //==============================
        // image transform animation
        //==============================
        let imageTransform = CAKeyframeAnimation(keyPath: kTransform)
        imageTransform.duration = 1.0 * duration //0.0333 * 30
        imageTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)),  //  0/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)),  //  3/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)),  //  9/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.25,  1.25,  1.0)),  // 10/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)),  // 11/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)),  // 14/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),  // 15/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),  // 16/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)),  // 17/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),  // 20/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.025, 1.025, 1.0)),  // 21/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),  // 22/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)),  // 25/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.95,  0.95,  1.0)),  // 26/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)),  // 27/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.99,  0.99,  1.0)),  // 29/30
            NSValue(caTransform3D: CATransform3DIdentity)                       // 30/30
        ]
        imageTransform.keyTimes = [
            0.0,    //  0/30
            0.1,    //  3/30
            0.3,    //  9/30
            0.333,  // 10/30
            0.367,  // 11/30
            0.467,  // 14/30
            0.5,    // 15/30
            0.533,  // 16/30
            0.567,  // 17/30
            0.667,  // 20/30
            0.7,    // 21/30
            0.733,  // 22/30
            0.833,  // 25/30
            0.867,  // 26/30
            0.9,    // 27/30
            0.967,  // 29/30
            1.0     // 30/30
        ]
        
        let layerTransform = CAKeyframeAnimation(keyPath: kTransform)
        layerTransform.duration = 1.0 * duration //0.0333 * 30
        
        animate(circleShape: circleShape, circleTransform: circleTransform, circleMask: circleMask, circleMaskTransform: circleMaskTransform, imageShape: imageShape, imageTransform: imageTransform, lineShapes: lineShapes, lineStrokeStart: lineStrokeStart, lineStrokeEnd: lineStrokeEnd, lineOpacity: lineOpacity)
    }
}
