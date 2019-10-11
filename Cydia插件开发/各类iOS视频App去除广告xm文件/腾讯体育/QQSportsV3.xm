// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
@interface TADMediaViewController : UIViewController
- (void)skipCurrentAd;
@end
%hook TADMediaViewController

- (void)viewDidLoad {
    %orig;
    [self skipCurrentAd];
}

%end
