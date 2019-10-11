#line 1 "/Users/in8/Downloads/tweak/钉钉/DingTalkRedEnvelop/DingTalkRedEnvelop/DingTalkRedEnvelop.xm"


#import <UIKit/UIKit.h>

#define kRedEnvelopTitle @"红包开关"
#define kRedEnvelopSwitch @"kRedEnvelopSwitch"

@interface DTRedEnvelopServiceIMP : NSObject
- (void)pickRedEnvelopCluster:(long long)arg1 clusterId:(id)arg2 successBlock:(id)arg3 failureBlock:(id)arg4;
@end

@interface WKBizConversation : NSObject
@property(retain, nonatomic) NSString *latestMessageJson; 
@end

@interface DTCellItem : NSObject
@property(copy, nonatomic) NSString *title; 
+ (id)cellItemForSwitcherStyleWithTitle:(id)arg1 isSwitcherOn:(_Bool)arg2 switcherValueDidChangeBlock:(id)arg3;

@end

@interface DTSectionItem : NSObject
@property(copy, nonatomic) NSArray *dataSource; 
@end

@interface DTTableViewDataSource : NSObject
@property(copy, nonatomic) NSArray *tableViewDataSource; 

@end

@interface DTTableViewHandler : NSObject
@property(retain, nonatomic) DTTableViewDataSource *dataSource; 
@property(nonatomic, weak) id delegate; 
@end

@interface DTSettingViewController : UIViewController
@property(strong, nonatomic) DTTableViewHandler *tableViewHandler; 

@end
static DTRedEnvelopServiceIMP *redEnvelopService = nil;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class DTConversationListDataSource; @class DTRedEnvelopServiceIMP; @class DTTableViewHandler; 
static DTRedEnvelopServiceIMP* (*_logos_orig$_ungrouped$DTRedEnvelopServiceIMP$init)(_LOGOS_SELF_TYPE_INIT DTRedEnvelopServiceIMP*, SEL) _LOGOS_RETURN_RETAINED; static DTRedEnvelopServiceIMP* _logos_method$_ungrouped$DTRedEnvelopServiceIMP$init(_LOGOS_SELF_TYPE_INIT DTRedEnvelopServiceIMP*, SEL) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$DTConversationListDataSource$controller$didChangeObject$atIndex$forChangeType$newIndex$)(_LOGOS_SELF_TYPE_NORMAL DTConversationListDataSource* _LOGOS_SELF_CONST, SEL, id, id, unsigned long long, long long, unsigned long long); static void _logos_method$_ungrouped$DTConversationListDataSource$controller$didChangeObject$atIndex$forChangeType$newIndex$(_LOGOS_SELF_TYPE_NORMAL DTConversationListDataSource* _LOGOS_SELF_CONST, SEL, id, id, unsigned long long, long long, unsigned long long); static void (*_logos_orig$_ungrouped$DTTableViewHandler$setDataSource$)(_LOGOS_SELF_TYPE_NORMAL DTTableViewHandler* _LOGOS_SELF_CONST, SEL, DTTableViewDataSource *); static void _logos_method$_ungrouped$DTTableViewHandler$setDataSource$(_LOGOS_SELF_TYPE_NORMAL DTTableViewHandler* _LOGOS_SELF_CONST, SEL, DTTableViewDataSource *); 

#line 42 "/Users/in8/Downloads/tweak/钉钉/DingTalkRedEnvelop/DingTalkRedEnvelop/DingTalkRedEnvelop.xm"

static DTRedEnvelopServiceIMP* _logos_method$_ungrouped$DTRedEnvelopServiceIMP$init(_LOGOS_SELF_TYPE_INIT DTRedEnvelopServiceIMP* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    id obj = _logos_orig$_ungrouped$DTRedEnvelopServiceIMP$init(self, _cmd);
    redEnvelopService = obj;
    return obj;
}



static void _logos_method$_ungrouped$DTConversationListDataSource$controller$didChangeObject$atIndex$forChangeType$newIndex$(_LOGOS_SELF_TYPE_NORMAL DTConversationListDataSource* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2, unsigned long long arg3, long long arg4, unsigned long long arg5) {
    _logos_orig$_ungrouped$DTConversationListDataSource$controller$didChangeObject$atIndex$forChangeType$newIndex$(self, _cmd, arg1, arg2, arg3, arg4, arg5);
    BOOL switchOn = [[NSUserDefaults standardUserDefaults] boolForKey:kRedEnvelopSwitch];
    if ([arg2 isKindOfClass:NSClassFromString(@"WKBizConversation")] && switchOn) {
        WKBizConversation *conversation = (WKBizConversation *)arg2;
        if (conversation.latestMessageJson.length > 0) {
            NSData *conversationData = [conversation.latestMessageJson dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *conversationDic = [NSJSONSerialization JSONObjectWithData:conversationData options:NSJSONReadingMutableLeaves error:nil];
            if (conversationDic.count > 0) {
                NSString *attachmentsJson = conversationDic[@"attachmentsJson"];
                if (attachmentsJson.length > 0) {
                    NSData *attachmentsJsonData = [attachmentsJson dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *attachmentsJsonDic = [NSJSONSerialization JSONObjectWithData:attachmentsJsonData options:NSJSONReadingMutableLeaves error:nil];
                    if (attachmentsJsonDic.count > 0) {
                        int contentType = [attachmentsJsonDic[@"contentType"] intValue];
                        if (contentType == 901 || contentType == 902 || contentType == 905) {
                            NSArray *attachments = attachmentsJsonDic[@"attachments"];
                            for (NSDictionary *dic in attachments) {
                                NSDictionary *extension = dic[@"extension"];
                                if (extension.count > 0) {
                                    NSString *clusterid = extension[@"clusterid"];
                                    long long sid = [extension[@"sid"] longLongValue];
                                    if (clusterid.length > 0 && sid > 0) {
                                        [redEnvelopService pickRedEnvelopCluster:sid clusterId:clusterid successBlock:nil failureBlock:nil];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



static void _logos_method$_ungrouped$DTTableViewHandler$setDataSource$(_LOGOS_SELF_TYPE_NORMAL DTTableViewHandler* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, DTTableViewDataSource * dataSource) {
    if ([self.delegate isKindOfClass:NSClassFromString(@"DTSettingViewController")]) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:dataSource.tableViewDataSource];
        BOOL isHas = NO;
        for (DTSectionItem *item in array) {
            NSMutableArray *subArray = [[NSMutableArray alloc] initWithArray:item.dataSource];
            for (DTCellItem *cellItem in subArray) {
                
                if ([cellItem.title isEqualToString:kRedEnvelopTitle]) {
                    isHas = YES;
                    break;
                }
            }
        }
        if (!isHas) {
            if (array.count > 0) {
                DTSectionItem *sectionItem = [NSClassFromString(@"DTSectionItem") new];
                NSMutableArray *subArray = @[].mutableCopy;
                BOOL switchOn = [[NSUserDefaults standardUserDefaults] boolForKey:kRedEnvelopSwitch];
                id block = ^(DTCellItem *cellItem, id cell, UISwitch *aSwitch){
                    [[NSUserDefaults standardUserDefaults] setBool:aSwitch.on forKey:kRedEnvelopSwitch];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                };
                DTCellItem *item = [NSClassFromString(@"DTCellItem") cellItemForSwitcherStyleWithTitle:kRedEnvelopTitle isSwitcherOn:switchOn switcherValueDidChangeBlock:block];
                [subArray addObject:item];
                sectionItem.dataSource = subArray;
                [array insertObject:sectionItem atIndex:0];
                dataSource.tableViewDataSource = [array copy];
            }
        }
    }
    _logos_orig$_ungrouped$DTTableViewHandler$setDataSource$(self, _cmd, dataSource);
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$DTRedEnvelopServiceIMP = objc_getClass("DTRedEnvelopServiceIMP"); MSHookMessageEx(_logos_class$_ungrouped$DTRedEnvelopServiceIMP, @selector(init), (IMP)&_logos_method$_ungrouped$DTRedEnvelopServiceIMP$init, (IMP*)&_logos_orig$_ungrouped$DTRedEnvelopServiceIMP$init);Class _logos_class$_ungrouped$DTConversationListDataSource = objc_getClass("DTConversationListDataSource"); MSHookMessageEx(_logos_class$_ungrouped$DTConversationListDataSource, @selector(controller:didChangeObject:atIndex:forChangeType:newIndex:), (IMP)&_logos_method$_ungrouped$DTConversationListDataSource$controller$didChangeObject$atIndex$forChangeType$newIndex$, (IMP*)&_logos_orig$_ungrouped$DTConversationListDataSource$controller$didChangeObject$atIndex$forChangeType$newIndex$);Class _logos_class$_ungrouped$DTTableViewHandler = objc_getClass("DTTableViewHandler"); MSHookMessageEx(_logos_class$_ungrouped$DTTableViewHandler, @selector(setDataSource:), (IMP)&_logos_method$_ungrouped$DTTableViewHandler$setDataSource$, (IMP*)&_logos_orig$_ungrouped$DTTableViewHandler$setDataSource$);} }
#line 122 "/Users/in8/Downloads/tweak/钉钉/DingTalkRedEnvelop/DingTalkRedEnvelop/DingTalkRedEnvelop.xm"
