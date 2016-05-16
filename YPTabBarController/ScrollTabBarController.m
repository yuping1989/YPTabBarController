//
//  ScrollTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 16/5/13.
//  Copyright © 2016年 YPTabBarController. All rights reserved.
//

#import "ScrollTabBarController.h"
#import "ViewController.h"
@interface ScrollTabBarController ()

@end

@implementation ScrollTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    ViewController *controller1 = [[ViewController alloc] init];
    controller1.yp_tabItemTitle = @"第一";
    
    ViewController *controller2 = [[ViewController alloc] init];
    controller2.yp_tabItemTitle = @"第二";
    
    ViewController *controller3 = [[ViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三";
    
    ViewController *controller4 = [[ViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentViewFrame = CGRectMake(0, 64, screenSize.width, screenSize.height - 64);
    self.tabBar.frame = CGRectMake(0, 20, screenSize.width, 44);

    self.tabBar.itemTitleColor = [UIColor grayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor redColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:16];
//    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:20];
    [self setContentScrollEnabled:YES switchAnimated:YES];
    self.tabBar.itemSelectedBgImageView.backgroundColor = [UIColor redColor];
    [self.tabBar setItemSelectedBgInsets:UIEdgeInsetsMake(40, 25, 0, 25) switchAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
