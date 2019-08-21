//
//  UIViewController+Unwind.h
//  iSH
//
//  Created by Theodore Dubois on 9/23/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Unwind)

- (IBAction)unwind:(UIStoryboardSegue *)segue;

@end

NS_ASSUME_NONNULL_END
