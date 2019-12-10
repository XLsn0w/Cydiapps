/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iCalendar.framework/iCalendar
 */

#import <iCalendar/ICSBusyStatusValue.h>
#import <iCalendar/ICSPredefinedValue.h>


@interface ICSBusyStatusValue : ICSPredefinedValue {
}
+ (id)busyStatusTypeFromCode:(int)code;	// 0xa2d5
@end

@interface ICSBusyStatusValue (ICSWriter)
- (void)_ICSStringWithOptions:(unsigned)options appendingToString:(id)string;	// 0xd301
@end

@interface ICSBusyStatusValue (iCalendarImport)
+ (id)busyStatusValueFromICSString:(id)icsstring;	// 0x1e259
@end
