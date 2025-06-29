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
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"网络请求失败: %@", error);
    }];
    
}

#pragma mark tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"AwemeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:24];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    Aweme *aweme = self.dataArray[indexPath.row];
    cell.textLabel.text = aweme.desc;
    cell.detailTextLabel.text = aweme.userName;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:aweme.coverUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    return cell;
}


@end 
