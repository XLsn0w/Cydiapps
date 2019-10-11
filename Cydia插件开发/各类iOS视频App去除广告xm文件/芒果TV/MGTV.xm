#import <UIKit/UIKit.h>

@interface MGOnlineADNetManager : NSObject
- (void)playerOver;
@end

@interface MGOfflineADNetManager : NSObject
- (void)playerOver;
@end

%hook MgMiLaunchView
- (id)initWithFrame:(CGRect)frame {
    return nil;
}
%end

%hook MGOnlineADNetManager
- (void)playAD {
    [self playerOver];
}
%end

%hook MGOfflineADNetManager
- (void)playOfflineAD {
    [self playerOver];
}
%end
