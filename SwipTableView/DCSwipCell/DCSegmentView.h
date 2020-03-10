//
//  DCSegmentView.h
//  SwipTableView
//
//  Created by xzm on 2019/5/23.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, DCSegmentViewLayoutType) {
    DCSegmentViewLayoutLeft, //居左 ,默认
    DCSegmentViewLayoutCenter //居中
};

/**
 切换视图
 */
@interface DCSegmentView : UIView

@property (nonatomic, strong) NSArray <NSString *> *titleArray;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, assign) CGFloat itemSpace; //间距，居左默认 25  居中默认50
@property (nonatomic, assign) DCSegmentViewLayoutType layoutType;
@property (nonatomic, strong, readonly) NSString *selectedTitle;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;
@property (nonatomic, copy) void (^ selectBlock)(NSInteger index, NSString *title);

- (void)setSelectedIndex:(NSUInteger)selectedIndex offsetLine:(BOOL)offsetLine;

/**
 invoke when scrollView did scroll
 
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 [self.columnHeader changeColunmColorByScrollView:scrollView];
 }
 
 @param scrollView  横向滑动的tableview、collectionview
 */
- (void)changeColunmColorByScrollView:(UIScrollView *)scrollView;

@end
