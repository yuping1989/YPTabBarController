//
//  UIScrollView+YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/11/15.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "UIScrollView+YPTab.h"
#import <objc/runtime.h>

@implementation UIScrollView (YPTab)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *methodName = [NSString stringWithFormat:@"%@%@%@%@", @"_", @"notify", @"Did", @"Scroll"];
        SEL originalSel = NSSelectorFromString(methodName);
        SEL swizzledSel = @selector(yp_didScroll);
        
        Method originalMethod = class_getInstanceMethod(self, originalSel);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSel);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)yp_didScroll {
    if (self.yp_didScrollHandler) {
        self.yp_didScrollHandler(self);
    }
    [self yp_didScroll];
}

- (void)setYp_didScrollHandler:(void (^)(UIScrollView *))yp_didScrollHandler {
    objc_setAssociatedObject(self, @selector(yp_didScrollHandler), yp_didScrollHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIScrollView *))yp_didScrollHandler {
    return objc_getAssociatedObject(self, _cmd);
}

@end
