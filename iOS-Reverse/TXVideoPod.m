
#import "TXVideoPod.h"
#import "CaptainHook.h"
#import <UIKit/UIKit.h>

CHDeclareClass(KKAdsViewController);
CHOptimizedMethod(0, self, KKAdsViewController *, KKAdsViewController, init) {
    return nil;
}

CHConstructor {
    CHLoadLateClass(KKAdsViewController);
    CHClassHook(0, KKAdsViewController,init);
}
