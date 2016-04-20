//
//  RootViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ViewController *controller1 = [[ViewController alloc] init];
    controller1.yp_tabItemTitle = @"第一";
    controller1.yp_tabItemImage = [UIImage imageNamed:@"tab_discover_normal"];
    controller1.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_discover_selected"];
    
    ViewController *controller2 = [[ViewController alloc] init];
    controller2.yp_tabItemTitle = @"第二二";
    controller2.yp_tabItemImage = [UIImage imageNamed:@"tab_message_normal"];
    controller2.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_message_selected"];
    
    ViewController *controller3 = [[ViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三";
    controller3.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    controller3.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    
    ViewController *controller4 = [[ViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四";
    controller4.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    controller4.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
    
    
    self.tabBar.backgroundColor = [UIColor lightGrayColor];
    
//    self.tabBar.itemTitleNormalColor = [UIColor whiteColor];
//    self.tabBar.itemTitleSelectedColor = [UIColor blackColor];
//    self.tabBar.titleFont = [UIFont systemFontOfSize:10];
//    self.tabBar.itemSelectedBgImageView.backgroundColor = [UIColor blackColor];
    
    
//    [self.tabBar setItemSelectedBgEnabledWithY:45 height:5 switchAnimated:YES];
//    self.tabBar.itemSelectedBgScrollFollowContent = YES;
    [self setcontentScrollEnabled:YES animated:NO];
//    [self.tabBar setScrollEnabledWithItemWith:100];
//    [self.tabBar setItemImageAndTitleMarginTop:5 spacing:5];
    
//    self.tabBar.badgeTitleFont = [UIFont systemFontOfSize:13];
//    self.tabBar.badgeTitleColor = [UIColor blackColor];
    [self.tabBar setBadgeMarginTop:2 marginRight:20 height:16 forStyle:YPTabItemStyleNumber];
//    [self.tabBar setBadgeMarginTop:5 marginRight:30 height:30 forStyle:YPTabItemStyleDot];
//    [self.tabBar setItemContentHorizontalCenterWithMarginTop:20 spacing:5];
//    self.tabBar.itemContentHorizontalCenter = NO;

//    UIViewController *controller1 = self.viewControllers[0];
//    UIViewController *controller2 = self.viewControllers[1];
//    UIViewController *controller3 = self.viewControllers[2];
    controller1.yp_tabItem.badge = 8;
    controller2.yp_tabItem.badge = 88;
    controller3.yp_tabItem.badge = -8;

}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
