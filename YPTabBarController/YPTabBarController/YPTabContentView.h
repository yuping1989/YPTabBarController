//
//  YPTabBarController.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPTabBar.h"
#import "YPTabItem.h"
#import "UIViewController+YPTab.h"

@class YPTabContentView;

@protocol YPTabContentViewDelegate <NSObject>

@optional

/**
 *  是否能切换到指定index
 */
- (BOOL)tabContentView:(YPTabContentView *)tabConentView shouldSelectTabAtIndex:(NSUInteger)index;

/**
 *  将要切换到指定index
 */
- (void)tabContentView:(YPTabContentView *)tabConentView willSelectTabAtIndex:(NSUInteger)index;

/**
 *  已经切换到指定index
 */
- (void)tabContentView:(YPTabContentView *)tabConentView didSelectedTabAtIndex:(NSUInteger)index;

/**
 *  当设置headerView时，内容视图竖向滚动时的y坐标偏移量
 */
- (void)tabContentView:(YPTabContentView *)tabConentView didChangedContentOffsetY:(CGFloat)offsetY;

@end

@interface YPTabContentView : UIView <YPTabBarDelegate>

@property (nonatomic, strong, readonly) YPTabBar *tabBar;

@property (nonatomic, copy) NSArray <UIViewController *> *viewControllers;

@property (nonatomic, weak) id<YPTabContentViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *headerView;

/**
 *  第一次显示时，默认被选中的Tab的Index，在viewWillAppear方法被调用前设置有效
 */
@property (nonatomic, assign) NSUInteger defaultSelectedTabIndex;

/**
 *  设置被选中的Tab的Index，界面会自动切换
 */
@property (nonatomic, assign) NSUInteger selectedTabIndex;

/**
 *  此属性仅在内容视图支持滑动时有效，它控制child view controller调用viewDidLoad方法的时机
 *  1. 值为YES时，拖动内容视图，一旦拖动到该child view controller所在的位置，立即加载其view
 *  2. 值为NO时，拖动内容视图，拖动到该child view controller所在的位置，不会立即展示其view，而是要等到手势结束，scrollView停止滚动后，再加载其view
 *  3. 默认值为NO
 */
@property (nonatomic, assign) BOOL loadViewOfChildContollerWhileAppear;

/**
 *  在此属性仅在内容视图支持滑动时有效，它控制chile view controller未选中时，是否将其从父view上面移除
 *  默认为YES
 */
@property (nonatomic, assign) BOOL removeViewOfChildContollerWhileDeselected;

/**
 *  鉴于有些项目集成了左侧或者右侧侧边栏，当内容视图支持滑动切换时，不能实现在第一页向右滑动和最后一页向左滑动呼出侧边栏的功能，
 *  此2个属性则可以拦截第一页向右滑动和最后一页向左滑动的手势，实现呼出侧边栏的功能
 */
@property (nonatomic, assign) BOOL interceptRightSlideGuetureInFirstPage;
@property (nonatomic, assign) BOOL interceptLeftSlideGuetureInLastPage;

/**
 *  设置HeaderView
 *  @param headerView UIView
 *  @param needStretch 内容视图向下滚动时，headerView是否拉伸
 *  @param headerHeight headerView的默认高度
 *  @param tabBarHeight tabBar的高度
 *  @param contentViewHeight 内容视图的高度
 *  @param tabBarStopOnTopHeight 当内容视图向上滚动时，TabBar停止移动的位置
 */
- (void)setHeaderView:(UIView *)headerView
          needStretch:(BOOL)needStretch
         headerHeight:(CGFloat)headerHeight
         tabBarHeight:(CGFloat)tabBarHeight
    contentViewHeight:(CGFloat)contentViewHeight
tabBarStopOnTopHeight:(CGFloat)tabBarStopOnTopHeight;

/**
 *  设置内容视图支持滑动切换，以及点击item切换时是否有动画
 *
 *  @param animated  点击切换时是否支持动画
 */
- (void)setContentScrollEnabledAndTapSwitchAnimated:(BOOL)animated __deprecated_msg("废弃，用setContentScrollEnabled:tapSwitchAnimated:替换");

/**
 *  设置内容视图支持滑动切换，以及点击item切换时是否有动画
 *
 *  @param enabled   是否支持滑动切换
 *  @param animated  点击切换时是否支持动画
 */
- (void)setContentScrollEnabled:(BOOL)enabled tapSwitchAnimated:(BOOL)animated;

/**
 *  获取被选中的ViewController
 */
- (UIViewController *)selectedController;

@end


