//
//  AwemeListCell.h
//  Douyin
//
//  Created by chenglin on 2025/6/29.
//  Copyright © 2025 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Aweme;

NS_ASSUME_NONNULL_BEGIN

@interface AwemeListCell : UITableViewCell

- (void)configWithAweme:(Aweme *)aweme;

@end

NS_ASSUME_NONNULL_END
