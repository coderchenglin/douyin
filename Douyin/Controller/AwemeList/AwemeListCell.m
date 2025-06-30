//
//  AwemeListCell.m
//  Douyin
//
//  Created by chenglin on 2025/6/29.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import "AwemeListCell.h"
#import "Aweme.h"
#import <Masonry/Masonry.h>
#import "SDWebImage/SDWebImage.h"
#import <AVFoundation/AVFoundation.h> // 苹果音视频框架

@interface AwemeListCell ()

@property (nonatomic, strong) Aweme *aweme;

@property (nonatomic, strong) UIView *videoContainerView; // 用于承载AVPlayerLayer
@property (nonatomic, strong) UIImageView *coverImageView; //封面图片视图
@property (nonatomic, strong) UILabel *descLabel; // 视屏描述标签
@property (nonatomic, strong) UILabel *userNameLabel; // 用户名标签
@property (nonatomic, strong) AVPlayer *player; // 视频播放器
@property (nonatomic, strong) AVPlayerLayer *playerLayer; // 视频播放器显示器
@property (nonatomic, copy) NSString *currentVideoUrl; // 当前要播放的视频URL

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel *commentCountLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel *shareCountLabel;


@end

@implementation AwemeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        // 视频容器
        self.videoContainerView = [[UIView alloc] init];
        self.videoContainerView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.videoContainerView];
        
        // 封面图
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill; // 图片会按比例缩放尺寸，保持宽高比，会完整显示不会裁剪
        self.coverImageView.clipsToBounds = YES; // 超出部分会裁剪
        [self.contentView addSubview:self.coverImageView];
        
        // 描述
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.textColor = [UIColor whiteColor];
        self.descLabel.font = [UIFont boldSystemFontOfSize:20]; // 加粗20号字体
        [self.contentView addSubview:self.descLabel];
        
        // 用户名
        self.userNameLabel = [[UILabel alloc] init];
        self.userNameLabel.textColor = [UIColor lightGrayColor];
        self.userNameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.userNameLabel];
        
        // 点赞按钮
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.likeButton];
        
        self.likeCountLabel = [[UILabel alloc] init];
        self.likeCountLabel.textColor = [UIColor whiteColor];
        self.likeCountLabel.font = [UIFont systemFontOfSize:12];
        [self.likeCountLabel addSubview:self.likeCountLabel];
        
        // 评论按钮
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.commentButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.commentButton];

        self.commentCountLabel = [[UILabel alloc] init];
        self.commentCountLabel.textColor = [UIColor whiteColor];
        self.commentCountLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.commentCountLabel];
        
        // 分享按钮
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.shareButton];

        self.shareCountLabel = [[UILabel alloc] init];
        self.shareCountLabel.textColor = [UIColor whiteColor];
        self.shareCountLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.shareCountLabel];
        
        // Masonry布局
        [self.videoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(220);
        }];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.videoContainerView);
        }];
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.coverImageView.mas_bottom).offset(8);
            make.left.equalTo(self.contentView).offset(12);
            make.right.equalTo(self.contentView).offset(-12);
        }];
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.descLabel.mas_bottom).offset(4);
            make.left.equalTo(self.descLabel);
            make.right.equalTo(self.descLabel);
            make.bottom.equalTo(self.contentView).offset(-12);
        }];
        
        // 按钮布局（右下角竖直排列）
        [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-16);
            make.bottom.equalTo(self.contentView).offset(-16);
            make.width.height.mas_equalTo(32);
        }];
        [self.shareCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareButton);
            make.top.equalTo(self.shareButton.mas_bottom).offset(2);
        }];
        [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareButton);
            make.bottom.equalTo(self.shareButton.mas_top).offset(-24);
            make.width.height.mas_equalTo(32);
        }];
        [self.commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.commentButton);
            make.top.equalTo(self.commentButton.mas_bottom).offset(2);
        }];
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareButton);
            make.bottom.equalTo(self.commentButton.mas_top).offset(-24);
            make.width.height.mas_equalTo(32);
        }];
        [self.likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.likeButton);
            make.top.equalTo(self.likeButton.mas_bottom).offset(2);
        }];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.playerLayer) {
        self.playerLayer.frame = self.videoContainerView.bounds;
    }
}

// 复用前的清理工作
- (void)prepareForReuse {
    [super prepareForReuse];
    [self pauseVideo]; //暂停视频
    [self.playerLayer removeFromSuperlayer]; // 一出播放层
    self.player = nil; // 释放播放器
    self.playerLayer = nil; //释放播放层
    self.currentVideoUrl = nil; //清空当前视频URL
    self.coverImageView.alpha = 1.0;
}

// 配置Cell数据
- (void)configWithAweme:(Aweme *)aweme {
    self.aweme = aweme;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:aweme.coverUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.descLabel.text = aweme.desc;
    self.userNameLabel.text = aweme.userName;
    self.currentVideoUrl = aweme.videoUrl; // 保存视频url
    self.coverImageView.alpha = 1.0; // 每次配置都先显示封面
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.likeCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.commentCount];
    self.shareCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.shareCount];
    [self.likeButton setImage:[UIImage imageNamed:(aweme.isLiked ? @"like_selected" : @"like")] forState:UIControlStateNormal];
}

#pragma mark 视频播放

// 播放视频
- (void)playVideo {
    // 如果没有视频URL就返回
    if (!self.currentVideoUrl)
        return;
    
    if (!self.player) {
        // 创建AVPlayerItem(视频资源项）
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.currentVideoUrl]];
        
        // 创建AVPlayer播放器
        self.player = [AVPlayer playerWithPlayerItem:item];
        
        // 创建AVPlayerLayer用于显示视频
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.videoContainerView.bounds; // playerLayer的大小要和ContainerView一样
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 填充模式
        [self.videoContainerView.layer addSublayer:self.playerLayer];
        
        // 添加播放完成通知，实现循环播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replayVideo) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    }
    // 每次播放都设置frame
    self.playerLayer.frame = self.videoContainerView.bounds;
    [self.player play]; // 开始播放
    self.coverImageView.alpha = 0.0;
}

// 暂停视频
- (void)pauseVideo {
    [self.player pause];
//    self.coverImageView.alpha = 1.0;
}

// 重新播放视频
- (void)replayVideo {
    //跳转到开始位置
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark 转评赞
- (void)likeButtonTapped {
    self.aweme.isLiked = !self.aweme.isLiked;
    if (self.aweme.isLiked) {
        self.aweme.likeCount += 1;
        [self.likeButton setImage:[UIImage imageNamed:@"like_selected"] forState:UIControlStateNormal];
        // 动画
        [UIView animateWithDuration:0.15 animations:^{
            self.likeButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.likeButton.transform = CGAffineTransformIdentity;
            }];
        }];
    } else {
        self.aweme.likeCount -= 1;
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.aweme.likeCount];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
