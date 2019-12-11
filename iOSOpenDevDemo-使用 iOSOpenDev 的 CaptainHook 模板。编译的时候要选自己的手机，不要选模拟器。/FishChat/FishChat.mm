//
//  FishChat.mm
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/22.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <CaptainHook/CaptainHook.h>
#import <Cycript/Cycript.h>
#import <UIKit/UIKit.h>
#import "FishConfigurationCenter.h"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

#define CYCRIPT_PORT 8888
#define FishConfigurationCenterKey @"FishConfigurationCenterKey"

CHDeclareClass(UIApplication)
CHDeclareClass(MicroMessengerAppDelegate)
CHDeclareClass(CMessageMgr)
CHDeclareClass(FindFriendEntryViewController)
CHDeclareClass(MMTabBarController)
CHDeclareClass(MMBadgeView)
CHDeclareClass(WCDeviceStepObject)
CHDeclareClass(NewMainFrameViewController)
CHDeclareClass(UIView)
CHDeclareClass(NewSettingViewController)
CHDeclareClass(MMTableViewInfo)
CHDeclareClass(MMTableViewSectionInfo)
CHDeclareClass(MMTableViewCellInfo)
CHDeclareClass(MMTableView)
CHDeclareClass(UIViewController)
CHDeclareClass(UILabel)
CHDeclareClass(ChatRoomInfoViewController)

CHOptimizedMethod2(self, void, MicroMessengerAppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    // 监听 Cycript 8888 端口
    NSLog(@"## Start Cycript ##");
    CYListenServer(CYCRIPT_PORT);
    
    NSLog(@"## Load FishConfigurationCenter ##");
    NSData *centerData = [[NSUserDefaults standardUserDefaults] objectForKey:FishConfigurationCenterKey];
    if (centerData) {
        FishConfigurationCenter *center = [NSKeyedUnarchiver unarchivedObjectOfClass:FishConfigurationCenter.class fromData:centerData error:NULL];
        [FishConfigurationCenter loadInstance:center];
    }
}

CHDeclareMethod1(void, MicroMessengerAppDelegate, applicationWillResignActive, UIApplication *, application)
{
    NSData *centerData = [NSKeyedArchiver archivedDataWithRootObject:[FishConfigurationCenter sharedInstance] requiringSecureCoding:NO error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:centerData forKey:FishConfigurationCenterKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 阻止撤回消息
CHOptimizedMethod1(self, void, CMessageMgr, onRevokeMsg, id, msg)
{
    [FishConfigurationCenter sharedInstance].revokeMsg = YES;
    CHSuper1(CMessageMgr, onRevokeMsg, msg);
}

CHDeclareMethod3(void, CMessageMgr, DelMsg, id, arg1, MsgList, id, arg2, DelAll, BOOL, arg3)
{
    if ([FishConfigurationCenter sharedInstance].revokeMsg) {
        [FishConfigurationCenter sharedInstance].revokeMsg = NO;
    }
    else {
        CHSuper3(CMessageMgr, DelMsg, arg1, MsgList, arg2, DelAll, arg3);
    }
}

// 屏蔽消息

NSMutableArray * filtMessageWrapArr(NSMutableArray *msgList) {
    NSMutableArray *msgListResult = [msgList mutableCopy];
    for (id msgWrap in msgList) {
        Ivar nsFromUsrIvar = class_getInstanceVariable(objc_getClass("CMessageWrap"), "m_nsFromUsr");
        NSString *m_nsFromUsr = object_getIvar(msgWrap, nsFromUsrIvar);
        if ([FishConfigurationCenter sharedInstance].chatIgnoreInfo[m_nsFromUsr].boolValue) {
            [msgListResult removeObject:msgWrap];
        }
    }
    return [msgListResult autorelease];
}

CHDeclareClass(BaseMsgContentViewController)
CHDeclareMethod1(void, BaseMsgContentViewController, viewDidAppear, BOOL, animated)
{
    CHSuper1(BaseMsgContentViewController, viewDidAppear, animated);
    id contact = [self GetContact];
    [FishConfigurationCenter sharedInstance].currentUserName = [contact valueForKey:@"m_nsUsrName"];
}

CHDeclareMethod0(void, ChatRoomInfoViewController, reloadTableData)
{
    CHSuper0(ChatRoomInfoViewController, reloadTableData);
    NSString *userName = [FishConfigurationCenter sharedInstance].currentUserName;
    MMTableViewInfo *tableInfo = [self valueForKeyPath:@"m_tableViewInfo"];
    MMTableViewSectionInfo *sectionInfo = [tableInfo getSectionAt:2];
    MMTableViewCellInfo *ignoreCellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(handleIgnoreChatRoom:) target:[FishConfigurationCenter sharedInstance] title:@"屏蔽群消息" on:[FishConfigurationCenter sharedInstance].chatIgnoreInfo[userName].boolValue];
    [sectionInfo addCell:ignoreCellInfo];
    MMTableView *tableView = [tableInfo getTableView];
    [tableView reloadData];
}

CHDeclareClass(AddContactToChatRoomViewController)

CHDeclareMethod0(void, AddContactToChatRoomViewController, reloadTableData)
{
    CHSuper0(AddContactToChatRoomViewController, reloadTableData);
    NSString *userName = [FishConfigurationCenter sharedInstance].currentUserName;
    MMTableViewInfo *tableInfo = [self valueForKeyPath:@"m_tableViewInfo"];
    MMTableViewSectionInfo *sectionInfo = [tableInfo getSectionAt:1];
    MMTableViewCellInfo *ignoreCellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(handleIgnoreChatRoom:) target:[FishConfigurationCenter sharedInstance] title:@"屏蔽此傻逼" on:[FishConfigurationCenter sharedInstance].chatIgnoreInfo[userName].boolValue];
    [sectionInfo addCell:ignoreCellInfo];
    MMTableView *tableView = [tableInfo getTableView];
    [tableView reloadData];
}

CHDeclareMethod6(id, CMessageMgr, GetMsgByCreateTime, id, arg1, FromID, unsigned int, arg2, FromCreateTime, unsigned int, arg3, Limit, unsigned int, arg4, LeftCount, unsigned int*, arg5, FromSequence, unsigned int, arg6)
{
    NSLog(@"GetMsgByCreateTime:%@ FromID:%d FromCreateTime:%d Limit:%d FromSequence:%d",arg1,arg2,arg3,arg4,arg6);
    id result = CHSuper6(CMessageMgr, GetMsgByCreateTime, arg1, FromID, arg2, FromCreateTime, arg3, Limit, arg4, LeftCount, arg5, FromSequence, arg6);
    NSLog(@"msgresult:%@",result);
    if ([FishConfigurationCenter sharedInstance].chatIgnoreInfo[arg1].boolValue) {
        return filtMessageWrapArr(result);
    }
    return result;
}

CHDeclareClass(CSyncBaseEvent)
CHDeclareMethod2(BOOL, CSyncBaseEvent, BatchAddMsg, BOOL, arg1, ShowPush, BOOL, arg2)
{
    NSMutableArray *msgList = [self valueForKeyPath:@"m_arrMsgList"];
    NSMutableArray *msgListResult = filtMessageWrapArr(msgList);
    [self setValue:msgListResult forKeyPath:@"m_arrMsgList"];
    return CHSuper2(CSyncBaseEvent, BatchAddMsg, arg1, ShowPush, arg2);
}

//CHDeclareMethod2(id, CMessageMgr, GetMsg, id, arg1, LocalID, unsigned int, arg2)
//{
//    NSLog(@"GetMsg:%@ LocalID:%d",arg1,arg2);
//    NSLog(@"originalIMP:%p",$CMessageMgr_GetMsg$LocalID$_super);
//    NSLog(@"%@",[NSThread callStackSymbols]);
//    return CHSuper2(CMessageMgr, GetMsg, arg1, LocalID, arg2);
//}

// 关闭朋友圈入口
CHOptimizedMethod2(self, CGFloat, FindFriendEntryViewController, tableView, UITableView *, tableView, heightForRowAtIndexPath, NSIndexPath *, indexPath)
{
    NSIndexPath *timelineIndexPath = [self valueForKeyPath:@"m_WCTimeLineIndexPath"];
    if (indexPath.section != 4) {
        NSLog(@"## Hide Time Line Entry ##");
        return 0;
    }
    return CHSuper2(FindFriendEntryViewController, tableView, tableView, heightForRowAtIndexPath, indexPath);
}

CHOptimizedMethod2(self, CGFloat, FindFriendEntryViewController, tableView, UITableView *, tableView, heightForHeaderInSection, NSInteger, section)
{
    return 0;
}

CHOptimizedMethod2(self, UITableViewCell *, FindFriendEntryViewController, tableView, UITableView *, tableView, cellForRowAtIndexPath, NSIndexPath *, indexPath)
{
    NSIndexPath *timelineIndexPath = [self valueForKeyPath:@"m_WCTimeLineIndexPath"];
    UITableViewCell *cell = CHSuper2(FindFriendEntryViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (indexPath.section != 4) {
        NSLog(@"## Hide Time Line Entry ##");
        cell.hidden = YES;
        for (UIView *subview in cell.subviews) {
            [subview removeFromSuperview];
        }
    }
    return cell;
}

CHOptimizedMethod1(self, void, FindFriendEntryViewController, viewDidAppear, BOOL, animated)
{
    CHSuper1(FindFriendEntryViewController, viewDidAppear, animated);
    [self performSelector:@selector(reloadData)];
}

// 去掉 TabBar 小红点

CHOptimizedMethod2(self, void, MMTabBarController, setTabBarBadgeImage, id, arg1, forIndex, unsigned int, arg2)
{
    if (arg2 != 2 && arg2 != 3) {
        CHSuper2(MMTabBarController, setTabBarBadgeImage, arg1, forIndex, arg2);
    }
}

CHOptimizedMethod2(self, void, MMTabBarController, setTabBarBadgeString, id, arg1, forIndex, unsigned int, arg2)
{
    if (arg2 != 2 && arg2 != 3) {
        CHSuper2(MMTabBarController, setTabBarBadgeString, arg1, forIndex, arg2);
    }
}

CHOptimizedMethod2(self, void, MMTabBarController, setTabBarBadgeValue, id, arg1, forIndex, unsigned int, arg2)
{
    if (arg2 != 2 && arg2 != 3) {
        CHSuper2(MMTabBarController, setTabBarBadgeValue, arg1, forIndex, arg2);
    }
}

// 去掉各种小红点

CHOptimizedMethod1(self, void, UIView, didAddSubview, UIView *, subview)
{
    if ([subview isKindOfClass:NSClassFromString(@"MMBadgeView")]) {
        subview.hidden = YES;
    }
}

// 微信运动步数

CHOptimizedMethod0(self, unsigned int, WCDeviceStepObject, m7StepCount)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[FishConfigurationCenter sharedInstance].lastChangeStepCountDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    BOOL modifyToday = NO;
    if([today isEqualToDate:otherDate]) {
        modifyToday = YES;
    }
    if ([FishConfigurationCenter sharedInstance].stepCount == 0 || !modifyToday) {
        [FishConfigurationCenter sharedInstance].stepCount = CHSuper0(WCDeviceStepObject, m7StepCount);
    }
    return (int)[FishConfigurationCenter sharedInstance].stepCount;
}

// 设置

CHDeclareMethod0(void, NewSettingViewController, reloadTableData)
{
    CHSuper0(NewSettingViewController, reloadTableData);
    MMTableViewInfo *tableInfo = [self valueForKeyPath:@"m_tableViewInfo"];
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    MMTableViewCellInfo *nightCellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(handleNightMode:) target:[FishConfigurationCenter sharedInstance] title:@"夜间模式" on:[FishConfigurationCenter sharedInstance].isNightMode];
    [sectionInfo addCell:nightCellInfo];
    MMTableViewCellInfo *stepcountCellInfo = [objc_getClass("MMTableViewCellInfo") editorCellForSel:@selector(handleStepCount:) target:[FishConfigurationCenter sharedInstance] title:@"微信运动步数" margin:300.0 tip:@"请输入步数" focus:NO text:[NSString stringWithFormat:@"%ld", (long)[FishConfigurationCenter sharedInstance].stepCount]];
    [sectionInfo addCell:stepcountCellInfo];
    [tableInfo insertSection:sectionInfo At:0];
    MMTableView *tableView = [tableInfo getTableView];
    [tableView reloadData];
}
//+ (id)editorCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 margin:(double)arg4 tip:(id)arg5 focus:(_Bool)arg6 text:(id)arg7;
// 夜间模式

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

static UIColor *nightBackgroundColor = UIColorFromRGB(0x343434);
static UIColor *nightSeparatorColor = UIColorFromRGB(0x313131);
static UIColor *nightTextColor = UIColorFromRGB(0xffffff);
static UIColor *nightTabBarColor = UIColorFromRGB(0x444444);

void updateColorOfView(UIView *view)
{
    if ([view isKindOfClass:UILabel.class]) {
        UILabel *label = (UILabel *)view;
        [label setBackgroundColor:[UIColor clearColor]];
        label.textColor = nightTextColor;
        label.tintColor = nightTextColor;
    }
    else if ([view isKindOfClass:UIButton.class]) {
        UIButton *button = (UIButton *)view;
        button.tintColor = nightTextColor;
    }
    else {
        [view setBackgroundColor:[UIColor clearColor]];
        for (UIView *subview in view.subviews) {
            updateColorOfView(subview);
        }
    }
}

CHDeclareMethod1(void, UIView, willMoveToSuperview, UIView *, newSuperview)
{
    CHSuper1(UIView,willMoveToSuperview , newSuperview);
    if ([FishConfigurationCenter sharedInstance].isNightMode) {
        updateColorOfView(self);
    }
}

CHDeclareMethod1(void, UIViewController, viewWillAppear, BOOL, animated)
{
    CHSuper1(UIViewController, viewWillAppear, animated);
    if ([FishConfigurationCenter sharedInstance].isNightMode) {
        updateColorOfView([self valueForKeyPath:@"view"]);
        [[self valueForKeyPath:@"view"] setBackgroundColor:nightBackgroundColor];
        [self setValue:nightTabBarColor forKeyPath:@"tabBarController.tabBar.barTintColor"];
        [self setValue:nightTabBarColor forKeyPath:@"tabBarController.tabBar.tintColor"];
    }
}

BOOL compareColor(UIColor *color1, UIColor *color2)
{
    if (color1 == color2) {
        return YES;
    }
    CGFloat red1, red2, green1, green2, blue1, blue2;
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:nil];
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:nil];
    if (fabs(red1-red2)<0.1 && fabs(green1-green2)<0.1 && fabs(blue1-blue2)<0.1) {
        return YES;
    }
    return NO;
}

CHDeclareMethod1(void, UIView, setBackgroundColor, UIColor *, color)
{
    CHSuper1(UIView, setBackgroundColor, color);
    if ([FishConfigurationCenter sharedInstance].isNightMode) {
        if ([self isKindOfClass:UILabel.class]) {
            CHSuper1(UIView, setBackgroundColor, [UIColor clearColor]);
        }
        else if ([self isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)self;
            button.tintColor = nightTextColor;
        }
        else if ([self isKindOfClass:UITableViewCell.class]) {
            CHSuper1(UIView, setBackgroundColor, nightBackgroundColor);
        }
        else if ([self isKindOfClass:UITableView.class]) {
            ((UITableView *)self).separatorColor = nightSeparatorColor;
        }
        else if (!compareColor(color, nightBackgroundColor) && !compareColor(color, nightSeparatorColor) && !compareColor(color, nightTabBarColor)){
            CHSuper1(UIView, setBackgroundColor, [UIColor clearColor]);
        }
    }
}

CHDeclareMethod1(void, UILabel, setTextColor, UIColor *, color)
{
    if ([FishConfigurationCenter sharedInstance].isNightMode) {
        CHSuper1(UILabel, setTextColor, nightTextColor);
        self.tintColor = nightTextColor;
        self.backgroundColor = [UIColor clearColor];
    }
    else {
        CHSuper1(UILabel, setTextColor, color);
    }
}

CHDeclareMethod1(void, UILabel, setText, NSString *, text)
{
    CHSuper1(UILabel, setText, text);
    if ([FishConfigurationCenter sharedInstance].isNightMode) {
        self.textColor = nightTextColor;
        self.tintColor = nightTextColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

CHConstructor // code block that runs immediately upon load
{
	@autoreleasepool
	{
        CHLoadLateClass(MicroMessengerAppDelegate);  // load class (that will be "available later")
		CHHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions); // register hook
        CHLoadLateClass(CMessageMgr);
        CHHook1(CMessageMgr, onRevokeMsg);
        CHLoadLateClass(FindFriendEntryViewController);
        CHHook2(FindFriendEntryViewController, tableView, heightForRowAtIndexPath);
        CHHook2(FindFriendEntryViewController, tableView, cellForRowAtIndexPath);
        CHHook1(FindFriendEntryViewController, viewDidAppear);
        CHLoadLateClass(MMTabBarController);
        CHHook2(MMTabBarController, setTabBarBadgeImage, forIndex);
        CHHook2(MMTabBarController, setTabBarBadgeString, forIndex);
        CHHook2(MMTabBarController, setTabBarBadgeValue, forIndex);
        CHLoadLateClass(WCDeviceStepObject);
        CHHook0(WCDeviceStepObject, m7StepCount);
        CHLoadLateClass(UIView);
        CHHook1(UIView, didAddSubview);
	}
}
