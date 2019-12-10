/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CoreDAV.framework/CoreDAV
 */

#import <CoreDAV/XXUnknownSuperclass.h>

@class NSArray;
@protocol CoreDAVAccountInfoProvider;

@interface CoreDAVRequestLogger : XXUnknownSuperclass {
	id<CoreDAVAccountInfoProvider> _provider;	// 4 = 0x4
	NSArray *_responseHeadersSortDescriptors;	// 8 = 0x8
	int _snippetsLogged;	// 12 = 0xc
}
@property(retain) NSArray *responseHeadersSortDescriptors;	// G=0x1f299; S=0x1f2ad; @synthesize=_responseHeadersSortDescriptors
// declared property setter: - (void)setResponseHeadersSortDescriptors:(id)descriptors;	// 0x1f2ad
// declared property getter: - (id)responseHeadersSortDescriptors;	// 0x1f299
- (void)finishCoreDAVResponse;	// 0x1f185
- (void)logCoreDAVResponseSnippet:(id)snippet;	// 0x1f09d
- (void)logCoreDAVResponseHeaders:(id)headers andStatusCode:(int)code;	// 0x1eda5
- (void)logCoreDAVRequest:(id)request;	// 0x1e819
- (id)_inflateRequestBody:(id)body;	// 0x1e6f1
- (void)dealloc;	// 0x1e691
- (id)initWithProvider:(id)provider;	// 0x1e591
@end
