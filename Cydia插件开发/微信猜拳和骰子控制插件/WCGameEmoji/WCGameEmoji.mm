
// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#include <notify.h> // not required; for examples only

#import "XXSendButton.h"
#import "AllButtonsView.h"
#import "WeChatObject.h"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()


@interface WCGameEmoji : NSObject

@end

@implementation WCGameEmoji

-(id)init
{
	if ((self = [super init]))
	{
	}

    return self;
}

@end


@class ClassToHook;

CHDeclareClass(MicroMessengerAppDelegate);
CHDeclareClass(BaseMsgContentViewController);

CHMethod(2, BOOL, MicroMessengerAppDelegate, application, id, arg1, didFinishLaunchingWithOptions, id, arg2)
{
    
    BOOL res = CHSuper(2, MicroMessengerAppDelegate, application, arg1, didFinishLaunchingWithOptions, arg2);

    return res;
}

CHMethod(1, void, BaseMsgContentViewController, viewDidBePushed,BOOL, arg1) {
    
    CHSuper(1, BaseMsgContentViewController, viewDidBePushed,arg1);
    CContact *contact = [self GetContact];
    NSString *m_nsToUsr = [contact valueForKey:@"m_nsUsrName"];
    [AllButtonsView sharedInstance].m_nsToUsr = m_nsToUsr;
    [XXSendButton sharedInstance].hidden = NO;
}

CHMethod(1, void, BaseMsgContentViewController, viewDidBePoped,BOOL, arg1) {
    
    CHSuper(1, BaseMsgContentViewController, viewDidBePoped,arg1);

    [XXSendButton sharedInstance].hidden = YES;

}

CHConstructor // code block that runs immediately upon load
{
	@autoreleasepool
	{
        CHLoadLateClass(MicroMessengerAppDelegate);
        CHClassHook(2, MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions);

        CHLoadLateClass(BaseMsgContentViewController);
        CHClassHook(1, BaseMsgContentViewController, viewDidBePushed); 
        CHClassHook(1, BaseMsgContentViewController, viewDidBePoped);
	}
}
