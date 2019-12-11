//
//  FishConfigurationCenter.m
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/26.
//
//

#import "FishConfigurationCenter.h"

@implementation FishConfigurationCenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.chatIgnoreInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [_chatIgnoreInfo release];
    [_currentUserName release];
    [_lastChangeStepCountDate release];
    [super dealloc];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FishConfigurationCenter *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [FishConfigurationCenter new];
    });
    return _instance;
}

+ (void)loadInstance:(FishConfigurationCenter *)instance
{
    FishConfigurationCenter *center = [self sharedInstance];
    center.nightMode = instance.isNightMode;
    center.stepCount = instance.stepCount;
    center.revokeMsg = instance.onRevokeMsg;
    center.chatIgnoreInfo = instance.chatIgnoreInfo;
    center.currentUserName = instance.currentUserName;
    center.lastChangeStepCountDate = instance.lastChangeStepCountDate;
}

#pragma mark - Handle Events

- (void)handleNightMode:(UISwitch *)sender
{
    self.nightMode = sender.isOn;
    [[self viewControllerOfResponder:sender] viewWillAppear:NO];
}

- (void)handleStepCount:(UITextField *)sender
{
    self.stepCount = sender.text.integerValue;
    self.lastChangeStepCountDate = [NSDate date];
}

- (void)handleIgnoreChatRoom:(UISwitch *)sender
{
    self.chatIgnoreInfo[self.currentUserName] = @(sender.isOn);
}

- (UIViewController *)viewControllerOfResponder:(UIResponder *)responder
{
    UIResponder *current = responder;
    while (current && ![current isKindOfClass:UIViewController.class]) {
        current = [current nextResponder];
    }
    return (UIViewController *)current;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.nightMode forKey:@"nightMode"];
    [aCoder encodeInteger:self.stepCount forKey:@"stepCount"];
    [aCoder encodeBool:self.revokeMsg forKey:@"revokeMsg"];
    [aCoder encodeObject:self.chatIgnoreInfo forKey:@"chatIgnoreInfo"];
    [aCoder encodeObject:self.currentUserName forKey:@"currentUserName"];
    [aCoder encodeObject:self.lastChangeStepCountDate forKey:@"lastChangeStepCountDate"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.nightMode = [aDecoder decodeBoolForKey:@"nightMode"];
        self.stepCount = [aDecoder decodeIntegerForKey:@"stepCount"];
        self.revokeMsg = [aDecoder decodeBoolForKey:@"revokeMsg"];
        self.chatIgnoreInfo = [aDecoder decodeObjectOfClass:NSDictionary.class forKey:@"chatIgnoreInfo"];
        self.currentUserName = [aDecoder decodeObjectOfClass:NSString.class forKey:@"currentUserName"];
        self.lastChangeStepCountDate = [aDecoder decodeObjectForKey:@"lastChangeStepCountDate"];
    }
    return self;
}

@end
