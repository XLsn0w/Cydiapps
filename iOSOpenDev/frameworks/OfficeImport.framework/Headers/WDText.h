/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/XXUnknownSuperclass.h>

@class WDTableCell, NSMutableArray, WDDocument;

__attribute__((visibility("hidden")))
@interface WDText : XXUnknownSuperclass {
@private
	NSMutableArray *mBlocks;	// 4 = 0x4
	WDDocument *mDocument;	// 8 = 0x8
	int mTextType;	// 12 = 0xc
	WDTableCell *mTableCell;	// 16 = 0x10
}
- (id)initWithDocument:(id)document textType:(int)type;	// 0x121f21
- (id)initWithDocument:(id)document textType:(int)type tableCell:(id)cell;	// 0x121f45
- (void)dealloc;	// 0xa2bb5
- (id)blocks;	// 0x29bc71
- (int)blockCount;	// 0x92561
- (id)blockAt:(int)at;	// 0x923ad
- (id)lastBlock;	// 0x196909
- (int)indexOfBlock:(id)block;	// 0x29bc81
- (void)addBlock:(id)block;	// 0x29bca5
- (id)document;	// 0x13243d
- (int)textType;	// 0x131ee9
- (id)tableCell;	// 0x14125d
- (id)addParagraph;	// 0x1322c9
- (id)addParagraphAtIndex:(int)index;	// 0x29bcc9
- (id)addTable;	// 0x13eca5
- (id)addTableAtIndex:(int)index;	// 0x29bd39
- (void)removeLastCharacter:(unsigned short)character;	// 0x1352a9
- (void)removeLastBlock;	// 0x134779
- (int)tableNestingLevel;	// 0x130fc9
- (id)blockIterator;	// 0x29bda9
- (id)newBlockIterator;	// 0x29bdfd
- (id)runIterator;	// 0x29be41
- (id)newRunIterator;	// 0x29bea1
- (BOOL)isEmpty;	// 0x29befd
- (id)content;	// 0x29bf6d
@end
