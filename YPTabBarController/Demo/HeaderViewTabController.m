//
//  HeaderViewTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/9/25.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "HeaderViewTabController.h"
#import "TableViewController.h"

@interface HeaderViewTabController ()

@end

@implementation HeaderViewTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewControllers];
    
    self.tabBar.itemTitleColor = [UIColor lightGrayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor redColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:17];
    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:22];
    
    self.tabBar.itemFontChangeFollowContentScroll = YES;
    
    self.tabBar.indicatorScrollFollowContent = YES;
    self.tabBar.indicatorColor = [UIColor redColor];
    [self.tabBar setIndicatorInsets:UIEdgeInsetsMake(40, 10, 0, 10) tapSwitchAnimated:NO];
    
    self.loadViewOfChildContollerWhileAppear = YES;
    
    [self setContentScrollEnabledAndTapSwitchAnimated:NO];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    
    [self setHeaderView:imageView
            needStretch:YES
           headerHeight:250
           tabBarHeight:44
      contentViewHeight:screenSize.height - 250 - 44 - 50
  tabBarStopOnTopHeight:64];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initViewControllers {
    TableViewController *controller1 = [[TableViewController alloc] init];
    controller1.yp_tabItemTitle = @"第一个";
    
    TableViewController *controller2 = [[TableViewController alloc] init];
    controller2.yp_tabItemTitle = @"第二";
    
    TableViewController *controller3 = [[TableViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三个";
    
    TableViewController *controller4 = [[TableViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
}

@end
