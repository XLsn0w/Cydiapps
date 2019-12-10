/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataDetectorsCore.framework/DataDetectorsCore
 */

#import <DataDetectorsCore/DataDetectorsCore-Structs.h>


@class NSString;

@interface DDURLMatch : NSObject {
	NSRange _range;	// 4 = 0x4
	NSString *_url;	// 12 = 0xc
}
@property(readonly, assign) NSRange range;	// G=0x9a41; converted property
@property(readonly, retain) NSString *url;	// G=0x9a5d; converted property
- (id)description;	// 0x9ac9
- (int)compare:(id)compare;	// 0x9a6d
// converted property getter: - (id)url;	// 0x9a5d
// converted property getter: - (NSRange)range;	// 0x9a41
- (void)dealloc;	// 0x99f5
- (id)initWithRange:(NSRange)range url:(id)url;	// 0x9989
@end
