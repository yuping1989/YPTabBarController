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

@interface YPTabBarController : UIViewController <YPTabBarDelegate>
@property (nonatomic, strong) YPTabBar *tabBar;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) CGRect contentViewFrame; //内容视图的Frame
@property (nonatomic, assign) NSInteger selectedControllerIndex; //被选中的ViewController的Index
@property (nonatomic, assign) BOOL contentScrollEnabled; // 内容视图是否支持滑动切换
@property (nonatomic, assign) BOOL contentScrollAnimated; // 点按tabBar切换视图时，是否有切换动画
/**
 *  设置内容视图是否支持滑动切换及动画
 *
 *  @param contentScrollEnabled 内容视图是否支持滑动
 *  @param animated             切换时是否支持动画
 */
- (void)setcontentScrollEnabled:(BOOL)contentScrollEnabled animated:(BOOL)animated;
/**
 *  获取被选中的ViewController
 */
- (UIViewController *)selectedController;
@end

@interface UIViewController (YPTabBarController)

@property (nonatomic, copy) NSString *yp_tabItemTitle; // tabItem的标题
@property (nonatomic, strong) UIImage *yp_tabItemImage; // tabItem的图像
@property (nonatomic, strong) UIImage *yp_tabItemSelectedImage; // tabItem的选中图像
- (YPTabItem *)yp_tabItem;
- (YPTabBarController *)yp_tabBarController;
/**
 *  ViewController对应的Tab被Select后，执行此方法
 */

- (void)tabItemDidSelected;
/**
 *  ViewController对应的Tab被Deselect后，执行此方法
 */
- (void)tabItemDidDeselected;
@end