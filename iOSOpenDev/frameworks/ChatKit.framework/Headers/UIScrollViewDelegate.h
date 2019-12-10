/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/ChatKit.framework/ChatKit
 */


#import <ChatKit/ChatKit-Structs.h>


@protocol UIScrollViewDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(id)scrollView;
- (void)scrollViewDidZoom:(id)scrollView;
- (void)scrollViewWillBeginDragging:(id)scrollView;
- (void)scrollViewWillEndDragging:(id)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)offset;
- (void)scrollViewDidEndDragging:(id)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewWillBeginDecelerating:(id)scrollView;
- (void)scrollViewDidEndDecelerating:(id)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(id)scrollView;
- (id)viewForZoomingInScrollView:(id)scrollView;
- (void)scrollViewWillBeginZooming:(id)scrollView withView:(id)view;
- (void)scrollViewDidEndZooming:(id)scrollView withView:(id)view atScale:(float)scale;
- (BOOL)scrollViewShouldScrollToTop:(id)scrollView;
- (void)scrollViewDidScrollToTop:(id)scrollView;
@end
