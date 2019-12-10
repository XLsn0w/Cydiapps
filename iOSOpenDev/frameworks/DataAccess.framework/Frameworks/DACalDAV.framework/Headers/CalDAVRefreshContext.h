/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/Frameworks/DACalDAV.framework/DACalDAV
 */

#import <DACalDAV/XXUnknownSuperclass.h>

@class NSError;

@interface CalDAVRefreshContext : XXUnknownSuperclass {
	BOOL _isForced;	// 4 = 0x4
	BOOL _isCalendarsOnly;	// 5 = 0x5
	BOOL _didDownloadEvents;	// 6 = 0x6
	BOOL _didSaveDatabase;	// 7 = 0x7
	BOOL _shouldSave;	// 8 = 0x8
	BOOL _shouldSaveAccounts;	// 9 = 0x9
	BOOL _calendarFailedToSync;	// 10 = 0xa
	int _numDownloadedElements;	// 12 = 0xc
	BOOL _shouldRetry;	// 16 = 0x10
	int _retryTime;	// 20 = 0x14
	NSError *_error;	// 24 = 0x18
}
@property(retain, nonatomic) NSError *error;	// G=0x17afd; S=0x17b0d; @synthesize=_error
@property(assign, nonatomic) int retryTime;	// G=0x17add; S=0x17aed; @synthesize=_retryTime
@property(assign, nonatomic) BOOL shouldRetry;	// G=0x17abd; S=0x17acd; @synthesize=_shouldRetry
@property(assign, nonatomic) int numDownloadedElements;	// G=0x17a7d; S=0x17a8d; @synthesize=_numDownloadedElements
@property(assign, nonatomic) BOOL calendarFailedToSync;	// G=0x17a9d; S=0x17aad; @synthesize=_calendarFailedToSync
@property(assign, nonatomic) BOOL shouldSaveAccounts;	// G=0x17a5d; S=0x17a6d; @synthesize=_shouldSaveAccounts
@property(assign, nonatomic) BOOL shouldSave;	// G=0x17a3d; S=0x17a4d; @synthesize=_shouldSave
@property(assign, nonatomic) BOOL didSaveDatabase;	// G=0x17a1d; S=0x17a2d; @synthesize=_didSaveDatabase
@property(assign, nonatomic) BOOL didDownloadEvents;	// G=0x179fd; S=0x17a0d; @synthesize=_didDownloadEvents
@property(assign, nonatomic) BOOL isCalendarsOnly;	// G=0x179dd; S=0x179ed; @synthesize=_isCalendarsOnly
@property(assign, nonatomic) BOOL isForced;	// G=0x179bd; S=0x179cd; @synthesize=_isForced
+ (id)defaultContext;	// 0x1792d
// declared property setter: - (void)setError:(id)error;	// 0x17b0d
// declared property getter: - (id)error;	// 0x17afd
// declared property setter: - (void)setRetryTime:(int)time;	// 0x17aed
// declared property getter: - (int)retryTime;	// 0x17add
// declared property setter: - (void)setShouldRetry:(BOOL)retry;	// 0x17acd
// declared property getter: - (BOOL)shouldRetry;	// 0x17abd
// declared property setter: - (void)setCalendarFailedToSync:(BOOL)sync;	// 0x17aad
// declared property getter: - (BOOL)calendarFailedToSync;	// 0x17a9d
// declared property setter: - (void)setNumDownloadedElements:(int)elements;	// 0x17a8d
// declared property getter: - (int)numDownloadedElements;	// 0x17a7d
// declared property setter: - (void)setShouldSaveAccounts:(BOOL)saveAccounts;	// 0x17a6d
// declared property getter: - (BOOL)shouldSaveAccounts;	// 0x17a5d
// declared property setter: - (void)setShouldSave:(BOOL)save;	// 0x17a4d
// declared property getter: - (BOOL)shouldSave;	// 0x17a3d
// declared property setter: - (void)setDidSaveDatabase:(BOOL)saveDatabase;	// 0x17a2d
// declared property getter: - (BOOL)didSaveDatabase;	// 0x17a1d
// declared property setter: - (void)setDidDownloadEvents:(BOOL)downloadEvents;	// 0x17a0d
// declared property getter: - (BOOL)didDownloadEvents;	// 0x179fd
// declared property setter: - (void)setIsCalendarsOnly:(BOOL)only;	// 0x179ed
// declared property getter: - (BOOL)isCalendarsOnly;	// 0x179dd
// declared property setter: - (void)setIsForced:(BOOL)forced;	// 0x179cd
// declared property getter: - (BOOL)isForced;	// 0x179bd
- (void)dealloc;	// 0x17971
@end
