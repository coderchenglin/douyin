//
//  BaseViewController.m
//  Douyin
//
//  Created by Your Name on 2024/1/1.
//  Copyright © 2024年 Your Name. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    self.view.backgroundColor = [UIColor blackColor];
    
    // 设置导航栏样式
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Setup Methods

- (void)setupNavigationBar {
    // 设置导航栏为透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    // 设置导航栏标题颜色
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
}

@end 
