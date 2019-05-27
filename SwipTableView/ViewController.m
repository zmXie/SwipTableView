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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,DCSwipCellDataSource>
{
    NSMutableArray *_titleArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SwipTableView";
    _titleArray = @[@"全部",@"艾欧尼亚",@"德玛西亚",@"诺克萨斯",@"班德尔城",@"黑色玫瑰",@"皮城警备",@"暗影岛",@"祖安"].mutableCopy;
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
