// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>

%hook QADPlayAdInfo
- (id)init {
return nil;
}

%end
