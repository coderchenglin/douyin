//
//  Aweme.h
//  Douyin
//
//  Created by chenglin on 2025/6/29.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import "BaseModel.h"
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface Aweme : JSONModel

@property (nonatomic, copy) NSString *awemeId;      // 短视频ID
@property (nonatomic, copy) NSString *desc;         // 视频描述
@property (nonatomic, copy) NSString *videoUrl;     // 视频播放地址
@property (nonatomic, copy) NSString *coverUrl;     // 封面图片地址
@property (nonatomic, copy) NSString *userName;     // 用户昵称
@property (nonatomic, copy) NSString *avatarUrl;    // 用户头像

@end

NS_ASSUME_NONNULL_END
