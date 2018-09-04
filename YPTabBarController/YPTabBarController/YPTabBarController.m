//
//  YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 2018/7/28.
//  Copyright © 2018年 YPTabBarController. All rights reserved.
//

#import "YPTabBarController.h"

@interface YPTabBarController ()

@property (nonatomic, strong) YPTabContentView *tabContentView;

@end

@implementation YPTabBarController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _tabContentView = [[YPTabContentView alloc] init];
    _tabContentView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tabContentView];
    [self.view addSubview:self.tabBar];
}

- (void)setTabBarFrame:(CGRect)tabBarFrame contentViewFrame:(CGRect)contentViewFrame {
    if (self.tabContentView.headerView) {
        return;
    }
    self.tabBar.frame = tabBarFrame;
    self.tabContentView.frame = contentViewFrame;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    self.tabContentView.viewControllers = viewControllers;
}

- (NSArray<UIViewController *> *)viewControllers {
    return self.tabContentView.viewControllers;
}

- (YPTabBar *)tabBar {
    return self.tabContentView.tabBar;
}

@end
