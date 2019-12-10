/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/Conference.framework/Conference
 */

#import <Conference/CNFRegListController.h>
#import <Conference/CNFRegFirstRunExperience.h>

@class IMAccount, UIBarButtonItem, NSTimer;
@protocol CNFRegFirstRunDelegate;

@interface CNFRegFirstRunController : CNFRegListController <CNFRegFirstRunExperience> {
	Class _completionControllerClass;	// 252 = 0xfc
	BOOL _showingActivityIndicator;	// 256 = 0x100
	BOOL _previousHidesBackButton;	// 257 = 0x101
	UIBarButtonItem *_previousLeftButton;	// 260 = 0x104
	UIBarButtonItem *_previousRightButton;	// 264 = 0x108
	id<CNFRegFirstRunDelegate> _delegate;	// 268 = 0x10c
	UIBarButtonItem *_customRightButton;	// 272 = 0x110
	UIBarButtonItem *_customLeftButton;	// 276 = 0x114
	NSTimer *_timeoutTimer;	// 280 = 0x118
	BOOL _timedOut;	// 284 = 0x11c
	BOOL _cancelled;	// 285 = 0x11d
	IMAccount *_account;	// 288 = 0x120
}
@property(assign, nonatomic) Class completionControllerClass;	// G=0x28a15; S=0x28a25; @synthesize=_completionControllerClass
@property(retain, nonatomic) UIBarButtonItem *previousLeftButton;	// G=0x28a05; S=0x28a61; @synthesize=_previousLeftButton
@property(retain, nonatomic) UIBarButtonItem *previousRightButton;	// G=0x289f5; S=0x28a89; @synthesize=_previousRightButton
@property(assign, nonatomic) BOOL previousHidesBackButton;	// G=0x289d5; S=0x289e5; @synthesize=_previousHidesBackButton
@property(assign, nonatomic) id<CNFRegFirstRunDelegate> delegate;	// G=0x289b5; S=0x289c5; @synthesize=_delegate
@property(retain, nonatomic) UIBarButtonItem *customLeftButton;	// G=0x289a5; S=0x28ab1; @synthesize=_customLeftButton
@property(retain, nonatomic) UIBarButtonItem *customRightButton;	// G=0x28995; S=0x28ad9; @synthesize=_customRightButton
@property(assign, nonatomic) BOOL timedOut;	// G=0x28975; S=0x28985; @synthesize=_timedOut
@property(retain, nonatomic) IMAccount *account;	// G=0x28965; S=0x28b01; @synthesize=_account
@property(readonly, assign, nonatomic) int currentAppearanceStyle;	// G=0x28a35; 
@property(assign, nonatomic) BOOL showSplash;
- (id)initWithRegController:(id)regController;	// 0x29f69
- (id)initWithRegController:(id)regController account:(id)account;	// 0x29f35
- (id)initWithParentController:(id)parentController account:(id)account;	// 0x29ee9
- (void)dealloc;	// 0x29dc9
- (BOOL)canBeShownFromSuspendedState;	// 0x28931
- (void)setSpecifier:(id)specifier;	// 0x29d4d
- (void)_startListeningForReturnKey;	// 0x29ced
- (void)_stopListeningForReturnKey;	// 0x29ca1
- (void)_handleReturnKeyTapped:(id)tapped;	// 0x29c91
- (void)_returnKeyPressed;	// 0x28935
- (void)viewDidAppear:(BOOL)view;	// 0x29c51
- (void)viewWillAppear:(BOOL)view;	// 0x29bfd
- (void)viewWillDisappear:(BOOL)view;	// 0x29b71
- (id)customTitle;	// 0x29b61
- (id)titleString;	// 0x29b21
- (id)validationString;	// 0x29ae1
- (void)_refreshNavBarAnimated:(BOOL)animated;	// 0x299f9
- (id)_rightButtonItem;	// 0x298e1
- (void)_rightButtonTapped;	// 0x28939
- (void)_handleValidationModeCancelled;	// 0x2893d
- (void)_cancelValidationMode;	// 0x298c1
- (id)_leftButtonItem;	// 0x29825
- (void)_leftButtonTapped;	// 0x28941
- (BOOL)_hidesBackButton;	// 0x28945
- (void)_startTimeoutWithDuration:(double)duration;	// 0x2978d
- (void)_stopTimeout;	// 0x29745
- (void)_timeoutFired:(id)fired;	// 0x29705
- (void)_handleTimeout;	// 0x2895d
- (id)_validationModeCancelButton;	// 0x296a9
- (void)_startActivityIndicatorWithTitle:(id)title animated:(BOOL)animated allowCancel:(BOOL)cancel;	// 0x294d1
- (void)_startActivityIndicatorWithTitle:(id)title animated:(BOOL)animated;	// 0x294ad
- (void)_stopActivityIndicatorWithTitle:(id)title animated:(BOOL)animated;	// 0x2936d
- (void)_stopActivityIndicatorAnimated:(BOOL)animated;	// 0x29339
- (void)_startValidationModeAnimated:(BOOL)animated allowCancel:(BOOL)cancel;	// 0x292e1
- (void)_startValidationModeAnimated:(BOOL)animated;	// 0x292cd
- (void)_stopValidationModeAnimated:(BOOL)animated;	// 0x292bd
- (void)setCellsChecked:(BOOL)checked;	// 0x291e5
- (void)willBecomeActive;	// 0x29191
- (void)willResignActive;	// 0x29119
- (void)_updateUI;	// 0x28961
- (void)_updateControllerState;	// 0x290c1
- (void)_refreshCurrentState;	// 0x29085
- (BOOL)pushCompletionControllerIfPossible;	// 0x28d2d
- (BOOL)dismissWithState:(unsigned)state;	// 0x28cb9
- (void)_setupEventHandlers;	// 0x28bd9
// declared property getter: - (int)currentAppearanceStyle;	// 0x28a35
- (void)_executeDismissBlock:(id)block;	// 0x28b29
// declared property getter: - (id)account;	// 0x28965
// declared property setter: - (void)setAccount:(id)account;	// 0x28b01
// declared property getter: - (BOOL)timedOut;	// 0x28975
// declared property setter: - (void)setTimedOut:(BOOL)anOut;	// 0x28985
// declared property getter: - (id)customRightButton;	// 0x28995
// declared property setter: - (void)setCustomRightButton:(id)button;	// 0x28ad9
// declared property getter: - (id)customLeftButton;	// 0x289a5
// declared property setter: - (void)setCustomLeftButton:(id)button;	// 0x28ab1
// declared property getter: - (id)delegate;	// 0x289b5
// declared property setter: - (void)setDelegate:(id)delegate;	// 0x289c5
// declared property getter: - (BOOL)previousHidesBackButton;	// 0x289d5
// declared property setter: - (void)setPreviousHidesBackButton:(BOOL)button;	// 0x289e5
// declared property getter: - (id)previousRightButton;	// 0x289f5
// declared property setter: - (void)setPreviousRightButton:(id)button;	// 0x28a89
// declared property getter: - (id)previousLeftButton;	// 0x28a05
// declared property setter: - (void)setPreviousLeftButton:(id)button;	// 0x28a61
// declared property getter: - (Class)completionControllerClass;	// 0x28a15
// declared property setter: - (void)setCompletionControllerClass:(Class)aClass;	// 0x28a25
@end
