//
//  AwemeListController.h
//  Douyin
//
//  Created by Your Name on 2024/1/1.
//  Copyright © 2024年 Your Name. All rights reserved.
//

#import "BaseViewController.h"

@class Aweme;

@interface AwemeListController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<Aweme *> *dataArray; // 后续会用模型数组

@end
