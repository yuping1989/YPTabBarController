//
//  WebViewController.m
//  YPTabBarController
//
//  Created by 喻平 on 2019/2/27.
//  Copyright © 2019年 YPTabBarController. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]];
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:[[WKWebViewConfiguration alloc] init]];
    self.wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.wkWebView];
    [self.wkWebView loadRequest:request];
}

- (UIScrollView *)yp_scrollView {
    return self.wkWebView.scrollView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
