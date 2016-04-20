//
//  YPTabBar.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPTabItem.h"
@class YPTabBar;
@protocol YPTabBarDelegate <NSObject>
@optional
- (BOOL)yp_tabBar:(YPTabBar *)tabBar willSelectItemAtIndex:(NSInteger)index;
- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSInteger)index;
@end

@interface YPTabBar : UIView
/**
 *  item的选中背景
 */
@property (nonatomic, strong, readonly) UIImageView *itemSelectedBgImageView;

@property (nonatomic, strong) UIColor *itemTitleColor; // 标题颜色
@property (nonatomic, strong) UIColor *itemSelectedTitleColor; // 标题选中时的颜色
@property (nonatomic, strong) UIFont *itemTitleFont; // 标题字体
@property (nonatomic, strong) UIFont *itemSelectedTitleFont; // 标题选中时的字体

@property (nonatomic, strong) UIColor *badgeBackgroundColor; // Badge背景颜色
@property (nonatomic, strong) UIImage *badgeBackgroundImage; // Badge背景图像
@property (nonatomic, strong) UIColor *badgeTitleColor; // Badge标题颜色
@property (nonatomic, strong) UIFont *badgeTitleFont; // Badge标题字体

@property (nonatomic, assign) NSInteger selectedItemIndex;

@property (nonatomic, strong) NSArray<YPTabItem *> *items; // TabItems
@property (nonatomic, assign) BOOL itemSelectedBgSwitchAnimated;  // TabItem选中切换时，是否显示动画
@property (nonatomic, assign) BOOL itemSelectedBgScrollFollowContent;  // TabItem的选中背景是否随contentView滑动而移动
@property (nonatomic, assign) BOOL itemContentHorizontalCenter; // 将Image和Title设置为水平居中

@property (nonatomic, assign) id<YPTabBarDelegate> delegate;

/**
 *  根据titles创建item
 */
- (void)setTitles:(NSArray *)titles;

/**
 *  设置tabItem的选中背景，这个背景可以是一个横条
 *
 *  @param y        选中背景的Y坐标
 *  @param height   选中背景的高度
 *  @param animated 背景切换的时候，是否支持动画
 */
- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets switchAnimated:(BOOL)animated;


/**
 *  将tabItem的image和title设置为居中，并且调整其在竖直方向的位置
 *
 *  @param marginTop                         image与顶部的间距
 *  @param spacing                           image和title的距离
 */
- (void)setItemContentHorizontalCenterWithMarginTop:(float)marginTop
                                            spacing:(float)spacing;
/**
 *  设置tabBar可以左右滑动
 *
 *  @param width 每个tabItem的宽度
 */
- (void)setScrollEnabledWithItemWith:(float)width;

/**
 *  设置Badge的位置
 *
 *  @param marginTop   与TabItem顶部的距离
 *  @param marginRight 与TabItem右侧的距离
 *  @param height      Badge的高度，宽度为自适应
 *  @param badgeStyle  Badge样式，分为数字样式和小圆点样式
 */
- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle;

@end
