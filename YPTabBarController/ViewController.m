//
//  ViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "ViewController.h"
#import "YPTabBarController.h"
#import "RootViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
//    [self.view addSubview:button];
//    [self.view addSubview:button1];
    NSLog(@"viewDidLoad--->%@", self.yp_tabItemTitle);
}
- (void)buttonClicked:(UIButton *)button {
//    [self.parentViewController presentViewController:[[ViewController alloc] init] animated:YES completion:nil];
    ViewController *controller1 = [[ViewController alloc] init];
    controller1.yp_tabItemTitle = @"一";
    controller1.yp_tabItemImage = [UIImage imageNamed:@"tab_discover_normal"];
    controller1.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_discover_selected"];
    
    ViewController *controller2 = [[ViewController alloc] init];
    controller2.yp_tabItemTitle = @"二";
    controller2.yp_tabItemImage = [UIImage imageNamed:@"tab_message_normal"];
    controller2.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_message_selected"];
    
    ViewController *controller3 = [[ViewController alloc] init];
    controller3.yp_tabItemTitle = @"三";
    controller3.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    controller3.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    
    ViewController *controller4 = [[ViewController alloc] init];
    controller4.yp_tabItemTitle = @"四";
    controller4.yp_tabItemImage = [UIImage imageNamed:@"tab_me_normal"];
    controller4.yp_tabItemSelectedImage = [UIImage imageNamed:@"tab_me_selected"];
    NSLog(@"RootViewController");
    RootViewController *tabBarController = (RootViewController *)self.parentViewController;
    if (tabBarController) {
        NSLog(@"RootViewController");
    }
    tabBarController.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
}
- (void)closeButtonClicked:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear--->%@", self.yp_tabItemTitle);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear--->%@", self.yp_tabItemTitle);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear--->%@", self.yp_tabItemTitle);
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear--->%@", self.yp_tabItemTitle);
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

- (IBAction)switchValueChanged:(UISwitch *)mSwitch {
    RootViewController *rootController = (RootViewController *)self.parentViewController;
    switch (mSwitch.tag) {
        case 1:
            [rootController setContentScrollEnabled:YES switchAnimated:NO];
            break;
        case 2:
//            [rootController setContentScrollEnabled:<#(BOOL)#> switchAnimated:<#(BOOL)#>];
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        case 5:
            
            break;
            
        default:
            break;
    }
}

@end
