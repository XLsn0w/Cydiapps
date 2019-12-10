/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStore.framework/iTunesStore
 */




@protocol SSDownloadQueueObserver <NSObject>
- (void)downloadQueue:(id)queue changedWithRemovals:(id)removals;
@optional
- (void)downloadQueueNetworkUsageChanged:(id)changed;
- (void)downloadQueue:(id)queue downloadStatusChangedAtIndex:(int)index;
@end

