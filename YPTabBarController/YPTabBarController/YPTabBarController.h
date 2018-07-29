//
//  YPTabBarController.h
//  YPTabBarController
//
//  Created by 喻平 on 2018/7/28.
//  Copyright © 2018年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPTabBar.h"
#import "YPTabContentView.h"

@interface YPTabBarController : UIViewController <YPTabContentViewDelegate>

@property (nonatomic, strong, readonly) YPTabBar *tabBar;

@property (nonatomic, strong, readonly) YPTabContentView *tabContentView;

@property (nonatomic, copy) NSArray <UIViewController *> *viewControllers;

/**
 *  设置tabBar和contentView的frame，
 *  默认是tabBar在底部，contentView填充其余空间
 *  如果设置了headerView，此方法不生效
 */
- (void)setTabBarFrame:(CGRect)tabBarFrame contentViewFrame:(CGRect)contentViewFrame;

@end
