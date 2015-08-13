//
//  YPTabBar.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YPTabBar;
@protocol YPTabBarDelegate <NSObject>
@optional
- (BOOL)yp_tabBar:(YPTabBar *)tabBar willSelectItemAtIndex:(NSInteger)index;
- (void)yp_tabBar:(YPTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;
@end

@interface YPTabBar : UIView
@property (nonatomic, strong) UIScrollView *scrollView; // 用于tabBar可滑动时
@property (nonatomic, strong) UIImageView *itemSelectedBgImageView;

@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, assign) NSInteger selectedItemIndex;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL itemSelectedBgSwitchAnimated;  // tabItem选中切换时，是否显示动画
@property (nonatomic, assign) BOOL itemSelectedBgScrollFollowContent;  // tabItem的选中背景是否随contentView滑动而移动

@property (nonatomic, assign) id<YPTabBarDelegate> delegate;

/**
 *  设置tabItem的选中背景可用
 *
 *  @param y        选中背景的Y坐标
 *  @param height   选中背景的高度
 *  @param animated 背景切换的时候，是否支持动画
 */

- (void)setItemSelectedBgEnabledWithY:(float)y
                               height:(float)height
                       switchAnimated:(BOOL)animated;
/**
 *  将tabItem的image和title设置为居中，并且调整其在竖直方向的位置
 *
 *  @param spacing   image和title的距离
 *  @param marginTop image与顶部的间距
 *  @param imageSize image的size
 */
- (void)setItemImageAndTitleCenterWithSpacing:(int)spacing
                                 marginTop:(float)marginTop
                                 imageSize:(CGSize)imageSize;
/**
 *  设置tabBar可以左右滑动
 *
 *  @param width 每个tabItem的宽度
 */
- (void)setScrollEnabledWithItemWith:(float)width;

@end
