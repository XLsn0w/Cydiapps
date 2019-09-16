//
//  ASMultiAppsView.swift
//  ASMultiAppsView
//
//  Created by Lakr Aream on 2019/5/18.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension common_views {
    
    class ASMultiAppsView: UIView {
        
        // Sets
        var images               = [String]()
        var image_size           = CGSize()
        var image_gap            = CGFloat()
        var is_animate           = true
        var image_angle          = CGFloat()
        var image_radius         = CGFloat()
        
        var contentView          = UIView()
        var angle_wrapper        = UIView()
        
        func apart_init(card_width: CGFloat = 466, card_hight: CGFloat = 233,
                        images: [String] = [], animate: Bool = true,
                        image_width: CGFloat = 66, image_hight: CGFloat = 66,
                        image_angle: CGFloat = -23.33, image_gap: CGFloat = 12, image_radius: CGFloat = 8) {
            self.images = images
            self.image_size = CGSize(width: image_width, height: image_hight)
            self.is_animate = animate
            self.image_angle = image_angle
            self.image_gap = image_gap
            self.image_radius = image_radius
            self.bounds.size = CGSize(width: card_width, height: card_hight)
            self.build_view()
            self.angle_wrapper.clipsToBounds = true
            self.contentView.transform = CGAffineTransform(rotationAngle: -90 + self.image_angle)
        }
        
        func build_view() {
            for item in self.subviews {
                item.removeFromSuperview()
            }
            
            self.addSubview(angle_wrapper)
            self.angle_wrapper.snp.makeConstraints { (x) in
                x.edges.equalTo(self.snp.edges)
            }
            
            self.contentView = UIView()
            self.angle_wrapper.addSubview(self.contentView)
            self.contentView.snp.makeConstraints { (x) in
                x.edges.equalTo(angle_wrapper.snp.edges)
            }
            
            // 计算一行的View个数
            let count = Int(self.bounds.width / (self.image_size.width + self.image_gap)) + 2
            // 计算行数
            var lines = Int(self.bounds.height / (self.image_size.height + self.image_gap)) + 1
            
            if image_angle != 0 {
                lines += 3
                self.contentView.snp.remakeConstraints { (x) in
                    x.top.equalTo(self.angle_wrapper.snp.top).offset(-128)
                    x.left.equalTo(self.angle_wrapper.snp.left)
                    x.right.equalTo(self.angle_wrapper.snp.right)
                    x.bottom.equalTo(self.angle_wrapper.snp.bottom).offset(128)
                }
            }
            
            for y in 1...lines {
                let yp = CGFloat(y - 1) * (self.image_size.height + self.image_gap) + self.image_size.height / 2
                // 计算行尾部位置
                var end_of_the_game = CGFloat(count - 1) * (self.image_size.width + self.image_gap) + self.image_size.width / 2
                if y % 2 == 1 {
                    end_of_the_game -= self.image_size.width / 2
                }
                inner: for x in 1...count {
                    // 获取图像，先计算index
                    let index = Int((y * 2 + x) % images.count)
                    let image = self.images[index]
                    // 计算位置
                    var xp = CGFloat(x - 1) * (self.image_size.width + self.image_gap) + self.image_size.width / 2
                    if y % 2 == 1 {
                        xp -= self.image_size.width / 2
                    }
                    let center = CGPoint(x: xp, y: yp)
                    let image_view = UIImageView()
                    image_view.center = center
                    image_view.bounds.size = self.image_size
                    image_view.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "SDWebImagePlaceHolder"))
                    image_view.contentMode = .scaleAspectFill
                    image_view.layer.cornerRadius = self.image_radius
                    image_view.layer.masksToBounds = true
                    self.contentView.addSubview(image_view)
                    
                    if !is_animate {
                        continue inner
                    }
                    
                    let opts: UIView.AnimationOptions = [.curveLinear]
                    UIView.animate(withDuration: TimeInterval(Double(x) * 6.66), delay: 0, options: opts, animations: {
                        image_view.center.x -= CGFloat(x) * (self.image_size.width + self.image_gap)
                    }, completion: { _ in
                        let endx = image_view.center.x
                        image_view.center.x = end_of_the_game
                        self.animate_my_image(start_x: end_of_the_game, end_x: endx, the_element: image_view, x: count)
                    })
                    
                }
            }
            
        }
        
        func animate_my_image(start_x: CGFloat, end_x: CGFloat, the_element: UIImageView, x: Int) {
            
            let opts: UIView.AnimationOptions = [.curveLinear, .repeat]
            UIView.animate(withDuration: TimeInterval(Double(x) * 6.66), delay: 0, options: opts, animations: {
                the_element.center.x = end_x
            })
        }
        
    }

}
