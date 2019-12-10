/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/IMCore.framework/Frameworks/IMFoundation.framework/IMFoundation
 */

#import <IMFoundation/XXUnknownSuperclass.h>
#import <IMFoundation/IMFoundation-Structs.h>

@class NSArray, NSString, NSAttributedString;

@interface IMAttributedStringParserContext : XXUnknownSuperclass {
	NSAttributedString *_inString;	// 4 = 0x4
}
@property(readonly, assign) BOOL shouldPreprocess;	// G=0x4539; 
@property(readonly, assign) NSArray *resultsForLogging;	// G=0x16741; 
@property(readonly, assign) NSString *name;	// G=0x16735; 
@property(readonly, assign) NSAttributedString *inString;	// G=0x4525; @synthesize=_inString
// declared property getter: - (id)inString;	// 0x4525
- (id)parser:(id)parser preprocessedAttributesForAttributes:(id)attributes range:(NSRange)range;	// 0x1674d
// declared property getter: - (BOOL)shouldPreprocess;	// 0x4539
- (void)parserDidEnd:(id)parser;	// 0x4845
- (void)parser:(id)parser foundAttributes:(id)attributes inRange:(NSRange)range;	// 0x16749
- (void)parserDidStart:(id)parser;	// 0x16745
// declared property getter: - (id)resultsForLogging;	// 0x16741
// declared property getter: - (id)name;	// 0x16735
- (void)dealloc;	// 0x4a49
- (id)initWithAttributedString:(id)attributedString;	// 0x446d
@end
