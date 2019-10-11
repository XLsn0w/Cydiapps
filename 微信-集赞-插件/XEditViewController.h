
#import "xia0WeChat.h"

@interface XEditViewController : UIViewController

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) void (^endEditing)(NSString *text);

@end
