//
//  UserHomePageController.m
//  Douyin
//
//  Created by Your Name on 2024/1/1.
//  Copyright © 2024年 Your Name. All rights reserved.
//

#import "UserHomePageController.h"

@interface UserHomePageController ()

@end

@implementation UserHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"我的";
    
    // 创建临时标签
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = @"用户主页\n(待实现)";
    tempLabel.textColor = [UIColor whiteColor];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.numberOfLines = 0;
    tempLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:tempLabel];
    
    // 设置约束
    tempLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [tempLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [tempLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [tempLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
        [tempLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

@end 