/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/SportsVoices.framework/SportsVoices
 */

#import <SportsVoices/XXUnknownSuperclass.h>

@class NSMutableDictionary, NSMutableArray, GrammarPart;

@interface Parser : XXUnknownSuperclass {
	NSMutableArray *_productionRules;	// 4 = 0x4
	NSMutableDictionary *_grammarsPlist;	// 8 = 0x8
	bool _debugging;	// 12 = 0xc
	GrammarPart *_theGrammar;	// 16 = 0x10
}
@property(readonly, assign) NSMutableArray *productionRules;	// G=0x5525; @synthesize=_productionRules
+ (id)retrievePlistForPathArray:(id)pathArray from:(id)from;	// 0x5399
+ (id)retrievePlistForStringInDotNotation:(id)dotNotation from:(id)from;	// 0x5359
+ (BOOL)insertStatementsFromOriginal:(id)original intoBranch:(id)branch;	// 0x4f99
+ (id)loadGrammarsFromPlistAtPath:(id)path;	// 0x4d31
// declared property getter: - (id)productionRules;	// 0x5525
- (void)dealloc;	// 0x54b1
- (id)resultOfRulesAppliedTo:(id)to;	// 0x5491
- (id)resultOfRulesAppliedToStrings:(id)strings;	// 0x5455
- (void)setGrammar:(id)grammar;	// 0x4ed5
- (id)initWithPlistAtPath:(id)path grammar:(id)grammar;	// 0x4c95
@end
