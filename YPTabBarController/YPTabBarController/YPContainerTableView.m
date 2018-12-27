//
//  YPContainerTableView.m
//  YPTabBarController
//
//  Created by 喻平 on 2018/12/12.
//  Copyright © 2018年 YPTabBarController. All rights reserved.
//

#import "YPContainerTableView.h"

@implementation YPContainerTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
