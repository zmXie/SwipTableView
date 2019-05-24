//
//  DCSwipCell.h
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCSegmentView.h"

@protocol DCSwipCellDataSource <NSObject>

@required
/** 顶部标题数组 */
- (NSArray *)swipCellTopTitles;
/** 内容视图 */
- (UITableView *)swipCellContentViewWithIndex:(NSInteger)index;

@end

@interface DCSwipCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView dataSource:(id<DCSwipCellDataSource>)dataSource;

@property (nonatomic, strong, readonly) DCSegmentView *segment;

- (void)reloadData;

@end
