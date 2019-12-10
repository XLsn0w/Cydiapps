/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStoreUI.framework/iTunesStoreUI
 */

#import <iTunesStoreUI/SUScriptObject.h>

@class MPMediaItem;

@interface SUScriptMediaItem : SUScriptObject {
}
@property(readonly, assign, nonatomic) MPMediaItem *nativeItem;	// G=0x79591; 
+ (void)initialize;	// 0x79c01
+ (id)webScriptNameForSelector:(SEL)selector;	// 0x79bb9
+ (id)scriptPropertyForNativeProperty:(id)nativeProperty;	// 0x7953d
+ (id)scriptMediaTypeForNativeMediaType:(int)nativeMediaType;	// 0x79515
+ (id)nativePropertyForScriptProperty:(id)scriptProperty;	// 0x794c1
+ (int)nativeMediaTypesForScriptMediaTypes:(id)scriptMediaTypes;	// 0x793f5
+ (id)copyScriptMediaTypesForNativeMediaTypes:(int)nativeMediaTypes;	// 0x7935d
- (id)_copyValueForProperty:(id)property;	// 0x79a71
- (id)_copyImageURLWithWidth:(int)width height:(int)height;	// 0x79819
- (id)_className;	// 0x7980d
- (id)valueForProperty:(id)property;	// 0x79699
- (id)imageURLWithWidth:(id)width height:(id)height;	// 0x795b9
// declared property getter: - (id)nativeItem;	// 0x79591
@end
