/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CertInfo.framework/CertInfo
 */


#import <CertInfo/UITableViewDataSource.h>
#import <CertInfo/CertInfo-Structs.h>

@class UITableView, NSMutableArray;

@interface CertInfoCertificateDetailsView : NSObject <UITableViewDataSource> {
	UITableView *_tableView;	// 48 = 0x30
	NSMutableArray *_tableSections;	// 52 = 0x34
}
- (id)tableView:(id)view titleForHeaderInSection:(int)section;	// 0x4401
- (int)numberOfSectionsInTableView:(id)tableView;	// 0x43e1
- (id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;	// 0x42b9
- (id)_detailForIndexPath:(id)indexPath;	// 0x4225
- (id)_titleForIndexPath:(id)indexPath;	// 0x4191
- (int)tableView:(id)view numberOfRowsInSection:(int)section;	// 0x411d
- (void)layoutSubviews;	// 0x40c1
- (void)dealloc;	// 0x4061
- (id)initWithFrame:(CGRect)frame certificateProperties:(id)properties;	// 0x3f55
- (id)_sectionsFromProperties:(id)properties;	// 0x3d91
- (id)_sectionInfoForCertSection:(id)certSection title:(id)title;	// 0x3d35
- (id)_cellInfosForSection:(id)section;	// 0x3b25
- (void)appendInfoFromCertView:(id)certView;	// 0x3ab5
@end
