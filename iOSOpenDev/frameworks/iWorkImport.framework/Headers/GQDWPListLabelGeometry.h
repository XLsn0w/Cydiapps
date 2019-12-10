/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iWorkImport.framework/iWorkImport
 */

#import <iWorkImport/XXUnknownSuperclass.h>
#import <iWorkImport/GQDNameMappable.h>
#import <iWorkImport/iWorkImport-Structs.h>


__attribute__((visibility("hidden")))
@interface GQDWPListLabelGeometry : XXUnknownSuperclass <GQDNameMappable> {
@private
	float mScale;	// 4 = 0x4
	float mBaselineOffset;	// 8 = 0x8
	BOOL mScaleWithText;	// 12 = 0xc
	int mLabelAlignment;	// 16 = 0x10
}
+ (const StateSpec *)stateForReading;	// 0x2290d
- (int)readAttributesFromReader:(xmlTextReader *)reader;	// 0x22979
- (float)scale;	// 0x22919
- (float)baselineOffset;	// 0x22929
- (BOOL)scaleWithText;	// 0x22939
- (int)labelAlignment;	// 0x22949
@end
