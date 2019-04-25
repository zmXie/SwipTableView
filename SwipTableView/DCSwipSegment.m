//
//  DCSwipSegment.m
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "DCSwipSegment.h"

#define DCWidth(view)  view.frame.size.width
#define DCHeight(view) view.frame.size.height
#define DCSegmentGap 12
#define DCSegemtFont [UIFont systemFontOfSize:14]

@interface DCSwipSegment ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    UICollectionView *_collectionV;
    UIView *_lineView;
    NSIndexPath *_selectIndexPath;
    NSIndexPath *_lastSelectIndexPath;
    NSMutableArray *_widthArray;
    CGFloat _itemMinWidth;
}

@end

@implementation DCSwipSegment

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame scrollEnabled:(BOOL)scrollEnabled
{
    self = [self initWithFrame:frame];
    _collectionV.scrollEnabled = NO;
    return self;
}

#pragma mark -- privateMethod
- (void)setUp
{
    _themeColor = [UIColor redColor];
    _itemMinWidth = 55;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    _collectionV = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionV.showsHorizontalScrollIndicator = NO;
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    [_collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"segementCell"];
    _collectionV.backgroundColor = [UIColor whiteColor];
    [self addSubview:_collectionV];

//    UIView *sepLine = [[UIView alloc]initWithFrame:CGRectMake(0, DCHeight(self) - 1, DCWidth(self), 1)];
//    sepLine.backgroundColor = [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1];
//    [self addSubview:sepLine];

    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, DCHeight(self) - 4, _itemMinWidth, 4)];
    _lineView.backgroundColor = _themeColor;
    [_collectionV addSubview:_lineView];

    _selectIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    _lastSelectIndexPath = _selectIndexPath;
}

- (void)setTitleArray:(NSArray *)titleArray
{
    _titleArray = titleArray;
    if (!_collectionV.scrollEnabled) {
        _itemMinWidth = DCWidth(self) / _titleArray.count;
        CGRect newframe = _lineView.frame;
        newframe.size.width = _itemMinWidth;
        _lineView.frame = newframe;
    }
    _widthArray = [NSMutableArray arrayWithCapacity:_titleArray.count];
    for (NSString *str in _titleArray) {
        CGFloat width = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, DCHeight(_collectionV)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: DCSegemtFont } context:nil].size.width;
        width += DCSegmentGap;
        width = MAX(_itemMinWidth, width);
        [_widthArray addObject:@(width)];
    }

    [_collectionV reloadData];
}

/**
 选中某一item

 @param index 索引
 */
- (void)selectItemToIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    if (_collectionV.scrollEnabled) {
        [_collectionV scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    } else {
        [_collectionV selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }

    _selectIndexPath = indexPath;

    [self resetChangeViews];

    if (!_collectionV.scrollEnabled && self.segementSelectBlock) {
        _segementSelectBlock(indexPath.item, _titleArray[indexPath.item]);
    }
}

- (void)resetChangeViews
{
    UICollectionViewCell *lastCell = [_collectionV cellForItemAtIndexPath:_lastSelectIndexPath];
    if (lastCell) {
        UILabel *label = [lastCell.contentView viewWithTag:100];
        label.textColor = [UIColor darkGrayColor];
    }

    UICollectionViewCell *cell = [_collectionV cellForItemAtIndexPath:_selectIndexPath];
    if (cell) {
        UILabel *label = [cell.contentView viewWithTag:100];
        label.textColor = _themeColor;
        CGRect cellRect = [cell.contentView convertRect:cell.contentView.frame toView:self];
        [UIView animateWithDuration:0.2 animations:^{
            CGRect newframe = self->_lineView.frame;
            newframe.size.width = DCWidth(cell.contentView);
            newframe.origin.x = cellRect.origin.x + self->_collectionV.contentOffset.x;
            self->_lineView.frame = newframe;
        }];
    }

    _lastSelectIndexPath = _selectIndexPath;

    if (self.titleArray.count > _selectIndexPath.item) {
        _currentTitle = _titleArray[_selectIndexPath.item];
        _currentIndex = _selectIndexPath.item;
    }
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _titleArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"segementCell" forIndexPath:indexPath];
    UILabel *label = [cell.contentView viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, DCHeight(collectionView))];
        label.tag = 100;
        label.font = DCSegemtFont;
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    label.textColor = _selectIndexPath == indexPath ? _themeColor : [UIColor darkGrayColor];
    CGRect newframe = label.frame;
    newframe.size.width = [_widthArray[indexPath.item] floatValue];
    label.frame = newframe;
    label.text = _titleArray[indexPath.row];
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([_widthArray[indexPath.item] floatValue], DCHeight(collectionView));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemToIndex:indexPath.row];
    if (collectionView.scrollEnabled && self.segementSelectBlock) {
        _segementSelectBlock(indexPath.item, _titleArray[indexPath.item]);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_selectIndexPath) [self resetChangeViews];
}

- (CGSize)intrinsicContentSize
{
    return self.frame.size;
}

@end
