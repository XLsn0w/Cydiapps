/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/IMCore.framework/Frameworks/IMDAppleServices.framework/IMDAppleServices
 */

#import <IMDAppleServices/IMUserNotificationListener.h>

#import <IMDAppleServices/IMSystemMonitorListener.h>
#import <IMDAppleServices/IMDAppleEmailInterfaceListener.h>

@class NSMutableDictionary, NSMutableArray, FTMessageDelivery;

__attribute__((visibility("hidden")))
@interface IMDAppleIDRegistrationCenter : NSObject <IMUserNotificationListener, IMSystemMonitorListener, IMDAppleEmailInterfaceListener> {
	NSMutableDictionary *_queues;	// 4 = 0x4
	NSMutableDictionary *_passwordFetchers;	// 8 = 0x8
	NSMutableDictionary *_passwordFetcherRegistrations;	// 12 = 0xc
	NSMutableArray *_handlers;	// 16 = 0x10
	FTMessageDelivery *_messageDelivery;	// 20 = 0x14
}
+ (id)sharedInstance;	// 0x1a0d
- (void)removeListener:(id)listener;	// 0x7619
- (void)addListener:(id)listener;	// 0x7599
- (void)center:(id)center foundEmail:(id)email vettingToken:(id)token forRegistrationInfo:(id)registrationInfo;	// 0x7509
- (void)cancelActionsForRegistrationInfo:(id)registrationInfo;	// 0x7505
- (BOOL)authenticateRegistration:(id)registration;	// 0x73ed
- (BOOL)removeEmail:(id)email forRegistration:(id)registration;	// 0x7215
- (BOOL)confirmEmail:(id)email vettingToken:(id)token forRegistration:(id)registration;	// 0x7185
- (BOOL)validateEmail:(id)email forRegistration:(id)registration;	// 0x7105
- (BOOL)validateRegion:(id)region phoneNumber:(id)number forRegistration:(id)registration;	// 0x7075
- (BOOL)queryInitialInvitationContextForRegistration:(id)registration;	// 0x7001
- (BOOL)queryValidatedEmailsForRegistration:(id)registration;	// 0x6f8d
- (BOOL)isRegistering:(id)registering;	// 0x6f55
- (BOOL)_sendConfirmationForEmail:(id)email vettingToken:(id)token registration:(id)registration;	// 0x6cc1
- (BOOL)_queryValidatedEmailsForRegistration:(id)registration;	// 0x6a6d
- (BOOL)_queryInitialInvitationContextForRegistration:(id)registration;	// 0x6819
- (BOOL)_validateRegionID:(id)anId phoneNumber:(id)number registration:(id)registration;	// 0x6585
- (BOOL)_sendValidationForEmail:(id)email registration:(id)registration;	// 0x62f5
- (BOOL)_registrationNeedsAuthentication:(id)authentication;	// 0x62b9
- (BOOL)_haveQueuedMessageForRegistration:(id)registration inQueue:(id)queue;	// 0x61c5
- (void)keychainPasswordFetcher:(id)fetcher retreivedPassword:(id)password forUsername:(id)username onService:(id)service;	// 0x5fdd
- (id)_displayStringForFTRegistrationServiceType:(int)ftregistrationServiceType;	// 0x5f55
- (void)userNotificationDidFinish:(id)userNotification;	// 0x5f45
- (void)_handlePasswordFetcherNotification:(id)notification;	// 0x5d8d
- (BOOL)_sendAuthenticationRequest:(id)request;	// 0x5c61
- (BOOL)__reallySendAuthentication:(id)authentication password:(id)password;	// 0x59cd
- (void)__clearKeychainFetcherInfoForInfo:(id)info;	// 0x5885
- (void)_fetchPasswordForRegistrationInfo:(id)registrationInfo;	// 0x550d
- (void)_processRegionValidationMessage:(id)message deliveredWithError:(id)error resultCode:(int)code resultDictionary:(id)dictionary;	// 0x5101
- (void)_processDefaultInvitationContextMessage:(id)message deliveredWithError:(id)error resultCode:(int)code resultDictionary:(id)dictionary;	// 0x4f69
- (void)_processEmailQueryMessage:(id)message deliveredWithError:(id)error resultCode:(int)code resultDictionary:(id)dictionary;	// 0x4da5
- (void)_processEmailConfirmationMessage:(id)message deliveredWithError:(id)error resultCode:(int)code resultDictionary:(id)dictionary;	// 0x4abd
- (void)_processValidationRequestMessage:(id)message deliveredWithError:(id)error resultCode:(int)code resultDictionary:(id)dictionary;	// 0x4789
- (void)_processAuthenticationMessage:(id)message deliveredWithError:(id)error resultCode:(int)code resultDictionary:(id)dictionary;	// 0x4231
- (void)_handleServerResponse:(int)response registration:(id)registration;	// 0x3c8d
- (void)_postUserNotificationWithTitle:(id)title message:(id)message identifier:(id)identifier completionHandler:(id)handler;	// 0x3b99
- (void)_notifyEmailQuerySuccess:(id)success emailAddresses:(id)addresses;	// 0x39b9
- (void)_notifyEmailQueryFailure:(id)failure error:(int)error info:(id)info;	// 0x37ad
- (void)_notifyEmailValidationRequestSuccess:(id)success emailAddress:(id)address;	// 0x35cd
- (void)_notifyEmailValidationRequestFailure:(id)failure emailAddress:(id)address error:(int)error info:(id)info;	// 0x33b9
- (void)_notifyEmailConfirmationSuccess:(id)success emailAddress:(id)address;	// 0x3149
- (void)_notifyEmailConfirmationFailure:(id)failure emailAddress:(id)address error:(int)error info:(id)info;	// 0x2f0d
- (void)_notifyAuthenticationSuccess:(id)success;	// 0x2ce1
- (void)_notifyAuthenticationFailure:(id)failure error:(int)error info:(id)info;	// 0x2a51
- (void)_notifyRegistrationRequired:(id)required;	// 0x2855
- (void)_notifyAuthenticating:(id)authenticating;	// 0x2625
- (void)_notifyRegionValidationSuccess:(id)success regionID:(id)anId phoneNumber:(id)number context:(id)context verified:(BOOL)verified;	// 0x238d
- (void)_notifyInitialRegionQuerySuccess:(id)success;	// 0x2161
- (void)_notifyRegionValidationFailure:(id)failure error:(int)error info:(id)info;	// 0x1f09
- (void)_serviceQueueForKey:(id)key;	// 0x1d99
- (id)_queueForKey:(id)key;	// 0x1cc5
- (void)dealloc;	// 0x1bc5
- (id)init;	// 0x1ac1
- (BOOL)retainWeakReference;	// 0x1abd
- (BOOL)allowsWeakReference;	// 0x1ab9
@end
