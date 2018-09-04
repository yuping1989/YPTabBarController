//
//  YPTabBarControllerProtocol.h
//  YPTabBarController
//
//  Created by 喻平 on 2018/9/4.
//  Copyright © 2018年 YPTabBarController. All rights reserved.
//

@protocol YPTabBarControllerProtocol <NSObject>

@property (nonatomic, strong, readonly) YPTabBar *tabBar;

@property (nonatomic, strong, readonly) YPTabContentView *tabContentView;

@property (nonatomic, copy) NSArray <UIViewController *> *viewControllers;

@end
