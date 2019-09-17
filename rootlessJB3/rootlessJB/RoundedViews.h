//
//  RoundedViews.h
//  rootlessJB
//
//  Created by Joseph Shenton on 6/2/19.
//  Copyright © 2019 Jake James. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface RoundView : UIView
@property (nonatomic) IBInspectable CGFloat *cornerRadius;
@end

IB_DESIGNABLE
@interface RoundImageView : UIImageView
@property (nonatomic) IBInspectable CGFloat *cornerRadius;
@end

IB_DESIGNABLE
@interface RoundVisualEffectView : UIVisualEffectView
@property (nonatomic) IBInspectable CGFloat *cornerRadius;
@end

IB_DESIGNABLE
@interface RoundButton : UIButton
@property (nonatomic) IBInspectable CGFloat *cornerRadius;
@end

NS_ASSUME_NONNULL_END
