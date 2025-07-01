//
//  AwemeListController.m
//  Douyin
//
//  Created by Your Name on 2024/1/1.
//  Copyright © 2024年 Your Name. All rights reserved.
//

#import "AwemeListController.h"
#import "Aweme.h"
#import "Comment.h"
#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/SDWebImage.h>
#import "AwemeListCell.h"
#import "CommentViewController.h"



@interface AwemeListController ()

@end

@implementation AwemeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"抖音";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self fetchAwemeList];
    
    // 创建TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.pagingEnabled = YES; // 关键：分页滚动
    [self.view addSubview:self.tableView];
    
    // 系统会自动为 TableView 的 contentInset.top 加上一段 Safe Area 的高度（比如 iPhone X 顶部的刘海/状态栏高度）。自动避开导航栏、状态栏、TabBar、Safe Area 等
    // 这里为了开始就让cell全屏，而不是向下偏移，把这个属性给禁用掉
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // Masonry布局
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    [self.tableView registerClass:[AwemeListCell class] forCellReuseIdentifier:@"AwemeListCell"];
}

//获取短视频列表
- (void)fetchAwemeList {
    NSString *urlString = @"http://127.0.0.1:4523/m1/6673336-0-default/awemes";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *awemeArr = [NSMutableArray array];
        for (NSDictionary *dict in responseObject) {
            Aweme *aweme = [[Aweme alloc] initWithDictionary:dict error:nil];
            // 强制类型转换
            if (aweme.comments.count > 0 && [aweme.comments[0] isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *commentModels = [NSMutableArray array];
                for (NSDictionary *commentDict in aweme.comments) {
                    Comment *comment = [[Comment alloc] initWithDictionary:commentDict error:nil];
                    [commentModels addObject:comment];
                }
                aweme.comments = commentModels;
            }
            [awemeArr addObject:aweme];
        }
        self.dataArray = awemeArr;
        [self.tableView reloadData];
        [self playCurrentVisibleCell];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"网络请求失败: %@", error);
    }];
    
}

// 滚动时持续触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self playCurrentVisibleCell];
}

// 滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self playCurrentVisibleCell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;
}

// 在 viewDidAppear: 里自动播放第一个 Cell：
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self playCurrentVisibleCell];
}

- (void)playCurrentVisibleCell {
    NSArray *visibleCells = [self.tableView visibleCells];
    for (AwemeListCell *cell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row == [self currentVisibleRow]) {
            [cell playVideo];
        } else {
            [cell pauseVideo];
        }
    }
}

//获取当前完全可见的 Cell 的行号
- (NSInteger)currentVisibleRow {
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows]; // 获取当前屏幕所有可见的cell的row（从上到下）
    CGFloat minOffset = CGFLOAT_MAX;
    NSInteger targetRow = 0;
    // 遍历所有可见的 indexPath
    for (NSIndexPath *indexPath in visibleRows) {
        // 获取该 indexPath 对应的 cell 的 frame（相对于 tableView 的坐标）
        CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
        // 计算 cell 顶部与 tableView 内容偏移量的绝对差值（即该 cell 顶部距离屏幕顶部的距离差）
        CGFloat offset = fabs(cellRect.origin.y - self.tableView.contentOffset.y);
        // 如果当前 cell 的偏移量更小，则更新目标行号
        if (offset < minOffset) {
            minOffset = offset;
            targetRow = indexPath.row;
        }
    }
    // 返回最接近顶部的行号
    return targetRow;
}

#pragma mark tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AwemeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AwemeListCell" forIndexPath:indexPath];
    Aweme *aweme = self.dataArray[indexPath.row];
    [cell configWithAweme:aweme];
    __weak typeof(self) weakSelf = self;
    cell.commentButtonTappedBlock = ^{
        CommentViewController *vc = [[CommentViewController alloc] init];
        vc.aweme = aweme;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    };
    cell.shareButtonTappedBlock = ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"分享" message:@"这里可以选择分享方式" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *wx = [UIAlertAction actionWithTitle:@"微信" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *qq = [UIAlertAction actionWithTitle:@"QQ" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:wx];
        [alert addAction:qq];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    return cell;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tableView reloadData];
    });
}

@end 
