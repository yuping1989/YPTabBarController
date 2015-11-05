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

@property (nonatomic, strong) UIColor *itemTitleNormalColor; // 标题颜色
@property (nonatomic, strong) UIColor *itemTitleSelectedColor; // 标题选中时的颜色
@property (nonatomic, strong) UIFont *itemTitleFont; // 标题字体

@property (nonatomic, strong) UIColor *badgeBackgroundColor; // badge颜色
@property (nonatomic, strong) UIImage *badgeBackgroundImage;
@property (nonatomic, strong) UIColor *badgeTitleColor;
@property (nonatomic, strong) UIFont *badgeTitleFont;

@property (nonatomic, assign) NSInteger selectedItemIndex;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) BOOL itemSelectedBgSwitchAnimated;  // tabItem选中切换时，是否显示动画
@property (nonatomic, assign) BOOL itemSelectedBgScrollFollowContent;  // tabItem的选中背景是否随contentView滑动而移动

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
 *  @param spacing   image和title的距离
 *  @param marginTop image与顶部的间距
 *  @param imageSize 考虑到有时候切出来的图大小不一，所以统一指定一个image的size
 */
- (void)setItemImageAndTitleMarginTop:(float)marginTop
                          spacing:(float)spacing;
- (void)setItemImageAndTitleMarginTop:(float)marginTop
                          spacing:(float)spacing
                        imageSize:(CGSize)imageSize;
/**
 *  设置tabBar可以左右滑动
 *
 *  @param width 每个tabItem的宽度
 */
- (void)setScrollEnabledWithItemWith:(float)width;

- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle;

@end
