//
//  RootTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "RootTabController.h"
#import "ViewController.h"
#import "FixedItemWidthTabController.h"
#import "DynamicItemWidthTabController.h"
#import "SegmentTabController.h"
#import "UnscrollTabController.h"

@interface RootTabController ()

@end

@implementation RootTabController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initViewControllers];
    self.tabBar.backgroundColor = [UIColor lightGrayColor];
    
    // 设置数字样式的badge的位置和大小
    [self.tabBar setNumberBadgeMarginTop:2
                       centerMarginRight:20
                     titleHorizonalSpace:8
                      titleVerticalSpace:2];
    // 设置小圆点样式的badge的位置和大小
    [self.tabBar setDotBadgeMarginTop:5
                    centerMarginRight:15
                           sideLength:10];
    
    
    UIViewController *controller1 = self.viewControllers[0];
    UIViewController *controller2 = self.viewControllers[1];
    UIViewController *controller3 = self.viewControllers[2];
    UIViewController *controller4 = self.viewControllers[3];
    controller1.yp_tabItem.badge = 8;
    controller2.yp_tabItem.badge = 88;
    controller3.yp_tabItem.badge = 120;
    controller4.yp_tabItem.badgeStyle = YPTabItemBadgeStyleDot;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initViewControllers {
    
    DynamicItemWidthTabController *controller1 = [[DynamicItemWidthTabController alloc] init];
    controller1.yp_tabItemTitle = @"动态宽度";
    controller1.yp_tabItemImage = [UIImage imageNamed:@"tab_message_normal"];
    controller1.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_message_selected"];
    
    FixedItemWidthTabController *controller2 = [[FixedItemWidthTabController alloc] init];
    controller2.yp_tabItemTitle = @"固定宽度";
    controller2.yp_tabItemImage = [UIImage imageNamed:@"tab_discover_normal"];
    controller2.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_discover_selected"];
    
    UnscrollTabController *controller3 = [[UnscrollTabController alloc] init];
    controller3.yp_tabItemTitle = @"不滚动tab";
    controller3.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    controller3.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    
    SegmentTabController *controller4 = [[SegmentTabController alloc] init];
    controller4.yp_tabItemTitle = @"系统Segment";
    controller4.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    controller4.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    
//    ViewController *controller5 = [[ViewController alloc] init];
//    controller5.yp_tabItemTitle = @"普通";
//    controller5.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
//    controller5.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
//    [self setContentScrollEnabledAndTapSwitchAnimated:NO];
    
    // 生成一个居中显示的YPTabItem对象，即“+”号按钮
    YPTabItem *item = [YPTabItem buttonWithType:UIButtonTypeCustom];
    item.title = @"+";
    item.titleColor = [UIColor yellowColor];
    item.backgroundColor = [UIColor darkGrayColor];
    item.titleFont = [UIFont boldSystemFontOfSize:40];
    
    // 设置其size，如果不设置，则默认为与其他item一样
    item.size = CGSizeMake(80, 60);
    // 高度大于tabBar，所以需要将此属性设置为NO
    self.tabBar.clipsToBounds = NO;
    
    [self.tabBar setSpecialItem:item
             afterItemWithIndex:1
                     tapHandler:^(YPTabItem *item) {
                         NSLog(@"item--->%ld", (long)item.index);
                     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"viewWillAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

@end
