/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/Conference.framework/Conference
 */

#import <Conference/Conference-Structs.h>
#import <Conference/CNFRegEditableTableCell.h>

@class NSString;

@interface CNFRegEditablePhoneTableCell : CNFRegEditableTableCell {
@private
	SEL _countryCodeSelector;	// 344 = 0x158
	NSString *_previousValue;	// 348 = 0x15c
}
- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier;	// 0x2de01
- (void)dealloc;	// 0x2e061
- (void)setValueChangedTarget:(id)target action:(SEL)action specifier:(id)specifier;	// 0x2dfd1
- (id)countryCode;	// 0x2df49
- (XXStruct_HeigOC)suggestionsForString:(id)string inputIndex:(unsigned)index;	// 0x2de85
@end
