//
//  RootViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "ScrollTabBarController.h"
#import "DynamicItemWidthTabController.h"

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
    
    
    self.tabBar.backgroundColor = [UIColor lightGrayColor];
    self.tabBar.badgeBackgroundColor = [UIColor blackColor];
    self.tabBar.badgeTitleFont = [UIFont systemFontOfSize:15];
    
    [self initViewControllers];
    
    UIViewController *controller1 = self.viewControllers[0];
    UIViewController *controller2 = self.viewControllers[1];
    UIViewController *controller3 = self.viewControllers[2];
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

- (void)initViewControllers {
    ScrollTabBarController *controller1 = [[ScrollTabBarController alloc] init];
    controller1.yp_tabItemTitle = @"第一";
    controller1.yp_tabItemImage = [UIImage imageNamed:@"tab_discover_normal"];
    controller1.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_discover_selected"];
    
    DynamicItemWidthTabController *controller2 = [[DynamicItemWidthTabController alloc] init];
    controller2.yp_tabItemTitle = @"第二";
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
