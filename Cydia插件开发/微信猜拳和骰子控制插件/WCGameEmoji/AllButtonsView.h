
#define LTSWidth [UIScreen mainScreen].bounds.size.width
#define LTSHeight [UIScreen mainScreen].bounds.size.height

#import <UIKit/UIKit.h>

@interface AllButtonsView : UIView
@property (nonatomic, copy) NSString *m_nsToUsr;//收信人

+ (instancetype)sharedInstance;

@end
