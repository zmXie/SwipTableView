//
//  TestTableView.h
//  SwipTableView
//
//  Created by xzm on 2019/5/23.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableView : UITableView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSString * title;

@end
