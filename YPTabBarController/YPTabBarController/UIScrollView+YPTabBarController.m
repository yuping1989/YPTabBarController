//
//  UIScrollView+YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/11/15.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "UIScrollView+YPTabBarController.h"
#import <objc/runtime.h>

@implementation UIScrollView (YPTabBarController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setContentSize:);
        SEL swizzledSelector = @selector(yp_setContentSize:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)yp_setContentSize:(CGSize)contentSize {
    if (contentSize.height < self.minContentSizeHeight) {
        contentSize = CGSizeMake(contentSize.width, self.minContentSizeHeight);
    }
    [self yp_setContentSize:contentSize];
}

- (CGFloat)minContentSizeHeight {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setMinContentSizeHeight:(CGFloat)minContentSizeHeight {
    objc_setAssociatedObject(self, @selector(minContentSizeHeight), @(minContentSizeHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
