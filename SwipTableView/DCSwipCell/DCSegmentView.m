//
//  DCSegmentView.m
//  SwipTableView
//
//  Created by xzm on 2019/5/23.
//  Copyright © 2019 xzm. All rights reserved.
//

#import "DCSegmentView.h"
#import <Masonry.h>

#define KRGB(r, g, b)   [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1]
#define KDCSegemtFont [UIFont fontWithName:@"PingFangSC-Medium" size:16]
#define KDCWidth(view)  view.frame.size.width
#define KDCHeight(view) view.frame.size.height
#define KDCLeft(view)  CGRectGetMinX(view.frame)
#define KDCRight(view) CGRectGetMaxX(view.frame)

static const CGFloat KLineW = 20;

@interface DCScaleLabel : UILabel

@property (nonatomic, assign) CGFloat scale; //缩放比例
@property (nonatomic, assign) CGFloat minScale; //最小缩放比例，默认为0.8，如不需要缩放设置为1即可
@property (nonatomic, strong) UIColor *defaultColor; //默认色
@property (nonatomic, strong) UIColor *lightColor; //高亮色

@end

struct RGBValue {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
};
typedef struct CG_BOXABLE RGBValue RGBValue;

static RGBValue readRGBForUIColor(UIColor *color)
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    Byte b = components[2] * 255;
    Byte g = components[1] * 255;
    Byte r = components[0] * 255;
    RGBValue rgb;
    rgb.blue = b;
    rgb.green = g;
    rgb.red = r;
    return rgb;
}

@implementation DCScaleLabel
{
    RGBValue _defaultRGB;
    RGBValue _lightRGB;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minScale = 0.8;
        self.defaultColor = KRGB(34, 34, 34);
        self.textColor = self.defaultColor;
        self.font = KDCSegemtFont;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setDefaultColor:(UIColor *)defaultColor
{
    _defaultColor = defaultColor;
    _defaultRGB = readRGBForUIColor(defaultColor);
}

- (void)setLightColor:(UIColor *)lightColor
{
    _lightColor = lightColor;
    _lightRGB = readRGBForUIColor(lightColor);
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    // color
    CGFloat r = _defaultRGB.red + (_lightRGB.red - _defaultRGB.red) * scale;
    CGFloat g = _defaultRGB.green + (_lightRGB.green - _defaultRGB.green) * scale;
    CGFloat b = _defaultRGB.blue + (_lightRGB.blue - _defaultRGB.blue) * scale;
    self.textColor = KRGB(r, g, b);
    // frame
    CGFloat realScale = _minScale + (1 - _minScale) * scale;
    self.transform = CGAffineTransformMakeScale(realScale, realScale);
}

@end

@implementation DCSegmentView
{
    NSMutableArray *_widthArray;
    NSMutableArray <DCScaleLabel *>*_labelArray;
    UIScrollView *_scrollView;
    UILabel *_lastLabel;
    UIView *_lineView;
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

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KDCWidth(self), KDCHeight(self) - 1)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    UIView *sepLine = [[UIView alloc]initWithFrame:CGRectMake(0, KDCHeight(self) - 1, KDCWidth(self), 0.5)];
    sepLine.backgroundColor = [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1];
    [self addSubview:sepLine];

    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, KDCHeight(_scrollView) - 3, KLineW, 3)];
    _lineView.layer.cornerRadius = 1.5;
    _lineView.backgroundColor = _themeColor;
    [_scrollView addSubview:_lineView];

    self.layoutType = DCSegmentViewLayoutLeft;
}

- (void)addSubViews
{
    NSInteger count = self.titleArray.count;
    CGFloat lastRight = 0;
    if (self.layoutType == DCSegmentViewLayoutCenter) {
        CGFloat sum = [[_widthArray valueForKeyPath:@"@sum.floatValue"] floatValue];
        sum += (count - 1) * self.itemSpace;
        lastRight += (KDCWidth(_scrollView) - sum) / 2.f;
        lastRight -= self.itemSpace;
    }
    while (count > _labelArray.count) {
        DCScaleLabel *label = [DCScaleLabel new];
        label.lightColor = self.themeColor;
        [_scrollView addSubview:label];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [label addGestureRecognizer:tap];
        [_labelArray addObject:label];
    }
    for (int i = 0; i < _labelArray.count; i++) {
        UILabel *label = _labelArray[i];
        if (i < count) {
            CGFloat w = [_widthArray[i] floatValue];
            label.text = self.titleArray[i];
            label.frame = CGRectMake(self.itemSpace + lastRight, 0, w, KDCHeight(_scrollView));
            lastRight = CGRectGetMaxX(label.frame);
            label.hidden = NO;
            if (i == count - 1) {
                _scrollView.contentSize = CGSizeMake(lastRight + self.itemSpace, KDCHeight(_scrollView));
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
        CGFloat width = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, KDCHeight(_scrollView)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: KDCSegemtFont } context:nil].size.width;
        [_widthArray addObject:@(width)];
    }
    [self addSubViews];
    [self setSelectedIndex:0 offsetLine:YES];
}

- (void)setLayoutType:(DCSegmentViewLayoutType)layoutType
{
    _layoutType = layoutType;
    if (_itemSpace == 0) {
        _itemSpace = _layoutType == DCSegmentViewLayoutLeft ? 20 : 40;
    }
}

- (void)tapAction:(UIGestureRecognizer *)ges
{
    NSInteger index = [_labelArray indexOfObject:(DCScaleLabel *)ges.view];
    [self setSelectedIndex:index offsetLine:NO];
    !_selectBlock ? : _selectBlock(self.selectedIndex, self.selectedTitle);
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex offsetLine:(BOOL)offsetLine
{
    _selectedIndex = selectedIndex;
    if (selectedIndex >= _labelArray.count) return;
    UILabel *selectLabel = _labelArray[selectedIndex];

    if (offsetLine) {
        _lineView.center = CGPointMake(selectLabel.center.x, KDCHeight(self) - 3);
    }

   //滑动到选中label的center，然后减去宽度的一半，这样label就始终在屏幕中心了
    CGFloat scrollOffsetX = selectLabel.center.x - KDCWidth(_scrollView) * 0.5;
    CGFloat maxScrollOffsetX = _scrollView.contentSize.width - KDCWidth(_scrollView);
    scrollOffsetX = MIN(maxScrollOffsetX, scrollOffsetX);
    scrollOffsetX = MAX(scrollOffsetX, 0);
    [_scrollView setContentOffset:CGPointMake(scrollOffsetX, 0) animated:YES];

    for (DCScaleLabel *label in _labelArray) {
        if (label == selectLabel) {
            label.scale = 1;
        } else {
            label.scale = 0;
        }
    }
}

- (void)changeColunmColorByScrollView:(UIScrollView *)scrollView
{
    CGFloat value = scrollView.contentOffset.x / KDCWidth(scrollView);
    if (value < 0 || value > self.titleArray.count - 1) return;

    int leftIndex = scrollView.contentOffset.x / KDCWidth(scrollView);
    int rightIndex = leftIndex + 1;

    CGFloat rightScale = value - leftIndex;
    CGFloat leftScale = 1 - rightScale;

    DCScaleLabel *leftLab = _labelArray[leftIndex];
    leftLab.scale = leftScale;
    DCScaleLabel *rightLab;
    if (rightIndex < _labelArray.count) {
        rightLab = _labelArray[rightIndex];
        rightLab.scale = rightScale;
    }
    
    //处理指示条
    CGFloat ratio = value - leftIndex;
    CGRect frame = _lineView.frame;
    if (ratio <= 0.5) {
        CGFloat totleW = ABS(rightLab.center.x - leftLab.center.x) + KLineW;
        frame.size.width = KLineW + (totleW - KLineW) * (ratio / 0.5);
        frame.origin.x = KDCLeft(leftLab) + (KDCWidth(leftLab) - KLineW)/2.f;
    } else {
        CGFloat totleW = ABS(rightLab.center.x - leftLab.center.x) + KLineW;
        frame.size.width = KLineW + (totleW - KLineW) * ((1 - ratio) / 0.5);
        frame.origin.x = KDCRight(rightLab) - (KDCWidth(rightLab) - KLineW)/2.f - frame.size.width;
    }
    _lineView.frame = frame;
}

- (void)refreshUI
{
    self.titleArray = _titleArray;
}

- (CGSize)intrinsicContentSize
{
    return self.frame.size;
}

@end
