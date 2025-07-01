//
//  CommentCell.m
//  Douyin
//
//  Created by chenglin on 2025/7/1.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "Masonry/Masonry.h"
#import <SDWebImage/SDWebImage.h>

@interface CommentCell ()
@property (nonatomic, strong) Comment *comment;
@end

@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 头像
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = 18;
        self.avatarImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.avatarImageView];
        
        // 昵称
        self.userNameLabel = [[UILabel alloc] init];
        self.userNameLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:self.userNameLabel];
        
        // 评论内容
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        // 时间
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.timeLabel];
        
        // 点赞按钮
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage imageNamed:@"like_selected"] forState:UIControlStateSelected];
        [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.likeButton];
        
        // 点赞数
        self.likeCountLabel = [[UILabel alloc] init];
        self.likeCountLabel.font = [UIFont systemFontOfSize:12];
        self.likeCountLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.likeCountLabel];
        
        // Masonry布局
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.mas_equalTo(36);
        }];
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).offset(10);
            make.top.equalTo(self.avatarImageView);
            make.right.lessThanOrEqualTo(self.likeButton.mas_left).offset(-10);
        }];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel);
            make.top.equalTo(self.userNameLabel.mas_bottom).offset(4);
            make.right.lessThanOrEqualTo(self.likeButton.mas_left).offset(-10);
        }];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel);
            make.top.equalTo(self.contentLabel.mas_bottom).offset(4);
            make.bottom.equalTo(self.contentView).offset(-12);
        }];
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-16);
            make.top.equalTo(self.avatarImageView);
            make.width.height.mas_equalTo(28);
        }];
        [self.likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.likeButton);
            make.top.equalTo(self.likeButton.mas_bottom).offset(2);
        }];
    }
    return self;
}

#pragma mark - 配置数据

- (void)configWithComment:(Comment *)comment {
    self.comment = comment;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.avatarUrl]];
    self.userNameLabel.text = comment.userName;
    self.contentLabel.text = comment.content;
    self.timeLabel.text = comment.createTime;
    self.likeButton.selected = comment.isLiked;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)comment.likeCount];
}

#pragma mark - 点赞按钮点击

- (void)likeButtonTapped {
    self.comment.isLiked = !self.comment.isLiked;
    if (self.comment.isLiked) {
        self.comment.likeCount += 1;
        self.likeButton.selected = YES;
        // 动画
        [UIView animateWithDuration:0.15 animations:^{
            self.likeButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.likeButton.transform = CGAffineTransformIdentity;
            }];
        }];
    } else {
        self.comment.likeCount -= 1;
        self.likeButton.selected = NO;
    }
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.comment.likeCount];
    
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
