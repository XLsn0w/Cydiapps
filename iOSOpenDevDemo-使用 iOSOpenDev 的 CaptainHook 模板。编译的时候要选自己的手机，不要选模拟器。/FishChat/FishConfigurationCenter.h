//
//  FishConfigurationCenter.h
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/26.
//
//

#import <UIKit/UIKit.h>

@interface FishConfigurationCenter : NSObject <NSCoding>

@property (nonatomic, getter = isNightMode) BOOL nightMode;
@property (nonatomic) NSInteger stepCount;
@property (nonatomic, getter=onRevokeMsg) BOOL revokeMsg;
@property (nonatomic, retain) NSMutableDictionary<NSString *,NSNumber *> *chatIgnoreInfo;
@property (nonatomic, copy) NSString *currentUserName;
@property (nonatomic,retain) NSDate *lastChangeStepCountDate;

+ (instancetype)sharedInstance;
+ (void)loadInstance:(FishConfigurationCenter *)instance;

- (void)handleNightMode:(UISwitch *)sender;
- (void)handleStepCount:(UITextField *)sender;
- (void)handleIgnoreChatRoom:(UISwitch *)sender;

@end
