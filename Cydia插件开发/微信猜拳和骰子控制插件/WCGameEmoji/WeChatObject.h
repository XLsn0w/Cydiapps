//
//  WeChatObject.h
//  WCGameEmoji
//
//  Created by In8 on 2017/9/20.
//

@interface MMServiceCenter : NSObject
+ (instancetype)defaultCenter;
- (id)getService:(Class)service;
@end

@interface MMNewSessionMgr : NSObject
- (long long)GenSendMsgTime;
@end

@interface CMessageWrap : NSObject

@property(retain, nonatomic) NSString *m_nsEmoticonMD5;
@property(nonatomic) unsigned int m_uiEmoticonType;

@property(nonatomic) unsigned int m_uiGameContent;
@property(nonatomic) unsigned int m_uiGameType;

@property (assign, nonatomic) NSUInteger m_uiMesLocalID;
@property (retain, nonatomic) NSString* m_nsFromUsr;
@property (retain, nonatomic) NSString* m_nsToUsr; 

@property (assign, nonatomic) NSUInteger m_uiStatus;
@property (assign, nonatomic) NSUInteger m_uiImgStatus;

@property (nonatomic) NSUInteger m_uiMessageType;
@property (nonatomic) NSUInteger m_uiCreateTime;

- (instancetype)initWithMsgType:(int)msgType;

@end

@interface CMessageMgr : NSObject
- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2;
- (void)AddEmoticonMsg:(NSString *)arg1 MsgWrap:(CMessageWrap *)arg2;
@end

@interface CContact : NSObject
@property (retain, nonatomic) NSString *m_nsUsrName;

@end

@interface CContactMgr : NSObject

- (CContact *)getSelfContact;

@end
