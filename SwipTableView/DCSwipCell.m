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
#import <ReactiveObjC.h>

#define DCScreenWidth [UIScreen mainScreen].bounds.size.width
#define DCScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DCSwipCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,  weak) UITableView * tableView;
@property (nonatomic,strong) DCSwipSegment * segment;
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,  weak) id<DCSwipCellDataSource> dataSource;

@end

@implementation DCSwipCell

+ (instancetype)cellWithTableView:(UITableView *)tableView dataSource:(id<DCSwipCellDataSource>)dataSource
{
    DCSwipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCSwipCell"];
    if(!cell){
        cell = [[DCSwipCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCSwipCell"];
        cell.selectionStyle = 0;
        cell.tableView = tableView;
        cell.dataSource = dataSource;
        [cell initUI];
    }
    return cell;
}

- (void)initUI
{
    self.segment.titleArray = [self.dataSource swipCellTopTitles];
    [self.contentView addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
    }];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(DCScreenHeight-self.segment.frame.size.height);
        make.bottom.mas_equalTo(0).priorityMedium();
    }];
    [self catchMethodWithScrollView:self.tableView];
}

- (void)catchMethodWithScrollView:(UIScrollView *)scrollView
{
    __weak typeof(self)weakSelf = self;
    [[(NSObject *)self.tableView.delegate rac_signalForSelector:@selector(scrollViewDidScroll:)] subscribeNext:^(RACTuple * _Nullable x) {
        RACTupleUnpack(UIScrollView *sc) = x;
        [weakSelf configScroll:sc];
    }];
}

- (void)configScroll:(UIScrollView *)sc
{
    if (sc == self.tableView) { //外层主tableView
        NSLog(@"外层：%@",sc);
    } else { //内层子scrollView
        NSLog(@"内层：%@",sc);
    }
}

- (void)reloadData
{
    self.segment.titleArray = [self.dataSource swipCellTopTitles];
    [self.collectionView reloadData];
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource swipCellItemCount];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contentCell" forIndexPath:indexPath];
    UIScrollView *scrollView = [cell.contentView viewWithTag:999];
    if (!scrollView) {
        scrollView = [self.dataSource swipCellContentViewWithIndex:indexPath.item];
        scrollView.frame = cell.contentView.bounds;
        scrollView.tag = 999;
        [cell.contentView addSubview:scrollView];
        [self catchMethodWithScrollView:scrollView];
    }
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
        BOOL canScroll = NO;
        if ([self.dataSource respondsToSelector:@selector(swipCellTitleCanScroll)]) {
            canScroll = [self.dataSource swipCellTitleCanScroll];
        }
        _segment = [[DCSwipSegment alloc]initWithFrame:CGRectMake(0, 0, DCScreenWidth, 44) scrollEnabled:canScroll];
    }
    return _segment;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.allowsSelection = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"contentCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

@end


@interface  NSObject (DCSwip)

@end

@implementation NSObject (DCSwip)

- (void)scrollViewDidScroll:(UIScrollView *)sc{}

@end

