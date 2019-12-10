/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iAdCore.framework/iAdCore
 */

#import <iAdCore/XXUnknownSuperclass.h>

@class NSRegularExpression;

@interface ADDateStringNormalizer : XXUnknownSuperclass {
@private
	NSRegularExpression *_regularExpression;	// 4 = 0x4
}
@property(retain, nonatomic) NSRegularExpression *regularExpression;	// G=0x3709d; S=0x370ad; @synthesize=_regularExpression
+ (id)dateFromString:(id)string;	// 0x36fb1
+ (id)normalizers;	// 0x36eed
+ (id)formatter;	// 0x36e39
// declared property setter: - (void)setRegularExpression:(id)expression;	// 0x370ad
// declared property getter: - (id)regularExpression;	// 0x3709d
- (id)normalize:(id)normalize;	// 0x36e35
- (void)dealloc;	// 0x36de1
@end
