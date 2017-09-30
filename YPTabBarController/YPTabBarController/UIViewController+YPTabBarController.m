//
//  UIViewController+YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 2017/9/19.
//  Copyright © 2017年 YPTabBarController. All rights reserved.
//

#import "UIViewController+YPTabBarController.h"
#import <objc/runtime.h>
#import "YPTabItem.h"
#import "YPTabBarController.h"

#pragma mark - UIViewController (YPTabBarController)

@implementation UIViewController (YPTabBarController)

- (NSString *)yp_tabItemTitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemTitle:(NSString *)yp_tabItemTitle {
    self.yp_tabItem.title = yp_tabItemTitle;
    objc_setAssociatedObject(self, @selector(yp_tabItemTitle), yp_tabItemTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)yp_tabItemImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemImage:(UIImage *)yp_tabItemImage {
    self.yp_tabItem.image = yp_tabItemImage;
    objc_setAssociatedObject(self, @selector(yp_tabItemImage), yp_tabItemImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)yp_tabItemSelectedImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemSelectedImage:(UIImage *)yp_tabItemSelectedImage {
    self.yp_tabItem.selectedImage = yp_tabItemSelectedImage;
    objc_setAssociatedObject(self, @selector(yp_tabItemSelectedImage), yp_tabItemSelectedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YPTabItem *)yp_tabItem {
    YPTabBar *tabBar = self.yp_tabBarController.tabBar;
    if (!tabBar) {
        return nil;
    }
    if (![self.yp_tabBarController.viewControllers containsObject:self]) {
        return nil;
    }
    
    NSUInteger index = [self.yp_tabBarController.viewControllers indexOfObject:self];
    return tabBar.items[index];
}

- (YPTabBarController *)yp_tabBarController {
    if ([self.parentViewController isKindOfClass:[YPTabBarController class]]) {
        return (YPTabBarController *)self.parentViewController;
    }
    return nil;
}

- (void)yp_tabItemDidSelected:(BOOL)isFirstTime {}

- (void)tabItemDidSelected {}

- (void)yp_tabItemDidDeselected {}

- (void)tabItemDidDeselected {}

- (UIView *)yp_displayView {
    return self.view;
}

@end
