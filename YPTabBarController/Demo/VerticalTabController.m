//
//  VerticalTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/11/8.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "VerticalTabController.h"
#import "ViewController.h"

@interface VerticalTabController ()

@end

@implementation VerticalTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGFloat bottom = [self.parentViewController isKindOfClass:[UINavigationController class]] ? 0 : 50;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.height == 812) {
        [self setTabBarFrame:CGRectMake(0, 44, screenSize.width, 44)
            contentViewFrame:CGRectMake(0, 88, screenSize.width, screenSize.height - 88 - bottom - 34)];
    } else {
        [self setTabBarFrame:CGRectMake(0, 0, 100, screenSize.height)
            contentViewFrame:CGRectMake(100, 0, screenSize.width - 100, screenSize.height)];
    }
    
    self.tabBar.itemTitleColor = [UIColor lightGrayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor whiteColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:17];
    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:22];
    
    self.tabBar.leadAndTrailSpace = 200;
    
    [self.tabBar setTabItemsVerticalLayout];
    [self.tabBar setItemSeparatorColor:[UIColor lightGrayColor] leading:0 trailing:0];
    
    self.tabBar.indicatorColor = [UIColor redColor];
    
    [self initViewControllers];
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
    controller7.yp_tabItemTitle = @"第七";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, controller5, controller6, controller7, nil];
    
}
@end
