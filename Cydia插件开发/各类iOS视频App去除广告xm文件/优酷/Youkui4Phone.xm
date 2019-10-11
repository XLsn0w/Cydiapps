
#import <UIKit/UIKit.h>
@interface CountDownView : NSObject
- (void)tapHandler:(id)arg1;
@end

%hook YTEngineYoukuPlatformManager

- (BOOL)mAdvertisementEnable {
    return NO;
}

- (void)setMAdvertisementEnable:(BOOL)b {
    %orig(NO);
}

- (BOOL)mOfflineAdvertisementEnable {
    return NO;
}

- (void)setMOfflineAdvertisementEnable:(BOOL)b {
    %orig(NO);
}

- (BOOL)mOverseaAdvertisementEnable {
    return NO;
}

- (void)setMOverseaAdvertisementEnable:(BOOL)b {
    %orig(NO);
}

- (BOOL)mImageAdvertisementEnable {
    return NO;
}

- (void)setMImageAdvertisementEnable:(BOOL)b {
    %orig(NO);
}

- (BOOL)mPreVideoAdEnable {
    return NO;
}

- (void)setMPreVideoAdEnable:(BOOL)b {
    %orig(NO);
}
%end

%hook YTEngineConfigurationItem

- (void)setEnableXAd:(BOOL)b {
    %orig(NO);
}

- (void)setEnableAdCache:(BOOL)b {
    %orig(NO);
}

- (void)setAdDataSource:(id)b {
    %orig(nil);
}
%end

%hook BPManager

- (void)setDisableAdv:(BOOL)b {
    %orig(YES);
}

%end

%hook PlayVideoController

- (void)setDisableAdv:(BOOL)b {
    %orig(YES);
}

%end

%hook OPPlayerDataSource

- (void)setDisableAdv:(BOOL)b {
    %orig(YES);
}

%end

%hook PlayDetailController

- (void)setDisableAdv:(BOOL)b {
    %orig(YES);
}

%end

%hook OPPlayerInstallData

- (void)setDisableAdv:(BOOL)b {
    %orig(YES);
}

%end

%hook VideoEpisodeContentViewCell
- (void)setCardData:(id)obj {
    %orig;
}
%end

%hook Card
- (int)limit {
    return 0;
}

- (void)setLimit:(int)limit {
    %orig(0);
}

- (int)state {
    return 0;
}

- (void)setState:(int)state {
    %orig(0);
}
%end

%hook CountDownView
- (void)startCountDownAnimation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tapHandler:nil];
    });
}
%end
