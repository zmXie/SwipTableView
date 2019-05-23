//
//  DCSegmentView.h
//  SwipTableView
//
//  Created by xzm on 2019/5/23.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, DCSegmentViewLayoutType) {
    DCSegmentViewLayoutLeft, //居左
    DCSegmentViewLayoutCenter //居中
};

/**
 切换视图
 */
@interface DCSegmentView : UIScrollView

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, assign) CGFloat itemSpace; //间距，居左默认 20  居中默认50
@property (nonatomic, assign) DCSegmentViewLayoutType layoutType;
@property (nonatomic, strong, readonly) NSString *currentTitle;
@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, copy) void (^ selectBlock)(NSInteger index, NSString *title);

/**
 选中某一item

 @param index 索引
 @param animated 动画
 */
- (void)selectItemToIndex:(NSInteger)index animated:(BOOL)animated;

@end
