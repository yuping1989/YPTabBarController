//
//  UIScrollView+YPTab.h
//  YPTabBarController
//
//  Created by 喻平 on 2017/11/15.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (YPTab)

@property (nonatomic, copy) void(^yp_didScrollHandler)(UIScrollView *scrollView);

@end
