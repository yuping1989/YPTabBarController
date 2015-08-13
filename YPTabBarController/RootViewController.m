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
        ViewController *controller1 = [[ViewController alloc] init];
        controller1.yp_tabItemTitle = @"第一";
        controller1.yp_tabItemImage = [UIImage imageNamed:@"tab_discover_normal"];
        controller1.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_discover_selected"];
        
        ViewController *controller2 = [[ViewController alloc] init];
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
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.backgroundColor = [UIColor lightGrayColor];
    self.tabBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
    self.tabBar.titleNormalColor = [UIColor whiteColor];
    self.tabBar.titleSelectedColor = [UIColor blackColor];
    self.tabBar.titleFont = [UIFont systemFontOfSize:10];
    self.tabBar.itemSelectedBgImageView.backgroundColor = [UIColor blackColor];
    
    self.contentViewFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50);
//    [self.tabBar setItemSelectedBgEnabledWithY:45 height:5 switchAnimated:YES];
//    self.tabBar.itemSelectedBgScrollFollowContent = YES;
//    [self setcontentScrollEnabled:YES animated:NO];
//    [self.tabBar setScrollEnabledWithItemWith:100];
    [self.tabBar setItemImageAndTitleCenterWithSpacing:5
                                          marginTop:5
                                          imageSize:CGSizeMake(25, 25)];
    
    UIViewController *controller1 = self.viewControllers[0];
    UIViewController *controller2 = self.viewControllers[1];
    UIViewController *controller3 = self.viewControllers[2];
    controller1.yp_tabItem.badge = 8;
    controller2.yp_tabItem.badge = 11;
    controller3.yp_tabItem.badge = 0;
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
