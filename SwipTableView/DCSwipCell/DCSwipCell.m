//
//  DCSwipCell.m
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "DCSwipCell.h"
#import <Masonry.h>
#import <ReactiveObjC.h>
#import <objc/runtime.h>

@interface  NSObject (DCSwip)

@end

@implementation NSObject (DCSwip)

- (void)scrollViewDidScroll:(UIScrollView *)sc{}

@end


@interface UICollectionViewCell (DCSwip)

@property (nonatomic,strong) UIScrollView * dc_swipScrollView;

@end

@implementation UICollectionViewCell (DCSwip)

- (UIScrollView *)dc_swipScrollView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDc_swipScrollView:(UIScrollView *)dc_swipScrollView
{
    objc_setAssociatedObject(self, @selector(dc_swipScrollView),dc_swipScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@interface UIScrollView (DCSwip)

@property (nonatomic, assign) BOOL dc_swipFlag;

@end

@implementation UIScrollView (DCSwip)

- (BOOL)dc_swipFlag
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDc_swipFlag:(BOOL)dc_swipFlag
{
    objc_setAssociatedObject(self, @selector(dc_swipFlag), @(dc_swipFlag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    UIView *otherView = otherGestureRecognizer.view;
    if ([view isKindOfClass:[UIScrollView class]] && [otherView isKindOfClass:[UIScrollView class]]) {
        return [(UIScrollView *)view dc_swipFlag] &&  [(UIScrollView *)otherView dc_swipFlag];
    }
    return NO;
}

@end


#define DCScreenWidth  [UIScreen mainScreen].bounds.size.width
#define DCScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DCSwipCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic,   weak) UITableView *tableView;
@property (nonatomic,   weak) UIScrollView *currentInnerScrollView;
@property (nonatomic,   weak) id<DCSwipCellDataSource> dataSource;
@property (nonatomic,   weak) UINavigationController *nav;

@end

@implementation DCSwipCell

+ (instancetype)cellWithTableView:(UITableView *)tableView dataSource:(id<DCSwipCellDataSource>)dataSource
{
    DCSwipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCSwipCell"];
    if (!cell) {
        cell = [[DCSwipCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCSwipCell"];
        cell.exclusiveTouch = YES;
        cell.selectionStyle = 0;
        cell.dataSource = dataSource;
        cell.tableView = tableView;
        [cell initUI];
    }
    return cell;
}

- (void)initUI
{
    //顶部segement
    _segment = [[DCSegmentView alloc]initWithFrame:CGRectMake(0, 0, DCScreenWidth, 44)];
    _segment.layoutType = DCSegmentViewLayoutLeft;
    _segment.titleArray = [self.dataSource swipCellTopTitles];
    @weakify(self)
    _segment.selectBlock = ^(NSInteger index, NSString *title) {
        @strongify(self)
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition: UICollectionViewScrollPositionNone animated: NO];
    };
    [self.contentView addSubview:_segment];
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
    }];
    //下面collectionView
    [self registerClasses];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(self.innerHeight);
        make.bottom.mas_equalTo(0).priorityMedium();
    }];
    [self catchMethodWithScrollView:self.tableView];
}

#pragma mark - Privite
- (void)registerClasses
{
    [[self.dataSource swipCellRegisterClasses] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.collectionView registerClass:[NSClassFromString(obj) class] forCellWithReuseIdentifier:obj];
    }];
}

- (void)catchMethodWithScrollView:(UIScrollView *)scrollView
{
    if (scrollView.dc_swipFlag) return;
    @weakify(self)
    [[(NSObject *)scrollView.delegate rac_signalForSelector:@selector(scrollViewDidScroll:)] subscribeNext:^(RACTuple *_Nullable x) {
        @strongify(self)
        RACTupleUnpack(UIScrollView * sc) = x;
        [self configScroll:sc];
    }];
    scrollView.dc_swipFlag = YES;
}

- (void)configScroll:(UIScrollView *)sc
{
    //顶部距离
    CGFloat top = [self convertRect:self.bounds toView:self.tableView].origin.y;
    CGFloat start = [self getContentOffYStart]; //获取congtentoffY坐标的起始点
    //设置临界点
    top = top + start;
    //外层tableView偏移量
    CGFloat outOffsetY = self.tableView.contentOffset.y;
    //内层tableView偏移量
    CGFloat innerOffsetY = self.currentInnerScrollView.contentOffset.y;

    if (sc == self.tableView) { //外层主tableView
        //（当外层已滑动到临界点 || 内层不在顶部） ，则固定外层offset
        if (outOffsetY >= top || innerOffsetY > 0) {
            [sc setContentOffset:CGPointMake(0, top)];
            sc.showsVerticalScrollIndicator = NO;
        } else {
            sc.showsVerticalScrollIndicator = YES;
        }
    } else { //内层子scrollView
        //（当内层已滑动到顶部 || 外层小于临界点） ，则固定内层offset
        if (innerOffsetY < 0 || outOffsetY < top) {
            [sc setContentOffset:CGPointZero];
            sc.showsVerticalScrollIndicator = NO;
        } else {
            sc.showsVerticalScrollIndicator = YES;
        }
    }
}

- (CGFloat)getContentOffYStart
{
    if (@available(iOS 11.0, *)) {
        if ((self.tableView.contentInsetAdjustmentBehavior == UIScrollViewContentInsetAdjustmentNever)) {
            return 0;
        } else {
            UIApplication *app = [UIApplication sharedApplication];
            UINavigationController *nav = self.nav;
            CGFloat sH = app.statusBarHidden ? 0 : app.statusBarFrame.size.height;
            if (!nav || nav.navigationBarHidden) { //无导航 或 导航栏已隐藏，则忽略导航
                return -sH;
            } else if (nav.navigationBar.translucent == NO) {
                return 0;
            }
            return -sH - 44;
        }
    } else {
        return 0;
    }
}

- (CGFloat)innerHeight
{
    CGFloat h = DCScreenHeight - self.segment.frame.size.height;
    if (!self.nav.navigationBarHidden) {
        h -= 44;
    }
    if (![UIApplication sharedApplication].statusBarHidden) {
        h -= [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return h;
}

#pragma mark - Publish
- (void)reloadData
{
    self.segment.titleArray = [self.dataSource swipCellTopTitles];
    [self registerClasses];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _segment.titleArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.dataSource swipCellCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sc = (UIScrollView *)view;
            [self catchMethodWithScrollView:sc];
            cell.dc_swipScrollView = sc;
            break;
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(DCScreenWidth, self.innerHeight);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger index = (*targetContentOffset).x/DCScreenWidth;
    [self.segment setSelectedIndex:index offsetLine:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.segment changeColunmColorByScrollView:scrollView];
}

#pragma mark - Lazzy
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
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UINavigationController *)nav
{
    if (!_nav) {
        UIResponder *next = [self nextResponder];
        do {
            if ([next isKindOfClass:[UINavigationController class]]) {
                _nav = (UINavigationController *)next;
                next = nil;
            } else {
                next = [next nextResponder];
            }
        } while (next != nil);
    }
    return _nav;
}

- (UIScrollView *)currentInnerScrollView
{
    UICollectionViewCell *cell = [self.collectionView visibleCells].firstObject;
    return cell.dc_swipScrollView;
}

@end
