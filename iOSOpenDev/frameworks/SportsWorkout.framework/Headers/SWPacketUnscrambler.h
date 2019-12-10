/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/SportsWorkout.framework/SportsWorkout
 */

#import <SportsWorkout/SportsWorkout-Structs.h>
#import <SportsWorkout/XXUnknownSuperclass.h>


@interface SWPacketUnscrambler : XXUnknownSuperclass {
	IapSimpleRemoteButtonState m_ButtonState[135];	// 4 = 0x4
}
/* iOSOpenDev: commented-out (bad name)
- (id).cxx_construct;	// 0x32d0d
*/
- (id)_handleButtonsPressedForCommandId:(int)commandId newButtonStatus:(unsigned)status;	// 0x32bf5
- (char *)_getBlanPayloadPtr:(BlanSportsDataFrame *)ptr;	// 0x32b59
- (unsigned char)_getBlanPayloadLen:(BlanSportsDataFrame *)len;	// 0x32b35
- (unsigned char)_getBlanDstAddrLen:(BlanSportsDataFrame *)len;	// 0x32b0d
- (unsigned char)_getBlanTimingByte:(BlanSportsDataFrame *)byte;	// 0x32a89
- (unsigned)_getBlanDstAddr:(BlanSportsDataFrame *)addr;	// 0x329d9
- (unsigned char)_getBlanSrcAddrLen:(BlanSportsDataFrame *)len;	// 0x329c5
- (unsigned)_getBlanDstType:(BlanSportsDataFrame *)type;	// 0x32941
- (unsigned char)_getBlanDstTypeLen:(BlanSportsDataFrame *)len;	// 0x32925
- (unsigned char)_getBlanDstFlags:(BlanSportsDataFrame *)flags;	// 0x328fd
- (unsigned)_getBlanSrcAddr:(BlanSportsDataFrame *)addr;	// 0x32899
- (unsigned)_getBlanSrcType:(BlanSportsDataFrame *)type;	// 0x32851
- (unsigned char)_getBlanSrcTypeLen:(BlanSportsDataFrame *)len;	// 0x32849
- (unsigned char)_getBlanSrcFlags:(BlanSportsDataFrame *)flags;	// 0x32845
- (void)_descramblePayload:(BlanSportsDataFrame *)payload;	// 0x32735
- (id)payloadForDataFrame:(id)dataFrame;	// 0x326f1
- (id)unscrambleRunSensorDataFrame:(id)frame;	// 0x32549
- (id)dataFrameForBlanPayload:(id)blanPayload radioId:(unsigned *)anId;	// 0x32505
- (id)sourceTypeForBlanPayload:(id)blanPayload;	// 0x324b5
- (id)buttonStatesForDataFrame:(id)dataFrame;	// 0x32401
@end
