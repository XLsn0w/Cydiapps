// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>

#define kRedEnvelopTitle @"红包开关"
#define kRedEnvelopSwitch @"kRedEnvelopSwitch"

@interface DTRedEnvelopServiceIMP : NSObject
- (void)pickRedEnvelopCluster:(long long)arg1 clusterId:(id)arg2 successBlock:(id)arg3 failureBlock:(id)arg4;
@end

@interface WKBizConversation : NSObject
@property(retain, nonatomic) NSString *latestMessageJson; // @synthesize latestMessageJson=_latestMessageJson;
@end

@interface DTCellItem : NSObject
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
+ (id)cellItemForSwitcherStyleWithTitle:(id)arg1 isSwitcherOn:(_Bool)arg2 switcherValueDidChangeBlock:(id)arg3;

@end

@interface DTSectionItem : NSObject
@property(copy, nonatomic) NSArray *dataSource; // @synthesize dataSource=_dataSource;
@end

@interface DTTableViewDataSource : NSObject
@property(copy, nonatomic) NSArray *tableViewDataSource; // @synthesize tableViewDataSource=_tableViewDataSource;

@end

@interface DTTableViewHandler : NSObject
@property(retain, nonatomic) DTTableViewDataSource *dataSource; // @synthesize dataSource=_dataSource;
@property(nonatomic, weak) id delegate; // @synthesize delegate=_delegate;
@end

@interface DTSettingViewController : UIViewController
@property(strong, nonatomic) DTTableViewHandler *tableViewHandler; // @synthesize tableViewHandler=_tableViewHandler;

@end
static DTRedEnvelopServiceIMP *redEnvelopService = nil;

%hook DTRedEnvelopServiceIMP
- (id)init {
    id obj = %orig;
    redEnvelopService = obj;
    return obj;
}
%end

%hook DTConversationListDataSource
- (void)controller:(id)arg1 didChangeObject:(id)arg2 atIndex:(unsigned long long)arg3 forChangeType:(long long)arg4 newIndex:(unsigned long long)arg5 {
    %orig;
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
%end

%hook DTTableViewHandler
- (void)setDataSource:(DTTableViewDataSource *)dataSource {
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
    %orig(dataSource);
}
%end
