// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>

%hook AdsProxy
+ (void)onPlayCardShow:(unsigned int)arg1 event:(int)arg2 {
return;
}
+ (id)GetExportLog_oc {
return nil;

}
+ (void)DeleteOfflineAdsWithEpisodeId_oc:(id)arg1 {
return;

}
+ (void)ShutDownCupidEpisode_oc:(unsigned int)arg1 {
return;

}
+ (id)GetSdkVersion_oc {
return nil;

}
+ (void)SetSdkStatus_oc:(id)arg1 {
return;
}
+ (void)OnVVEventWithVVId_oc:(unsigned int)arg1 event:(int)arg2{
return;
}
+ (id)GetAdExtraInfoWithAdId_oc:(unsigned int)arg1{
return nil;
}
+ (void)OnCreativeEventWithAdId_oc:(unsigned int)arg1 event:(int)arg2 index:(int)arg3 url:(id)arg4 {
return;
}
+ (void)UpdateAdProgress:(unsigned int)arg1 progress:(unsigned int)arg2 {
return;
}
+ (void)OnAdEventWithAdId_oc:(unsigned int)arg1 event:(int)arg2 properties:(id)arg3 {
return;
}
+ (void)OnAdEventWithAdId_oc:(unsigned int)arg1 event:(int)arg2 {
return;
}
+ (void)DeregisterObjectAppDelegateWithVVId_oc:(unsigned int)arg1 slotType:(int)arg2 delegate:(id)arg3 {
return;
}
+ (void)RegisterObjectAppDelegateWithVVId_oc:(unsigned int)arg1 slotType:(int)arg2 delegate:(id)arg3 {
return;
}
+ (void)DeregisterJsonDelegateWithVVId_oc:(unsigned int)arg1 slotType:(int)arg2 delegate:(id)arg3 {
return;
}
+ (void)RegisterJsonDelegateWithVVId_oc:(unsigned int)arg1 slotType:(int)arg2 delegate:(id)arg3 {
return;
}
+ (void)SetMemberStatus_oc:(id)arg1 {
return;
}
+ (unsigned int)InitCupidEpisode_oc:(id)arg1 {
return 0;
}
%end

%hook QYPhoneStartADManager
- (BOOL)shouldShowAd {
    return NO;
}
%end
