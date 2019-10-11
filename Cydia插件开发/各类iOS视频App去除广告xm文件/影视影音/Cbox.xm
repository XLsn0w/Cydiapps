// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

%hook LaunchView
+ (id)shareInstance {
    return nil;
}

- (id)init {
    return nil;
}
%end

%hook CNAdPlayerView
- (id)initWithFrame:(CGRect)arg1 {
    return nil;
}
%end
