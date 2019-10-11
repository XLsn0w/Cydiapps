
#import <UIKit/UIKit.h>

#import "WBSettingViewController.h"

#import "WeChatRedEnvelopParam.h"
#import "WBReceiveRedEnvelopOperation.h"
#import "WBRedEnvelopTaskManager.h"
#import "WBRedEnvelopConfig.h"
#import "WBRedEnvelopParamQueue.h"

#import "XXXSendButton.h"

#pragma mark -- 设置页入口
%hook MicroMessengerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return %orig;
}
%end

%hook NewSettingViewController

- (void)reloadTableData {
    %orig;
    
    WCTableViewManager *tableViewMgr = MSHookIvar<id>(self, "m_tableViewMgr");
    
    WCTableViewSectionManager *sectionInfo = [%c(WCTableViewSectionManager) defaultSection];
    
    WCTableViewCellManager *settingCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(setting) target:self title:@"微信助手"];
    [sectionInfo addCell:settingCell];
    
    [tableViewMgr insertSection:sectionInfo At:0];
    
    MMTableView *tableView = [tableViewMgr getTableView];
    [tableView reloadData];
}

%new
- (void)setting {
    WBSettingViewController *settingViewController = [WBSettingViewController new];
    [self.navigationController PushViewController:settingViewController animated:YES];
}
%end

#pragma mark -- 抢红包

%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2 {
    
    %orig;
    
    // 非参数查询请求
    if (arg1.cgiCmdid != 3) { return; }
    
    NSString *(^parseRequestSign)() = ^NSString *() {
        NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
        NSDictionary *requestDictionary = [%c(WCBizUtil) dictionaryWithDecodedComponets:requestString separator:@"&"];
        NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
        NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
        
        return [nativeUrlDict stringForKey:@"sign"];
    };
    
    NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
    
    WeChatRedEnvelopParam *mgrParams = [[WBRedEnvelopParamQueue sharedQueue] dequeue];
    
    BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
        
        // 手动抢红包
        if (!mgrParams) { return NO; }
        
        // 自己已经抢过
        if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }
        
        // 红包被抢完
        if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }
        
        // 没有这个字段会被判定为使用外挂
        if (!responseDict[@"timingIdentifier"]) { return NO; }
        
        if (mgrParams.isGroupSender) { // 自己发红包的时候没有 sign 字段
            return [WBRedEnvelopConfig sharedConfig].autoReceiveEnable;
        } else {
            return [parseRequestSign() isEqualToString:mgrParams.sign] && [WBRedEnvelopConfig sharedConfig].autoReceiveEnable;
        }
    };
    
    if (shouldReceiveRedEnvelop()) {
        mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];
        
        unsigned int delaySeconds = [self calculateDelaySeconds];
        WBReceiveRedEnvelopOperation *operation = [[WBReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:delaySeconds];
        [[WBRedEnvelopTaskManager sharedManager] addNormalTask:operation];
    }
}

%new
- (unsigned int)calculateDelaySeconds {
    NSInteger configDelaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    return (unsigned int)configDelaySeconds;
}

%end

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
    %orig;
    
    switch(wrap.m_uiMessageType) {
        case 49: { // AppNode
            
            /** 是否为红包消息 */
            BOOL (^isRedEnvelopMessage)() = ^BOOL() {
                return [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
            };
            
            if (isRedEnvelopMessage()) { // 红包
                CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
                CContact *selfContact = [contactManager getSelfContact];
                
                BOOL (^isSender)() = ^BOOL() {
                    return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
                };
                
                /** 是否别人在群聊中发消息 */
                BOOL (^isGroupReceiver)() = ^BOOL() {
                    return [wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
                };
                
                /** 是否自己在群聊中发消息 */
                BOOL (^isGroupSender)() = ^BOOL() {
                    return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
                };
                
                /** 是否抢自己发的红包 */
                BOOL (^isReceiveSelfRedEnvelop)() = ^BOOL() {
                    return NO;
                };
                
                /** 是否在黑名单中 */
                BOOL (^isGroupInBlackList)() = ^BOOL() {
                    return NO;
                };
                
                /** 是否自动抢红包 */
                BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
                    if (![WBRedEnvelopConfig sharedConfig].autoReceiveEnable) { return NO; }
                    if (isGroupInBlackList()) { return NO; }
                    
                    return isGroupReceiver() || (isGroupSender() && isReceiveSelfRedEnvelop());
                };
                
                NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
                    nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                    return [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
                };
                
                /** 获取服务端验证参数 */
                void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                    NSMutableDictionary *params = [@{} mutableCopy];
                    params[@"agreeDuty"] = @"0";
                    params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
                    params[@"inWay"] = @"0";
                    params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
                    params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];
                    
                    WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
                    [logicMgr ReceiverQueryRedEnvelopesRequest:params];
                };
                
                /** 储存参数 */
                void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                    WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
                    mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
                    mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
                    mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
                    mgrParams.nickName = [selfContact getContactDisplayName];
                    mgrParams.headImg = [selfContact m_nsHeadImgUrl];
                    mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
                    mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];
                    
                    mgrParams.isGroupSender = isGroupSender();
                    
                    [[WBRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
                };
                
                if (shouldReceiveRedEnvelop()) {
                    NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);
                    
                    queryRedEnvelopesReqeust(nativeUrlDict);
                    enqueueParam(nativeUrlDict);
                }
            }
            break;
        }
        default:
        break;
    }
    
}

- (void)onRevokeMsg:(CMessageWrap *)arg1 {
    
    if (![WBRedEnvelopConfig sharedConfig].revokeEnable) {
        %orig;
    } else {
        if ([arg1.m_nsContent rangeOfString:@"<session>"].location == NSNotFound) { return; }
        if ([arg1.m_nsContent rangeOfString:@"<replacemsg>"].location == NSNotFound) { return; }
        
        NSString *(^parseSession)() = ^NSString *() {
            NSUInteger startIndex = [arg1.m_nsContent rangeOfString:@"<session>"].location + @"<session>".length;
            NSUInteger endIndex = [arg1.m_nsContent rangeOfString:@"</session>"].location;
            NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
            return [arg1.m_nsContent substringWithRange:range];
        };
        
        NSString *(^parseSenderName)() = ^NSString *() {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<!\\[CDATA\\[(.*?)撤回了一条消息\\]\\]>" options:NSRegularExpressionCaseInsensitive error:nil];
            
            NSRange range = NSMakeRange(0, arg1.m_nsContent.length);
            NSTextCheckingResult *result = [regex matchesInString:arg1.m_nsContent options:0 range:range].firstObject;
            if (result.numberOfRanges < 2) { return nil; }
            
            return [arg1.m_nsContent substringWithRange:[result rangeAtIndex:1]];
        };
        
        CMessageWrap *msgWrap = [[%c(CMessageWrap) alloc] initWithMsgType:0x2710];
        BOOL isSender = [%c(CMessageWrap) isSenderFromMsgWrap:arg1];
        
        NSString *sendContent;
        if (isSender) {
            [msgWrap setM_nsFromUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsToUsr:arg1.m_nsFromUsr];
            sendContent = @"你撤回一条消息";
        } else {
            [msgWrap setM_nsToUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsFromUsr:arg1.m_nsFromUsr];
            
            NSString *name = parseSenderName();
            sendContent = [NSString stringWithFormat:@"拦截 %@ 的一条撤回消息", name ? name : arg1.m_nsFromUsr];
        }
        [msgWrap setM_uiStatus:0x4];
        [msgWrap setM_nsContent:sendContent];
        [msgWrap setM_uiCreateTime:[arg1 m_uiCreateTime]];
        
        [self AddLocalMsg:parseSession() MsgWrap:msgWrap fixTime:0x1 NewMsgArriveNotify:0x0];
    }
}

%end

#pragma mark -- 点赞
NSMutableArray *starsArray(NSArray *origLikeUsers) {
    NSLog(@"6666666666 %@", origLikeUsers);

    NSMutableArray *addStars = [[NSMutableArray alloc] initWithArray:origLikeUsers];
    
    NSArray *allUserNameArray = [[[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getAllContactUserName] allObjects];
    NSLog(@"7777777777 %@", allUserNameArray);

    for (int i = 0; i < [WBRedEnvelopConfig sharedConfig].starsCount; i++) {
        NSString *userName = allUserNameArray[arc4random() % [allUserNameArray count]];
        CContact *contact = [[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getContactByName:userName];
        if (!contact) {
            continue;
        }
        NSString *nickName = [contact m_nsNickName];
        
        WCUserComment *userComment = [[%c(WCUserComment) alloc] init];
        userComment.username = userName;
        userComment.nickname = nickName;
        userComment.type = 1;
        userComment.isRichText = 1;
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSInteger nowTime = interval;
        userComment.createTime = nowTime;
        
        [addStars addObject:userComment];
    }
    
    return addStars;
}


NSMutableArray *commentArray(NSArray *origCommentUsers){
    NSMutableArray *addComment = [[NSMutableArray alloc] initWithArray:origCommentUsers];
    
    NSArray* allUserNameArray = [[[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getAllContactUserName] allObjects];
    
    NSArray *commentContent = @[@"高级", @"点赞就完事了", @"6666", @"赞~", @"这个不错",@"什么鬼东西= = ", @"你说的就是这个？" ,@"牛皮", @"来了~~", @"牛b"];
    
    
    for (int i = 0; i < [WBRedEnvelopConfig sharedConfig].commentCount; i++) {
        NSString *userName = allUserNameArray[arc4random() % [allUserNameArray count]];
        CContact *contact = [[[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]] getContactByName:userName];
        if (!contact) {
            continue;
        }
        NSString *nickName = [contact m_nsNickName];
        
        WCUserComment *userComment = [[%c(WCUserComment) alloc] init];
        userComment.username = userName;
        userComment.nickname = nickName;
        userComment.type = 2;
        userComment.commentID = [NSString stringWithFormat:@"%d", origCommentUsers.count + i];
        NSTimeInterval interval=[[NSDate date] timeIntervalSince1970];
        NSInteger nowTime = interval;
        userComment.createTime = nowTime;
        
        NSString *comment = commentContent[arc4random() % [commentContent count]];
        userComment.content = comment;
        
        [addComment addObject:userComment];
    }
    
    return addComment;
}

// more zan in timeline detail
%hook WCCommentDetailViewControllerFB

- (void)setDataItem:(WCDataItem *)dataItem {
    NSString *myName = [%c(SettingUtil) getCurUsrName];
    if ([dataItem.username isEqualToString:myName]) {
        dataItem.likeUsers = starsArray(dataItem.likeUsers);
        dataItem.likeCount = [dataItem.likeUsers count];
        dataItem.commentUsers = commentArray(dataItem.commentUsers);
        dataItem.commentCount = [dataItem.commentUsers count];
    }
    
    return %orig(dataItem);
}

%end

%hook WCTimelineMgr
- (void)onDataUpdated:(id)arg1 andData:(id)arg2 andAdData:(id)arg3 withChangedTime:(unsigned int)arg4 {
    NSLog(@"1111111111 %@", arg2);
    NSMutableArray *data = [[NSMutableArray alloc] initWithArray:arg2];
    NSLog(@"2222222222 %@", data);

    NSString *myName = [%c(SettingUtil) getCurUsrName];
    NSLog(@"3333333333 %@", myName);
    for (WCDataItem *item in data){
        NSLog(@"4444444444 %@", item.username);

        if ([item.username isEqualToString:myName]) {
            NSLog(@"5555555555 %@", item.username);

            item.likeUsers = starsArray(item.likeUsers);
            item.likeCount = [item.likeUsers count];
            
            item.commentUsers = commentArray(item.commentUsers);
            item.commentCount = [item.commentUsers count];
        }
        
    }
    return %orig(arg1, data, arg3, arg4);
}
%end

#pragma mark -- 猜拳 筛子
%hook BaseMsgContentViewController
- (void)viewDidBePushed:(BOOL)arg1 {
    %orig;
    if ([WBRedEnvelopConfig sharedConfig].gameEnable) {
        CContact *contact = [self GetContact];
        NSString *m_nsToUsr = [contact valueForKey:@"m_nsUsrName"];
        [XXXAllButtonsView sharedInstance].m_nsToUsr = m_nsToUsr;
        [XXXSendButton sharedInstance].hidden = NO;
    }
}

- (void)viewDidBePoped:(BOOL)arg1 {
    %orig;
    [XXXSendButton sharedInstance].hidden = YES;
}

%end
