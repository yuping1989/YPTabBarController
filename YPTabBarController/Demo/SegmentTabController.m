//
//  SegmentTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 16/5/23.
//  Copyright © 2016年 YPTabBarController. All rights reserved.
//

#import "SegmentTabController.h"
#import "ViewController.h"

@interface SegmentTabController ()

@end

@implementation SegmentTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewControllers];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self setTabBarFrame:CGRectMake(30, 27, screenSize.width - 60, 30)
        contentViewFrame:CGRectMake(0, 64, screenSize.width, screenSize.height - 64 - 50)];
    
    self.tabBar.itemTitleColor = [UIColor redColor];
    self.tabBar.itemTitleSelectedColor = [UIColor whiteColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:15];
    self.tabBar.itemSelectedBgColor = [UIColor blueColor];
    self.tabBar.layer.cornerRadius = 5;
    self.tabBar.layer.borderWidth = 1;
    self.tabBar.layer.borderColor = [UIColor blueColor].CGColor;
    [self.tabBar setItemSeparatorColor:[UIColor blueColor] width:1 marginTop:0 marginBottom:0];
    
    UIViewController *controller1 = self.viewControllers[0];
    UIViewController *controller2 = self.viewControllers[1];
    UIViewController *controller3 = self.viewControllers[2];
    controller1.yp_tabItem.badge = 8;
    controller2.yp_tabItem.badge = 88;
    controller3.yp_tabItem.badgeStyle = YPTabItemBadgeStyleDot;
    
    self.tabBar.badgeTitleFont = [UIFont systemFontOfSize:10];
    [self.tabBar setNumberBadgeMarginTop:2
                       centerMarginRight:25
                     titleHorizonalSpace:10
                      titleVerticalSpace:4];
    
    [self.tabBar setDotBadgeMarginTop:5
                    centerMarginRight:15
                           sideLength:8];
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

    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, nil];
}

@end
