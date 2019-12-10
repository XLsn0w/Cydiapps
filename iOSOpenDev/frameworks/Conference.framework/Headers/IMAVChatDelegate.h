/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/Conference.framework/Conference
 */



@protocol IMAVChatDelegate
@optional
- (void)avChat:(id)chat stateChanged:(unsigned)changed;
- (void)avChat:(id)chat didAddParticipant:(id)participant;
- (void)avChat:(id)chat willRemoveParticipants:(id)participants;
- (void)avChat:(id)chat didRemoveParticipant:(id)participant;
- (void)avChat:(id)chat participant:(id)participant changedFromState:(unsigned)state toState:(unsigned)state4;
- (void)avChat:(id)chat didSendInvitationForParticipant:(id)participant;
- (void)avChat:(id)chat networkStalled:(BOOL)stalled;
- (void)avChat:(id)chat networkStalled:(BOOL)stalled forRemoteParticipant:(id)remoteParticipant;
- (void)avChat:(id)chat receivedFirstPreviewForParticipant:(id)participant;
- (void)avChat:(id)chat receivedFirstRemoteFrameForParticipant:(id)participant;
- (void)receivedFirstPreviewForAVChat:(id)avchat;
- (void)receivedFirstRemoteFrameForAVChat:(id)avchat;
- (void)remoteCameraBeingChangedForAVChat:(id)avchat;
- (void)remoteCameraDidChangeForAVChat:(id)remoteCamera newCameraType:(unsigned)type;
- (void)avChat:(id)chat remoteOrientationChanged:(unsigned)changed;
- (void)avChat:(id)chat irisStateChanged:(unsigned)changed;
- (void)avChat:(id)chat remoteParticipant:(id)participant muteChanged:(BOOL)changed;
- (void)avChat:(id)chat remoteParticipant:(id)participant pauseChanged:(BOOL)changed;
@end

