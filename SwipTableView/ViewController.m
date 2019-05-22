//
//  ViewController.m
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "ViewController.h"
#import "DCSwipCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,DCSwipCellDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 2) {
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
/** 内容个数 */
- (NSInteger)swipCellItemCount
{
    return 4;
}
/** 顶部标题数组 */
- (NSArray *)swipCellTopTitles
{
    return @[@"全部",@"医生",@"患者",@"医患之家"];
}
/** 内容视图 */
- (UIScrollView *)swipCellContentViewWithIndex:(NSInteger)index
{
    UITableView *tableView = [UITableView new];
    return tableView;
}


@end
