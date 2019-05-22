//
//  DCSwipCell.h
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCSwipCellDataSource <NSObject>

@required

/** 内容个数 */
- (NSInteger)swipCellItemCount;
/** 顶部标题数组 */
- (NSArray *)swipCellTopTitles;
/** 内容视图 */
- (UIScrollView *)swipCellContentViewWithIndex:(NSInteger)index;

@optional
/** 标题是否可滑动，默认为NO */
- (BOOL)swipCellTitleCanScroll;

@end

@interface DCSwipCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView dataSource:(id<DCSwipCellDataSource>)dataSource;

- (void)reloadData;

@end


