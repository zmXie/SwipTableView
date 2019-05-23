//
//  ViewController.m
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "ViewController.h"
#import "DCSwipCell.h"
#import "TestTableView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,DCSwipCellDataSource>
{
    NSMutableArray *_titleArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleArray = @[@"全部",@"医生",@"患者"].mutableCopy;
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"row=%ld",(long)indexPath.row];
        return cell;
    } else {
        DCSwipCell *cell = [DCSwipCell cellWithTableView:tableView dataSource:self];
        return cell;
    }
}

#pragma mark - DCSwipCellDataSource
/** 顶部标题数组 */
- (NSArray *)swipCellTopTitles
{
    return _titleArray;
}
/** 内容视图 */
- (UIScrollView *)swipCellContentViewWithIndex:(NSInteger)index
{
    TestTableView *tableView = [TestTableView new];
    tableView.title = _titleArray[index];
    return tableView;
}
/** 标题是否可滑动，默认为NO */
- (BOOL)swipCellTitleCanScroll
{
    return NO;
}

@end
