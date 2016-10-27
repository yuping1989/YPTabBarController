//
//  ViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "ViewController.h"
#import "YPTabBarController.h"
#import "RootTabController.h"
#import "AppDelegate.h"
@interface ViewController ()
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.label.text = self.yp_tabItemTitle;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 50);
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

//    [self.view addSubview:button];
    NSLog(@"viewDidLoad--->%@", self.yp_tabItemTitle);
}
- (IBAction)buttonClicked:(UIButton *)button {
//    self.yp_tabBarController.contentViewFrame = CGRectMake(0, 64, 300, 500);
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = self.navigationController;
    [navController pushViewController:[[ViewController alloc] init] animated:YES];
    [navController setNavigationBarHidden:NO animated:YES];
}



//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSLog(@"viewWillAppear--->%@ %@", NSStringFromClass(self.class), self.yp_tabItemTitle);
//}
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"viewDidAppear--->%@ %@", NSStringFromClass(self.class), self.yp_tabItemTitle);
//}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear--->%@ %@", NSStringFromClass(self.class), self.yp_tabItemTitle);
}
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    NSLog(@"viewDidDisappear--->%@ %@", NSStringFromClass(self.class), self.yp_tabItemTitle);
//}
//
//- (void)tabItemDidDeselected {
//    NSLog(@"Deselected--->%@ %@", NSStringFromClass(self.class), self.yp_tabItemTitle);
//}
//
//- (void)tabItemDidSelected {
//    NSLog(@"Selected--->%@ %@", NSStringFromClass(self.class), self.yp_tabItemTitle);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doubleClicked {
    NSLog(@"doubleClicked");
}

@end
