/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/CMShapeRenderer.h>
#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface CMShapeRenderer : XXUnknownSuperclass {
}
+ (void)renderFreeForm:(id)form fill:(id)fill stroke:(id)stroke orientedBounds:(id)bounds state:(id)state drawingContext:(id)context;	// 0x14a16d
+ (void)renderDiagramPath:(id)path fill:(id)fill stroke:(id)stroke state:(id)state drawingContext:(id)context;	// 0x20646d
+ (void)renderLine:(int)line stroke:(id)stroke adjustValues:(id)values orientedBounds:(id)bounds state:(id)state drawingContext:(id)context;	// 0x1082dd
+ (void)renderCanonicalShape:(int)shape fill:(id)fill stroke:(id)stroke adjustValues:(id)values orientedBounds:(id)bounds state:(id)state drawingContext:(id)context;	// 0xc8a21
+ (void)_renderCGPath:(CGPathRef)path stroke:(id)stroke fill:(id)fill orientedBounds:(id)bounds state:(id)state drawingContext:(id)context;	// 0xc94f5
+ (CGColorRef)_createCGColorFromOADColor:(id)oadcolor andState:(id)state;	// 0xcf97d
+ (CGColorRef)_createCGColorFromOADFill:(id)oadfill andState:(id)state;	// 0xc99e1
+ (CGImageRef)_createImageFromOADImagefill:(id)oadimagefill withContext:(id)context;	// 0x1c0d4d
+ (void)_setupDrawingStyleInDrawingContext:(id)drawingContext fill:(id)fill stroke:(id)stroke state:(id)state;	// 0xc95f5
+ (void)_setupDrawingStyleInDrawingContext:(id)drawingContext stroke:(id)stroke state:(id)state;	// 0xc967d
+ (void)_setupDrawingStyleInDrawingContext:(id)drawingContext dash:(id)dash state:(id)state;	// 0xcfab5
@end

@interface CMShapeRenderer (Private)
@end
