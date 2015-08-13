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
    // Do any additional setup after loading the view, typically from a nib.
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.text = self.yp_tabItemTitle;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
//    [self.yp_tabItem addDoubleTapTarget:self action:@selector(doubleClicked)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doubleClicked {
    NSLog(@"doubleClicked");
}
@end
