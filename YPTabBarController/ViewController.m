//
//  ViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "ViewController.h"
#import "YPTabBarController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.text = self.yp_tabItemTitle;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
//    [self.yp_tabItem addDoubleTapTarget:self action:@selector(doubleClicked)];
    
//    YPTabBar *tabBar = [[YPTabBar alloc] initWithFrame:CGRectMake(10, 100, 355, 30)];
////    [tabBar setItemSelectedBgEnabledWithY:25 height:5 switchAnimated:NO];
//    tabBar.itemSelectedBgImageView.backgroundColor = [UIColor darkGrayColor];
//    tabBar.backgroundColor = [UIColor lightGrayColor];
//    [tabBar setTitles:@[@"第一", @"第二", @"第三"]];
//    tabBar.selectedItemIndex = 0;
//    
//    YPTabItem *item1 = tabBar.items[0];
//    item1.badge = -1;
//    [self.view addSubview:tabBar];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 50);
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setTitle:@"关闭" forState:UIControlStateNormal];
    button1.frame = CGRectMake(100, 200, 100, 50);
    [button1 addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addSubview:button1];
    
}
- (void)buttonClicked:(UIButton *)button {
    [self.parentViewController presentViewController:[[ViewController alloc] init] animated:YES completion:nil];
}
- (void)closeButtonClicked:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tabItemDidDeselected {
    NSLog(@"Deselected--->%@", self.yp_tabItemTitle);
}

- (void)tabItemDidSelected {
    NSLog(@"Selected--->%@", self.yp_tabItemTitle);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doubleClicked {
    NSLog(@"doubleClicked");
}
@end
