//
//  AwemeListCell.h
//  Douyin
//
//  Created by chenglin on 2025/6/29.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> // 苹果音视频框架

@class Aweme;

NS_ASSUME_NONNULL_BEGIN

@interface AwemeListCell : UITableViewCell

@property (nonatomic, strong) Aweme *aweme;

// 只暴露必要的 block 回调
@property (nonatomic, copy) void (^commentButtonTappedBlock)(void);
@property (nonatomic, copy) void (^shareButtonTappedBlock)(void);

// 配置cell数据
- (void)configWithAweme:(Aweme *)aweme;
- (void)playVideo;
- (void)pauseVideo;

@end

NS_ASSUME_NONNULL_END
