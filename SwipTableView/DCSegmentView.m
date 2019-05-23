//
//  DCSegmentView.m
//  SwipTableView
//
//  Created by xzm on 2019/5/23.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "DCSegmentView.h"
#import <Masonry.h>

#define KDefaultColor [UIColor colorWithRed:23 / 255.0 green:23 / 255.0 blue:23 / 255.0 alpha:1]
#define KDCSegemtFont [UIFont boldSystemFontOfSize:16]
#define KDCWidth(view)  view.frame.size.width
#define KDCHeight(view) view.frame.size.height

@implementation DCSegmentView
{
    NSMutableArray *_widthArray;
    NSMutableArray *_labelArray;
    UILabel *_lastLabel;
    UIView *_lineView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _widthArray = @[].mutableCopy;
    _labelArray = @[].mutableCopy;
    self.themeColor = [UIColor colorWithRed:37 / 255.0 green:148 / 255.0 blue:1 alpha:1];
    UIView *sepLine = [[UIView alloc]initWithFrame:CGRectMake(0, KDCHeight(self) - 1, KDCWidth(self), 0.5)];
    sepLine.backgroundColor = [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1];
    [self addSubview:sepLine];

    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, KDCHeight(self) - 2, 30, 2)];
    _lineView.backgroundColor = _themeColor;
    [self addSubview:_lineView];
    self.showsHorizontalScrollIndicator = NO;
}

- (void)addSubViews
{
    NSInteger count = self.titleArray.count;
    CGFloat lastRight = 0;
    if (self.layoutType == DCSegmentViewLayoutCenter) {
        CGFloat sum = [[_widthArray valueForKeyPath:@"@sum.floatValue"] floatValue];
        sum += (count - 1) * self.itemSpace;
        lastRight += (KDCWidth(self) - sum) / 2.f;
        lastRight -= self.itemSpace;
    }
    while (count > _labelArray.count) {
        UILabel *label = [UILabel new];
        label.font = KDCSegemtFont;
        label.textAlignment = 1;
        label.textColor = KDefaultColor;
        label.userInteractionEnabled = YES;
        [self addSubview:label];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [label addGestureRecognizer:tap];
        [_labelArray addObject:label];
    }
    for (int i = 0; i < _labelArray.count; i++) {
        UILabel *label = _labelArray[i];
        if (i < count) {
            CGFloat w = [_widthArray[i] floatValue];
            label.text = self.titleArray[i];
            label.frame = CGRectMake(self.itemSpace + lastRight, 0, w, KDCHeight(self));
            lastRight = CGRectGetMaxX(label.frame);
            label.hidden = NO;
            if (i == count - 1) {
                self.contentSize = CGSizeMake(lastRight + self.itemSpace, KDCHeight(self));
            }
        } else {
            label.hidden = YES;
        }
    }
}

- (void)setTitleArray:(NSArray *)titleArray
{
    _titleArray = titleArray;
    [_widthArray removeAllObjects];
    for (NSString *str in _titleArray) {
        CGFloat width = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, KDCHeight(self)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: KDCSegemtFont } context:nil].size.width;
        [_widthArray addObject:@(width)];
    }
    [self addSubViews];
    [self selectItemToIndex:0 animated:NO];
}

- (void)setLayoutType:(DCSegmentViewLayoutType)layoutType
{
    _layoutType = layoutType;
    if (_itemSpace == 0) {
        _itemSpace = _layoutType == DCSegmentViewLayoutLeft ? 20 : 50;
    }
}

- (void)tapAction:(UIGestureRecognizer *)ges
{
    UILabel *currentLabel = (UILabel *)ges.view;
    [self selectWithItem:currentLabel animated:YES];
    !_selectBlock ? : _selectBlock(self.currentIndex, self.currentTitle);
}

- (void)selectWithItem:(UILabel *)currentLabel animated:(BOOL)animated
{
    currentLabel.textColor = self.themeColor;
    if (_lastLabel != currentLabel) {
        _lastLabel.textColor = KDefaultColor;
        _lastLabel = currentLabel;
    }
    _currentIndex = [_labelArray indexOfObject:currentLabel];
    _currentTitle = currentLabel.text;
    void (^scroll)(void) = ^{
        CGRect newFrame = self->_lineView.frame;
        newFrame.size.width = CGRectGetWidth(currentLabel.frame);
        newFrame.origin.x = CGRectGetMinX(currentLabel.frame);
        self->_lineView.frame = newFrame;
    };
    if (animated) {
        [UIView animateWithDuration:0.2 animations:scroll];
    } else {
        scroll();
    }
}

- (void)selectItemToIndex:(NSInteger)index animated:(BOOL)animated
{
    [self selectWithItem:_labelArray[index] animated:animated];
    !_selectBlock ? : _selectBlock(self.currentIndex, self.currentTitle);
}

- (CGSize)intrinsicContentSize
{
    return self.frame.size;
}

@end
