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
    if (screenSize.height == 812) {
        [self setTabBarFrame:CGRectMake(0, 44, screenSize.width, 44)
            contentViewFrame:CGRectMake(0, 88, screenSize.width, screenSize.height - 88 - 50 - 34)];
    } else {
        [self setTabBarFrame:CGRectMake(0, 20, screenSize.width, 44)
            contentViewFrame:CGRectMake(0, 64, screenSize.width, screenSize.height - 64 - 50)];
    }
    
    self.tabBar.backgroundColor = [UIColor grayColor];
    
    self.tabBar.itemTitleColor = [UIColor purpleColor];
    self.tabBar.itemTitleSelectedColor = [UIColor whiteColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:18];
    
    
    self.tabBar.indicatorScrollFollowContent = YES;
    self.tabBar.itemColorChangeFollowContentScroll = YES;
    
    self.tabBar.indicatorColor = [UIColor redColor];
    [self.tabBar setIndicatorWidthFixTextAndMarginTop:40 marginBottom:0 widthAdditional:0 tapSwitchAnimated:YES];
    self.tabBar.indicatorAnimationStyle = YPTabBarIndicatorAnimationStyle1;
    
    [self setContentScrollEnabledAndTapSwitchAnimated:YES];
    
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
    controller2.yp_tabItemTitle = @"第二个";
    
    ViewController *controller3 = [[ViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三";
    
    ViewController *controller4 = [[ViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四个个";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
}

@end
