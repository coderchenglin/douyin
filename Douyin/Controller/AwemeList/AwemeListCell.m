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
#import <SDWebImage/SDWebImage.h>

@interface AwemeListCell ()
// 视频容器
@property (nonatomic, strong) UIView *videoContainerView;
@property (nonatomic, strong) UIImageView *coverImageView;
// 右侧操作栏
@property (nonatomic, strong) UIView *rightActionContainer;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel *commentCountLabel;
@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, strong) UILabel *collectCountLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel *shareCountLabel;
// 底部信息区
@property (nonatomic, strong) UIView *bottomInfoContainer;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *musicLabel;
// 播放器相关
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, copy) NSString *currentVideoUrl;
@end

@implementation AwemeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone; // 关掉cell默认的，选中高亮
        // 1. 视频容器
        self.videoContainerView = [[UIView alloc] init];
        self.videoContainerView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.videoContainerView];
        
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.clipsToBounds = YES;
        self.coverImageView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.coverImageView];
        
        // 2. 右侧操作栏
        self.rightActionContainer = [[UIView alloc] init];
        [self.contentView addSubview:self.rightActionContainer];
        // 头像
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = 24;
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.layer.borderWidth = 2;
        self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.rightActionContainer addSubview:self.avatarImageView];
        // 点赞
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [self.likeButton setImage:[UIImage imageNamed:@"like_selected"] forState:UIControlStateSelected];
        [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.rightActionContainer addSubview:self.likeButton];
        self.likeCountLabel = [[UILabel alloc] init];
        self.likeCountLabel.textColor = [UIColor whiteColor];
        self.likeCountLabel.font = [UIFont systemFontOfSize:12];
        self.likeCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.rightActionContainer addSubview:self.likeCountLabel];
        // 评论
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.commentButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [self.commentButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.rightActionContainer addSubview:self.commentButton];
        self.commentCountLabel = [[UILabel alloc] init];
        self.commentCountLabel.textColor = [UIColor whiteColor];
        self.commentCountLabel.font = [UIFont systemFontOfSize:12];
        self.commentCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.rightActionContainer addSubview:self.commentCountLabel];
        // 收藏
        self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.collectButton setImage:[UIImage imageNamed:@"收藏"] forState:UIControlStateNormal];
        [self.collectButton setImage:[UIImage imageNamed:@"收藏 -已收藏"] forState:UIControlStateSelected];
        [self.collectButton addTarget:self action:@selector(collectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.rightActionContainer addSubview:self.collectButton];
        self.collectCountLabel = [[UILabel alloc] init];
        self.collectCountLabel.textColor = [UIColor whiteColor];
        self.collectCountLabel.font = [UIFont systemFontOfSize:12];
        self.collectCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.rightActionContainer addSubview:self.collectCountLabel];
        // 分享
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.rightActionContainer addSubview:self.shareButton];
        self.shareCountLabel = [[UILabel alloc] init];
        self.shareCountLabel.textColor = [UIColor whiteColor];
        self.shareCountLabel.font = [UIFont systemFontOfSize:12];
        self.shareCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.rightActionContainer addSubview:self.shareCountLabel];
        
        // 3. 底部信息区
        self.bottomInfoContainer = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomInfoContainer];
        
        self.userNameLabel = [[UILabel alloc] init];
        self.userNameLabel.font = [UIFont boldSystemFontOfSize:15];
        self.userNameLabel.textColor = [UIColor whiteColor];
        [self.bottomInfoContainer addSubview:self.userNameLabel];
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.font = [UIFont systemFontOfSize:14];
        self.descLabel.textColor = [UIColor whiteColor];
        self.descLabel.numberOfLines = 0;
        [self.bottomInfoContainer addSubview:self.descLabel];
        self.musicLabel = [[UILabel alloc] init];
        self.musicLabel.font = [UIFont systemFontOfSize:13];
        self.musicLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        [self.bottomInfoContainer addSubview:self.musicLabel];
        
        // Masonry布局
        [self.videoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.videoContainerView);
        }];
        [self.rightActionContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-12);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(60);
        }];
        // 右侧操作栏竖直排列
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.rightActionContainer);
            make.centerX.equalTo(self.rightActionContainer);
            make.width.height.mas_equalTo(48);
        }];
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(24);
            make.centerX.equalTo(self.rightActionContainer);
            make.width.height.mas_equalTo(40);
        }];
        [self.likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.likeButton.mas_bottom).offset(2);
            make.centerX.equalTo(self.rightActionContainer);
        }];
        [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.likeCountLabel.mas_bottom).offset(18);
            make.centerX.equalTo(self.rightActionContainer);
            make.width.height.mas_equalTo(40);
        }];
        [self.commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentButton.mas_bottom).offset(2);
            make.centerX.equalTo(self.rightActionContainer);
        }];
        [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentCountLabel.mas_bottom).offset(18);
            make.centerX.equalTo(self.rightActionContainer);
            make.width.height.mas_equalTo(40);
        }];
        [self.collectCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectButton.mas_bottom).offset(2);
            make.centerX.equalTo(self.rightActionContainer);
        }];
        [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectCountLabel.mas_bottom).offset(18);
            make.centerX.equalTo(self.rightActionContainer);
            make.width.height.mas_equalTo(40);
        }];
        [self.shareCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.shareButton.mas_bottom).offset(2);
            make.centerX.equalTo(self.rightActionContainer);
            make.bottom.equalTo(self.rightActionContainer);
        }];
        
        // 底部信息区
        [self.bottomInfoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(12);
            make.right.equalTo(self.rightActionContainer.mas_left).offset(-12);
            make.bottom.equalTo(self.contentView).offset(-12);
        }];
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.bottomInfoContainer);
            make.right.lessThanOrEqualTo(self.bottomInfoContainer);
        }];
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel);
            make.top.equalTo(self.userNameLabel.mas_bottom).offset(6);
            make.right.lessThanOrEqualTo(self.bottomInfoContainer);
        }];
        [self.musicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel);
            make.top.equalTo(self.descLabel.mas_bottom).offset(6);
            make.right.lessThanOrEqualTo(self.bottomInfoContainer);
            make.bottom.equalTo(self.bottomInfoContainer);
        }];
    }
    return self;
}

#pragma mark - 配置数据

- (void)configWithAweme:(Aweme *)aweme {
    self.aweme = aweme;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:aweme.coverUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.currentVideoUrl = aweme.videoUrl;
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@", aweme.userName];
    self.descLabel.text = aweme.desc;
    self.musicLabel.text = @"♫ 抖音-热门音乐"; // 可根据数据动态设置
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:aweme.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.likeButton.selected = aweme.isLiked;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.likeCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.commentCount];
    self.collectButton.selected = aweme.isCollected;
    self.collectCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.collectCount];
    self.shareCountLabel.text = [NSString stringWithFormat:@"%ld", (long)aweme.shareCount];
}

#pragma mark - 点赞/评论/收藏/分享

- (void)likeButtonTapped {
    self.aweme.isLiked = !self.aweme.isLiked;
    if (self.aweme.isLiked) {
        self.aweme.likeCount += 1;
        self.likeButton.selected = YES;
        [UIView animateWithDuration:0.15 animations:^{
            self.likeButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.likeButton.transform = CGAffineTransformIdentity;
            }];
        }];
    } else {
        self.aweme.likeCount -= 1;
        self.likeButton.selected = NO;
    }
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.aweme.likeCount];
}

- (void)commentButtonTapped {
    if (self.commentButtonTappedBlock) {
        self.commentButtonTappedBlock();
    }
}

- (void)collectButtonTapped {
    self.collectButton.selected = !self.collectButton.selected;
    // 收藏数可根据需求自增/自减
    if (self.aweme.isCollected) {
        self.aweme.collectCount += 1;
        self.collectButton.selected = YES;
    } else {
        self.aweme.collectCount -= 1;
        self.collectButton.selected = NO;
    }
    self.collectCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.aweme.collectCount];
}

- (void)shareButtonTapped {
    if (self.shareButtonTappedBlock) {
        self.shareButtonTappedBlock();
    }
}

#pragma mark - 视频播放相关（略，后续产品级优化再完善）
- (void)playVideo {
    if (!self.currentVideoUrl) return;
    if (!self.player) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.currentVideoUrl]];
        self.player = [AVPlayer playerWithPlayerItem:item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.videoContainerView.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.videoContainerView.layer addSublayer:self.playerLayer];
        // 循环播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replayVideo) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    }
    self.playerLayer.frame = self.videoContainerView.bounds;
    [self.player play];
    self.coverImageView.alpha = 0.0;
}

- (void)pauseVideo {
    [self.player pause];
}

- (void)replayVideo {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self pauseVideo];
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;
    self.playerLayer = nil;
    self.currentVideoUrl = nil;
    self.coverImageView.alpha = 1.0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
