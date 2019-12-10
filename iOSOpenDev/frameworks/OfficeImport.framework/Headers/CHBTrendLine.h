/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/CHBTrendLine.h>
#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface CHBTrendLine : XXUnknownSuperclass {
}
+ (void)readFrom:(XlChartTrendLine *)from toSeries:(id)series state:(id)state;	// 0x1ed27d
@end

@interface CHBTrendLine (Private)
+ (int)edTrendLineTypeFrom:(int)from order:(int)order;	// 0x1ed521
+ (id)readTrendlineGraphicProperties:(const XlChartSeriesFormat *)properties forStyleIndex:(int)styleIndex state:(id)state;	// 0x1ed9b9
@end
