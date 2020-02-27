/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iPodUI.framework/iPodUI
 */

#import <iPodUI/iPodUI-Structs.h>
#import <iPodUI/IUMediaQueriesDataSource.h>


@interface IUPodcastsDataSource : IUMediaQueriesDataSource {
}
+ (id)queryCollectionPropertiesToFetch;	// 0x49369
+ (id)tabBarItemTitleKey;	// 0x48bc9
+ (id)tabBarItemIconName;	// 0x48bbd
+ (int)mediaEntityType;	// 0x48bb9
- (BOOL)shouldDisplayWhenEmpty;	// 0x49365
- (id)viewControllerContextForMediaQuery:(id)mediaQuery;	// 0x49319
- (id)viewControllerContextForIndex:(unsigned)index;	// 0x49259
- (void)setQueries:(id)queries;	// 0x49099
- (id)createNoContentDataSource;	// 0x48e4d
- (SEL)libraryHasDisplayableEntitiesSelector;	// 0x48e3d
- (void)createGlobalContexts;	// 0x48ca5
- (BOOL)canDeleteIndex:(unsigned)index;	// 0x48c21
- (BOOL)allowsDeletion;	// 0x48bd5
@end