/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/CHBAxis.h>
#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface CHBAxis : XXUnknownSuperclass {
}
+ (id)readWithXlPlotAxis:(int)xlPlotAxis state:(id)state;	// 0x168c25
+ (int)chbAxisIdForPlotAxis:(int)plotAxis state:(id)state;	// 0x16a7a9
@end

@interface CHBAxis (Private)
+ (Class)chbAxisClassWith:(XlChartPlotAxis *)with plotAxis:(int)axis;	// 0x16a1ed
+ (Class)chbAxisClassWith:(id)with;	// 0x25df3d
+ (int)xlPlotAxisTypeFrom:(int)from;	// 0x25df21
+ (int)chdAxisPositionFromAxisType:(int)axisType;	// 0x16a811
@end
