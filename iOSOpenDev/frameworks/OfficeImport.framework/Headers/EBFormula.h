/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/EBFormula.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface EBFormula : XXUnknownSuperclass {
}
+ (void)readFormulaFromXlCell:(XlCell *)xlCell edCell:(EDCellHeader *)cell edRowBlocks:(id)blocks state:(id)state;	// 0x25aa8d
+ (id)edFormulaFromXlFmlaDefinition:(const void *)xlFmlaDefinition withFormulaLength:(int)formulaLength state:(id)state;	// 0x10c481
+ (id)edFormulaFromXlFmlaDefinition:(const void *)xlFmlaDefinition withFormulaLength:(int)formulaLength formulaClass:(Class)aClass state:(id)state;	// 0x10c4d5
+ (id)edFormulaFromXlFmlaDefinition:(const void *)xlFmlaDefinition withFormulaLength:(int)formulaLength formulaClass:(Class)aClass edSheet:(id)sheet state:(id)state;	// 0x10c539
+ (XlFormulaInfo *)xlFormulaInfoFromEDFormula:(id)edformula state:(id)state;	// 0x25ad0d
@end

@interface EBFormula (Private)
+ (char *)edFormulaToParsedExpression:(id)parsedExpression tokenLength:(unsigned short *)length formulaLength:(unsigned short *)length3 state:(id)state;	// 0x25a8b9
+ (unsigned)writeToken:(id)token tokenIndex:(unsigned)index tokenStream:(XLFormulaStream *)stream extendedStream:(XLFormulaStream *)stream4 state:(id)state;	// 0x25ae89
+ (void)setupTokensInEDFormulaFromXlFormulaProcessor:(XlFormulaProcessor *)xlFormulaProcessor length:(int)length edFormula:(id)formula edSheet:(id)sheet;	// 0x10c78d
+ (XlFormulaInfo *)xlFormulaInfoFromEDSharedFormula:(id)edsharedFormula state:(id)state;	// 0x25b0fd
+ (void)setupFormulaDataForSharedFormula:(id)sharedFormula xlFormulaInfo:(XlFormulaInfo *)info state:(id)state;	// 0x25b33d
@end
