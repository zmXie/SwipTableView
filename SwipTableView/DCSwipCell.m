//
//  DCSwipCell.m
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "DCSwipCell.h"
#import "DCSwipSegment.h"
#import <Masonry.h>

#define DCScreenWidth [UIScreen mainScreen].bounds.size.width
#define DCScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DCSwipCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,  weak) UITableView * tableView;
@property (nonatomic,strong) DCSwipSegment * segment;
@property (nonatomic,strong) UICollectionView * collectionView;

@end

@implementation DCSwipCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    DCSwipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCSwipCell"];
    if(!cell){
        cell = [[DCSwipCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCSwipCell"];
        cell.selectionStyle = 0;
        cell.tableView = tableView;
        [cell initUI];
        [cell config];
    }
    return cell;
}

- (void)initUI
{
    self.segment.titleArray = @[@"全部",@"医生",@"患者",@"医患之家"];
    [self.contentView addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
    }];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(DCScreenHeight);
        make.bottom.mas_equalTo(0).priorityMedium();
    }];
}

- (void)config
{
    
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"segementCell" forIndexPath:indexPath];
   
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(DCScreenWidth, DCScreenHeight - self.segment.frame.size.height);
}

#pragma mark - Lazzy
- (DCSwipSegment *)segment
{
    if (!_segment) {
        _segment = [[DCSwipSegment alloc]initWithFrame:CGRectMake(0, 0, DCScreenWidth, 44) scrollEnabled:NO];
    }
    return _segment;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
    }
    return _collectionView;
}

@end
