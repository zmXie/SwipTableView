//
//  TestCollectionViewCell.h
//  SwipTableView
//
//  Created by xzm on 2019/5/27.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestCollectionViewCell : UICollectionViewCell <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSString * title;

@end
