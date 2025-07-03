#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DYVideoCacheLoader : NSObject <AVAssetResourceLoaderDelegate>

- (instancetype)initWithOriginalURL:(NSURL *)url;
+ (void)clearAllCache;
@end
