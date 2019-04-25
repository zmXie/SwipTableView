//
//  DCSwipSegment.h
//  SwipTableView
//
//  Created by xzm on 2019/4/25.
//  Copyright © 2019 xzm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCSwipSegment : UIView

@property (nonatomic,strong)NSArray * titleArray;
@property (nonatomic,strong) UIColor * themeColor;
@property (nonatomic,copy,readonly)NSString * currentTitle;
@property (nonatomic,assign,readonly)NSInteger currentIndex;
@property (nonatomic,copy)void(^segementSelectBlock)(NSInteger index,NSString *title);

/**
 选中某一item
 
 @param index 索引
 */
- (void)selectItemToIndex:(NSInteger)index;

/**
 是否可以滑动，如果不可以则contentSize为bound.size,每个item的宽度均分。
 
 @param frame    坐标
 @param scrollEnabled 是否可以滑动
 
 @return DQDSegementView
 */
- (instancetype)initWithFrame:(CGRect)frame scrollEnabled:(BOOL)scrollEnabled;

@end

