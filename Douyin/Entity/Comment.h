//
//  Comment.h
//  Douyin
//
//  Created by chenglin on 2025/6/29.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface Comment : JSONModel

@property (nonatomic, copy) NSString *commentId;    // 评论ID
@property (nonatomic, copy) NSString *content;      // 评论内容
@property (nonatomic, copy) NSString *userName;     // 评论用户昵称
@property (nonatomic, copy) NSString *avatarUrl;    // 评论用户头像
@property (nonatomic, copy) NSString *createTime;   // 评论时间
@property (nonatomic, assign) NSInteger likeCount;  // 评论点赞数
@property (nonatomic, assign) BOOL isLiked;         // 是否已点赞

@end

NS_ASSUME_NONNULL_END 
