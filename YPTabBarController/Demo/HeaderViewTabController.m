//
//  HeaderViewTabController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/9/25.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "HeaderViewTabController.h"
#import "TableViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface HeaderViewTabController ()

@end

@implementation HeaderViewTabController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabContentView.interceptRightSlideGuetureInFirstPage = YES;
    
    self.tabBar.itemTitleColor = [UIColor lightGrayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor redColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:17];
    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:22];
    
    self.tabBar.itemFontChangeFollowContentScroll = YES;
    
    self.tabBar.indicatorScrollFollowContent = YES;
    self.tabBar.indicatorColor = [UIColor redColor];
    [self.tabBar setIndicatorInsets:UIEdgeInsetsMake(40, 10, 0, 10) tapSwitchAnimated:NO];
    
    self.yp_tabItem.badgeStyle = YPTabItemBadgeStyleDot;
    
    self.tabContentView.loadViewOfChildContollerWhileAppear = YES;
    
    [self.tabContentView setContentScrollEnabledAndTapSwitchAnimated:NO];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    
    CGFloat bottom = 0;
    if (screenSize.height == 812) {
        bottom += 34;
    }
    if ([self.parentViewController isKindOfClass:[YPTabBarController class]]) {
        bottom += 50;
    }
    
    [self.tabContentView setHeaderView:imageView
                           needStretch:NO
                          headerHeight:250
                          tabBarHeight:44
                     contentViewHeight:screenSize.height - 250 - 44 - bottom
                 tabBarStopOnTopHeight:20];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 20, 50, 40);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self initViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initViewControllers {
    TableViewController *controller1 = [[TableViewController alloc] init];
    controller1.yp_tabItemTitle = @"第一个";
    
    TableViewController *controller2 = [[TableViewController alloc] init];
    controller2.yp_tabItemTitle = @"第二";
    
    TableViewController *controller3 = [[TableViewController alloc] init];
    controller3.yp_tabItemTitle = @"第三个";
    controller3.numberOfRows = 5;
    
    TableViewController *controller4 = [[TableViewController alloc] init];
    controller4.yp_tabItemTitle = @"第四";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
    
}

- (void)tabContentView:(YPTabContentView *)tabConentView didChangedContentOffsetY:(CGFloat)offsetY {
    NSLog(@"offsetY-->%f", offsetY);
}

@end
