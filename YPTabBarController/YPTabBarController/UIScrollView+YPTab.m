//
//  UIScrollView+YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/11/15.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "UIScrollView+YPTab.h"
#import <objc/runtime.h>

static void YPHookMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL noneSel) {
    // 原实例方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    // 替换的实例方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    // 如果没有实现 delegate 方法，则手动动态添加
    if (!originalMethod) {
        Method noneMethod = class_getInstanceMethod(replacedClass, noneSel);
        BOOL didAddNoneMethod = class_addMethod(originalClass, originalSel, method_getImplementation(noneMethod), method_getTypeEncoding(noneMethod));
        if (didAddNoneMethod) {
            NSLog(@"%@ 没有实现 (%@) 方法，手动添加成功！！", NSStringFromClass(originalClass),  NSStringFromSelector(originalSel));
        }
        return;
    }
    // 向实现 delegate 的类中添加新的方法
    BOOL didAddMethod = class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        // 添加成功
        NSLog(@"%@ 实现了 (%@) 方法并成功 Hook 为 --> (%@)", NSStringFromClass(originalClass),  NSStringFromSelector(originalSel), NSStringFromSelector(replacedSel));
        // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        // 实现交换
        method_exchangeImplementations(originalMethod, newMethod);
    } else {
        // 添加失败，则说明已经 hook 过该类的 delegate 方法，防止多次交换。
        NSLog(@"%@ 已替换过，避免多次替换 --> (%@)", NSStringFromClass(originalClass), NSStringFromClass(originalClass));
    }
}

@implementation UIScrollView (YPTab)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSel = @selector(setDelegate:);
        SEL swizzledSel = @selector(yp_setDelegate:);
        
        Method originalMethod = class_getInstanceMethod(self, originalSel);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSel);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)yp_setDelegate:(id<UIScrollViewDelegate>)delegate {
    if (delegate) {
        YPHookMethod([delegate class],
                     @selector(scrollViewDidScroll:),
                     [self class],
                     @selector(yp_scrollViewDidScroll:),
                     @selector(none_scrollViewDidScroll:));
    }
    
    [self yp_setDelegate:delegate];
}

- (void)yp_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.yp_didScrollHandler) {
        scrollView.yp_didScrollHandler(scrollView);
    }
    [self yp_scrollViewDidScroll:scrollView];
}

- (void)none_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.yp_didScrollHandler) {
        scrollView.yp_didScrollHandler(scrollView);
    }
}

- (void)setYp_didScrollHandler:(void (^)(UIScrollView *))yp_didScrollHandler {
    objc_setAssociatedObject(self, @selector(yp_didScrollHandler), yp_didScrollHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIScrollView *))yp_didScrollHandler {
    return objc_getAssociatedObject(self, _cmd);
}

@end
