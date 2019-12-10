/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary
 */




@protocol PLDraggingDestination <NSObject>
- (void)concludeDragOperation:(id)operation;
- (BOOL)performDragOperation:(id)operation;
- (BOOL)prepareForDragOperation:(id)dragOperation;
@optional
- (void)draggingExited:(id)exited;
- (void)draggingEnded:(id)ended;
- (int)draggingUpdated:(id)updated;
- (int)draggingEntered:(id)entered;
@end

