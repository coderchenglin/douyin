//
//  MainTabBarController.m
//  Douyin
//
//  Created by Your Name on 2024/1/1.
//  Copyright © 2024年 Your Name. All rights reserved.
//

#import "MainTabBarController.h"
#import "AwemeListController.h"
#import "UserHomePageController.h"
#import "GroupChatController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置TabBar的外观
    [self setupTabBarAppearance];
    
    // 创建子视图控制器
    [self setupChildViewControllers];
}

#pragma mark - Setup Methods

- (void)setupTabBarAppearance {
    // 设置TabBar的背景色
    self.tabBar.backgroundColor = [UIColor blackColor];
    self.tabBar.barTintColor = [UIColor blackColor];
    
    // 设置TabBar的选中和未选中颜色
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.unselectedItemTintColor = [UIColor grayColor];
}

- (void)setupChildViewControllers {
    // 创建短视频流页面
    AwemeListController *awemeListVC = [[AwemeListController alloc] init];
    UINavigationController *awemeListNav = [[UINavigationController alloc] initWithRootViewController:awemeListVC];
    awemeListNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" 
                                                             image:[UIImage systemImageNamed:@"house"] 
                                                     selectedImage:[UIImage systemImageNamed:@"house.fill"]];
    
    // 创建个人主页
    UserHomePageController *userHomeVC = [[UserHomePageController alloc] init];
    UINavigationController *userHomeNav = [[UINavigationController alloc] initWithRootViewController:userHomeVC];
    userHomeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" 
                                                            image:[UIImage systemImageNamed:@"person"] 
                                                    selectedImage:[UIImage systemImageNamed:@"person.fill"]];
    
    // 创建聊天页面
    GroupChatController *groupChatVC = [[GroupChatController alloc] init];
    UINavigationController *groupChatNav = [[UINavigationController alloc] initWithRootViewController:groupChatVC];
    groupChatNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" 
                                                             image:[UIImage systemImageNamed:@"message"] 
                                                     selectedImage:[UIImage systemImageNamed:@"message.fill"]];
    
    // 设置子视图控制器
    self.viewControllers = @[awemeListNav, userHomeNav, groupChatNav];
}

@end 