/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataDetectorsCore.framework/DataDetectorsCore
 */

#import <DataDetectorsCore/DataDetectorsCore-Structs.h>
#import <DataDetectorsCore/DDLocation.h>

@class NSString;

__attribute__((visibility("hidden")))
@interface DDCompilationNote : DDLocation {
@private
	NSString *_message;	// 24 = 0x18
	int _level;	// 28 = 0x1c
}
@property(readonly, assign) int level;	// G=0x1d81; @synthesize=_level
@property(readonly, assign) NSString *message;	// G=0x1d71; @synthesize=_message
+ (id)noteAtLocation:(id)location ofLevel:(int)level withFormat:(id)format;	// 0x1b99
// declared property getter: - (int)level;	// 0x1d81
// declared property getter: - (id)message;	// 0x1d71
- (void)dealloc;	// 0x1d25
- (id)initWithLocation:(id)location message:(id)message level:(int)level;	// 0x1ca9
- (id)initWithFileName:(id)fileName position:(DDExpressionPosition)position message:(id)message level:(int)level;	// 0x1c39
@end
