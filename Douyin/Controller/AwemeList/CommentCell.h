//
//  CommentCell.h
//  Douyin
//
//  Created by chenglin on 2025/7/1.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;   // 头像
@property (nonatomic, strong) UILabel *userNameLabel;         // 昵称
@property (nonatomic, strong) UILabel *contentLabel;          // 评论内容
@property (nonatomic, strong) UILabel *timeLabel;             // 时间
@property (nonatomic, strong) UIButton *likeButton;           // 点赞按钮
@property (nonatomic, strong) UILabel *likeCountLabel;        // 点赞数

// 配置cell数据
- (void)configWithComment:(Comment *)comment;

@end

NS_ASSUME_NONNULL_END
