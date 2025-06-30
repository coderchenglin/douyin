//
//  AwemeListController.m
//  Douyin
//
//  Created by Your Name on 2024/1/1.
//  Copyright © 2024年 Your Name. All rights reserved.
//

#import "AwemeListController.h"
#import "Aweme.h"
#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/SDWebImage.h>
#import "AwemeListCell.h"



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
    [self.view addSubview:self.tableView];
    
    // Masonry布局
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
    return 300;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AwemeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AwemeListCell" forIndexPath:indexPath];
    Aweme *aweme = self.dataArray[indexPath.row];
    [cell configWithAweme:aweme];
    return cell;
}


@end 
