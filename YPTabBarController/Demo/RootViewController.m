//
//  RootViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/11/8.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.dataSource = @[@{@"title" : @"基础样式 + 多层嵌套", @"class" : @"MultilTabController"},
                        @{@"title" : @"可滚动，tabItem宽度适配标题，指示器宽度固定", @"class" : @"DynamicItemWidthTabController"},
                        @{@"title" : @"可滚动，tabItem固定宽度，指示器宽度适配title", @"class" : @"FixedItemWidthTabController"},
                        @{@"title" : @"不可滚动，指示器宽度适配title", @"class" : @"IndicatorFollowTitleTabController"},
                        @{@"title" : @"指示器样式自定义", @"class" : @"CustomIndicatorTabController"},
                        @{@"title" : @"仿系统segment", @"class" : @"SegmentTabController"},
                        @{@"title" : @"可伸缩的HeaderView", @"class" : @"HeaderViewTabController"},
                        @{@"title" : @"竖向tabBar", @"class" : @"VerticalTabController"}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *className = self.dataSource[indexPath.row][@"class"];
    if (className.length == 0) {
        return;
    }
    Class cls = NSClassFromString(className);
    [self.navigationController pushViewController:[[cls alloc] init] animated:YES];
}

@end
