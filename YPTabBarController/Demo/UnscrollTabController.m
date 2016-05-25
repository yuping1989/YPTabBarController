//
//  UnscrollTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 16/5/25.
//  Copyright © 2016年 YPTabBarController. All rights reserved.
//

#import "UnscrollTabController.h"
#import "ViewController.h"

@interface UnscrollTabController ()

@end

@implementation UnscrollTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewControllers];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentViewFrame = CGRectMake(0, 64, screenSize.width, screenSize.height - 64 - 50);
    self.tabBar.frame = CGRectMake(0, 20, screenSize.width, 44);
    
    self.tabBar.itemTitleColor = [UIColor lightGrayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor redColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:18];
    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:22];
    
//    [self.tabBar setScrollEnabledAndItemWidth:80];
    [self setContentScrollEnabledAndTapSwitchAnimated:YES];
    self.tabBar.itemFontChangeFollowContentScroll = YES;
    self.tabBar.itemSelectedBgScrollFollowContent = YES;
    
    
    
    self.tabBar.itemSelectedBgColor = [UIColor redColor];
    [self.tabBar setItemSelectedBgInsets:UIEdgeInsetsMake(40, 20, 0, 20) tapSwitchAnimated:YES];
    
    
    [self.yp_tabItem setDoubleTapHandler:^{
        NSLog(@"双击效果");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initViewControllers {
    ViewController *controller1 = [[ViewController alloc] init];
    controller1.yp_tabItemTitle = @"第一";
    
    ViewController *controller2 = [[ViewController alloc] init];
    controller2.yp_tabItemTitle = @"第二";
    
    ViewController *controller3 = [[ViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三";
    
    ViewController *controller4 = [[ViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
}

@end
