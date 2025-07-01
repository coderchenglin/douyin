//
//  CommentViewController.m
//  Douyin
//
//  Created by chenglin on 2025/7/1.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import "CommentViewController.h"
#import "Aweme.h"
#import "Comment.h"
#import "CommentCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *inputContainer;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"评论";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1. 评论列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:@"CommentCell"];
    [self.view addSubview:self.tableView];
    
    // 2. 输入区
    self.inputContainer = [[UIView alloc] init];
    self.inputContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    [self.view addSubview:self.inputContainer];
    
    self.inputTextField = [[UITextField alloc] init];
    self.inputTextField.placeholder = @"说点什么...";
    self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.inputContainer addSubview:self.inputTextField];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    [self.inputContainer addSubview:self.sendButton];
    
    // Masonry布局
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.inputContainer.mas_top);
    }];
    [self.inputContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputContainer).offset(16);
        make.centerY.equalTo(self.inputContainer);
        make.right.equalTo(self.sendButton.mas_left).offset(-16);
        make.height.mas_equalTo(36);
    }];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.inputContainer).offset(-16);
        make.centerY.equalTo(self.inputContainer);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(36);
    }];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.aweme.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    Comment *comment = self.aweme.comments[indexPath.row];
    [cell configWithComment:comment];
    return cell;
}

- (void)sendComment {
    NSString *text = self.inputTextField.text;
    if (text.length == 0) {
        return;
    }
    
    Comment *newComment = [[Comment alloc] init];
    newComment.commentId = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    newComment.content = text;
    newComment.userName = @"我";
    newComment.avatarUrl = @"https://dummyimage.com/100x100";
    newComment.createTime = [self formatDate:[NSDate date]];
    newComment.likeCount = 0;
    newComment.isLiked = NO;
    
    NSMutableArray *comments = [self.aweme.comments mutableCopy] ?: [NSMutableArray array];
    [comments addObject:newComment];
    self.aweme.comments = comments;
    self.aweme.commentCount = comments.count;
    
    [self.tableView reloadData];
    self.inputTextField.text = @"";
    
    // 显示成功提示
    [self showToast:@"评论发送成功"];
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:date];
}

- (void)showToast:(NSString *)message {
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.text = message;
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    toastLabel.layer.cornerRadius = 20;
    toastLabel.layer.masksToBounds = YES;
    [self.view addSubview:toastLabel];
    
    [toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
    }];
    
    [UIView animateWithDuration:2.0 animations:^{
        toastLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [toastLabel removeFromSuperview];
    }];
}

@end
