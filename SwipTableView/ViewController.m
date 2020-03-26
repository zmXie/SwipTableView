//
//  ViewController.m
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "ViewController.h"
#import "DCSwipCell.h"
#import "TestCollectionViewCell.h"
#import <Masonry.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,DCSwipCellDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_titleArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SwipTableView";
    _titleArray = @[@"全部",@"峡谷之巅",@"艾欧尼亚",@"德玛西亚",@"诺克萨斯",@"班德尔城",@"黑色玫瑰",@"暗影岛",@"祖安"].mutableCopy;
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 100;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshUI)];
}

- (void)refreshUI
{
    DCSwipCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    if (cell.segment.layoutType == DCSegmentViewLayoutCenter) {
        cell.segment.layoutType = DCSegmentViewLayoutLeft;
        _titleArray = @[@"全部",@"峡谷之巅",@"艾欧尼亚",@"德玛西亚",@"诺克萨斯",@"班德尔城",@"黑色玫瑰",@"暗影岛",@"祖安"].mutableCopy;
    } else {
        cell.segment.layoutType = DCSegmentViewLayoutCenter;
        _titleArray = @[@"全部",@"关注",@"热门"].mutableCopy;
    }
    [cell reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *vc = [ViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DCSwipCellDataSource
/** 顶部标题数组 */
- (NSArray <NSString *>*)swipCellTopTitles
{
    return _titleArray;
}
/** 注册类 */
- (NSArray <NSString *>*)swipCellRegisterClasses
{
    return @[@"TestCollectionViewCell"];
}
/** 内容cell，类名即identifier */
- (UICollectionViewCell *)swipCellCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TestCollectionViewCell" forIndexPath:indexPath];
    cell.title = _titleArray[indexPath.item];
    [cell.tableView reloadData];
    return cell;
}


@end
