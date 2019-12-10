/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/GMM.framework/GMM
 */

#import <GMM/GMM-Structs.h>



@protocol GEOTileDecoder <NSObject>
- (id)decodeTile:(id)tile forKey:(const GEOTileKey *)key;
- (BOOL)canDecodeTile:(const GEOTileKey *)tile quickly:(BOOL *)quickly;
@end
