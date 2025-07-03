#import "DYVideoCacheLoader.h"

@interface DYVideoCacheLoader ()
@property (nonatomic, strong) NSURL *originalURL; // 原始视频URL（http/https）
@property (nonatomic, strong) NSString *cacheDirectory; // 缓存文件存储目录
@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *> *pendingRequests; // 待处理的请求队列
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDataTask *> *taskMap; // 片段请求任务映射
@property (nonatomic, assign) long long expectedContentLength; // 视频总长度
@property (nonatomic, copy) NSString *mimeType; // 视频MIME类型（如video/mp4）
@end

@implementation DYVideoCacheLoader

- (instancetype)initWithOriginalURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.originalURL = url;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheRoot = [paths firstObject];
        self.cacheDirectory = [cacheRoot stringByAppendingPathComponent:@"DYVideoCache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        self.pendingRequests = [NSMutableArray array];
        self.taskMap = [NSMutableDictionary dictionary];
        self.expectedContentLength = 0;
        self.mimeType = @"video/mp4";
    }
    return self;
}

// 缓存文件路径生成
- (NSString *)cacheFilePath {
    NSString *fileName = [self.originalURL.absoluteString stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    return [self.cacheDirectory stringByAppendingPathComponent:fileName];
}

// 清理所有缓存（可在设置页调用）
+ (void)clearAllCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheRoot = [paths firstObject];
    NSString *cacheDir = [cacheRoot stringByAppendingPathComponent:@"DYVideoCache"];
    [[NSFileManager defaultManager] removeItemAtPath:cacheDir error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
}

// 拦截所有数据请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"✅ shouldWaitForLoadingOfRequestedResource called for: %@", loadingRequest.request.URL);
    @synchronized (self) {
        [self.pendingRequests addObject:loadingRequest];
    }
    [self processPendingRequests];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"🚫 didCancelLoadingRequest: %@", loadingRequest.request.URL);
    @synchronized (self) {
        [self.pendingRequests removeObject:loadingRequest];
    }
}

// 处理所有待处理请求
- (void)processPendingRequests {
    NSString *cachePath = [self cacheFilePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL hasCache = [fm fileExistsAtPath:cachePath];
    NSMutableArray *completedRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
        long long requestedLength = loadingRequest.dataRequest.requestedLength;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (currentOffset == 0) currentOffset = requestedOffset;
        NSLog(@"[DYVideoCacheLoader] processPendingRequests: offset=%lld length=%lld", currentOffset, requestedLength);
        // 1. 优先尝试本地缓存
        if (hasCache) {
            NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:cachePath];
            unsigned long long fileLength = [handle seekToEndOfFile];
            if (fileLength >= currentOffset + requestedLength) {
                [handle seekToFileOffset:currentOffset];
                NSData *subData = [handle readDataOfLength:(NSUInteger)requestedLength];
                [loadingRequest.dataRequest respondWithData:subData];
                [self fillContentInformation:loadingRequest contentLength:fileLength];
                [loadingRequest finishLoading];
                [completedRequests addObject:loadingRequest];
                [handle closeFile];
                continue;
            }
            [handle closeFile];
        }
        // 2. 未命中缓存，发起分片网络请求
        NSString *taskKey = [NSString stringWithFormat:@"%lld-%lld", currentOffset, currentOffset + requestedLength - 1];
        if (!self.taskMap[taskKey]) {
            [self startNetworkTaskForRequest:loadingRequest offset:currentOffset length:requestedLength taskKey:taskKey];
        }
    }
    @synchronized (self) {
        [self.pendingRequests removeObjectsInArray:completedRequests];
    }
}

// 发起分片网络请求，支持并发
- (void)startNetworkTaskForRequest:(AVAssetResourceLoadingRequest *)loadingRequest offset:(long long)offset length:(long long)length taskKey:(NSString *)taskKey {
    NSLog(@"[DYVideoCacheLoader] startNetworkTaskForRequest: offset=%lld length=%lld url=%@", offset, length, self.originalURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.originalURL];
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld", offset, offset + length - 1];
    [request setValue:range forHTTPHeaderField:@"Range"];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) wself = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSLog(@"[DYVideoCacheLoader] Network data received: %lu bytes", (unsigned long)data.length);
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
                NSLog(@"[DYVideoCacheLoader] HTTP headers: %@", httpResp.allHeaderFields);
            }
            // 1. 识别 contentType、contentLength
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
                NSString *type = httpResp.allHeaderFields[@"Content-Type"];
                if (type) wself.mimeType = type;
                NSString *lenStr = httpResp.allHeaderFields[@"Content-Range"];
                if (lenStr) {
                    // Content-Range: bytes 0-1023/123456
                    NSArray *parts = [lenStr componentsSeparatedByString:@"/"];
                    if (parts.count == 2) {
                        wself.expectedContentLength = [parts[1] longLongValue];
                    }
                } else if (httpResp.expectedContentLength > 0) {
                    wself.expectedContentLength = httpResp.expectedContentLength;
                }
            }
            // 2. 写入本地缓存（随机写入）
            NSString *cachePath = [wself cacheFilePath];
            if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                [[NSFileManager defaultManager] createFileAtPath:cachePath contents:nil attributes:nil];
            }
            NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:cachePath];
            [handle seekToFileOffset:offset];
            [handle writeData:data];
            [handle closeFile];
            // 3. 响应所有等待的请求
            [wself processPendingRequests];
        } else {
            NSLog(@"[DYVideoCacheLoader] Network error: %@", error);
            // 网络错误：finishLoadingWithError
            for (AVAssetResourceLoadingRequest *req in wself.pendingRequests) {
                [req finishLoadingWithError:error];
            }
        }
        [wself.taskMap removeObjectForKey:taskKey];
    }];
    self.taskMap[taskKey] = task;
    [task resume];
}

// 填充视频元信息，确保 AVPlayer 能识别
- (void)fillContentInformation:(AVAssetResourceLoadingRequest *)loadingRequest contentLength:(long long)contentLength {
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentType = self.mimeType ?: @"video/mp4";
    loadingRequest.contentInformationRequest.contentLength = contentLength > 0 ? contentLength : self.expectedContentLength;
}

@end 
