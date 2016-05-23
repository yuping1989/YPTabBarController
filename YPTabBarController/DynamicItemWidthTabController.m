//
//  DynamicItemWidthTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 16/5/20.
//  Copyright © 2016年 YPTabBarController. All rights reserved.
//

#import "DynamicItemWidthTabController.h"
#import "ViewController.h"
@interface DynamicItemWidthTabController ()

@end

@implementation DynamicItemWidthTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewControllers];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentViewFrame = CGRectMake(0, 64, screenSize.width, screenSize.height - 64);
    self.tabBar.frame = CGRectMake(0, 20, screenSize.width, 44);
    
    self.tabBar.itemTitleColor = [UIColor lightGrayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor redColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:18];
    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:22];
    
//    [self.tabBar setScrollEnabledAndItemWidth:90];
    [self.tabBar setScrollEnabledAndItemFitTextWidthWithSpacing:40];
    [self setContentScrollEnabledAndTapSwitchAnimated:NO];
    
    self.tabBar.itemSelectedBgImageView.backgroundColor = [UIColor redColor];
    [self.tabBar setItemSelectedBgInsets:UIEdgeInsetsMake(40, 15, 0, 15) switchAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initViewControllers {
    ViewController *controller1 = [[ViewController alloc] init];
    controller1.yp_tabItemTitle = @"第一个";
    
    ViewController *controller2 = [[ViewController alloc] init];
    controller2.yp_tabItemTitle = @"第二";
    
    ViewController *controller3 = [[ViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三个";
    
    ViewController *controller4 = [[ViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四";
    
    ViewController *controller5 = [[ViewController alloc] init];
    controller5.yp_tabItemTitle = @"第五个";
    
    ViewController *controller6 = [[ViewController alloc] init];
    controller6.yp_tabItemTitle = @"第六";
    
    ViewController *controller7 = [[ViewController alloc] init];
    controller7.yp_tabItemTitle = @"第七个";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, controller5, controller6, controller7, nil];
}
@end
