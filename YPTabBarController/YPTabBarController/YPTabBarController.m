//
//  YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBarController.h"
#import <objc/runtime.h>
#define kYPTabItemTitle @"kYPTabItemTitle"
#define kYPTabItemImage @"kYPTabItemImage"
#define kYPTabItemSelectedImage @"kYPTabItemSelectedImage"
@interface YPTabBarController () <UIScrollViewDelegate>
{
    BOOL _didViewAppeared;
    UIScrollView *_scrollView;
}
@end

@implementation YPTabBarController
- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedIndex = -1;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBar = [[YPTabBar alloc] init];
    _tabBar.delegate = self;
    [self.view addSubview:_tabBar];
    
    NSMutableArray *items = [NSMutableArray array];
    for (UIViewController *controller in _viewControllers) {
        YPTabItem *item = [YPTabItem instance];
        [item setImage:controller.yp_tabItemImage forState:UIControlStateNormal];
        [item setImage:controller.yp_tabItemSelectedImage forState:UIControlStateSelected];
        [item setTitle:controller.yp_tabItemTitle forState:UIControlStateNormal];
        [items addObject:item];
    }
    _tabBar.items = items;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_didViewAppeared) {
        
        _tabBar.selectedItemIndex = 0;
        _didViewAppeared = YES;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setViewControllers:(NSMutableArray *)viewControllers
{
    _viewControllers = viewControllers;
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:obj];
    }];
}

- (void)setContentScrollEnabled:(BOOL)contentScrollEnabled {
    [self setcontentScrollEnabled:contentScrollEnabled animated:YES];
}

- (void)setcontentScrollEnabled:(BOOL)contentScrollEnabled animated:(BOOL)animated {
    _contentScrollEnabled = contentScrollEnabled;
    _contentScrollAnimated = animated;
    if (_contentScrollEnabled) {
        if (_scrollView == nil) {
            _scrollView = [[UIScrollView alloc] initWithFrame:_contentViewFrame];
            _scrollView.pagingEnabled = YES;
            _scrollView.showsHorizontalScrollIndicator = NO;
            _scrollView.showsVerticalScrollIndicator = NO;
            _scrollView.delegate = self;
        }
        [self.view addSubview:_scrollView];
        _scrollView.contentSize = CGSizeMake(_contentViewFrame.size.width * _viewControllers.count, _contentViewFrame.size.height);
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_contentScrollEnabled) {
        UIViewController *curController = _viewControllers[selectedIndex];
        if (curController.view.superview == nil) {
            curController.view.frame = CGRectMake(selectedIndex * _scrollView.frame.size.width,
                                                  0,
                                                  _scrollView.frame.size.width,
                                                  _scrollView.frame.size.height);
            [_scrollView addSubview:curController.view];
        }
        [_scrollView scrollRectToVisible:curController.view.frame animated:_contentScrollAnimated];
    } else {
        if (_selectedIndex >= 0) {
            UIViewController *oldController = _viewControllers[_selectedIndex];
            [oldController.view removeFromSuperview];
        }
        UIViewController *curController = _viewControllers[selectedIndex];
        [self.view addSubview:curController.view];
        if (!CGRectEqualToRect(curController.view.frame, _contentViewFrame)) {
            curController.view.frame = _contentViewFrame;
        }
    }
    _selectedIndex = selectedIndex;
}
- (void)yp_tabBar:(YPTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"index-->%ld selected-->%ld", index, _selectedIndex);
    if (index == _selectedIndex) {
        NSLog(@"equal");
        return;
    }
    self.selectedIndex = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.tabBar.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!_tabBar.itemSelectedBgScrollFollowContent) {
        return;
    }
    NSLog(@"x--->%f", scrollView.contentOffset.x);
    if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.width - scrollView.frame.size.width) {
        CGRect frame = _tabBar.itemSelectedBgImageView.frame;
        YPTabItem *item = _tabBar.items[_tabBar.selectedItemIndex];
        frame.origin.x = ceilf((scrollView.contentOffset.x / scrollView.frame.size.width) * item.frame.size.width);
        _tabBar.itemSelectedBgImageView.frame = frame;
    }
}
@end

@implementation UIViewController (YPTabBarController)
- (NSString *)yp_tabItemTitle {
    return objc_getAssociatedObject(self, kYPTabItemTitle);
}

- (void)setYp_tabItemTitle:(NSString *)yp_tabItemTitle {
    objc_setAssociatedObject(self, kYPTabItemTitle, yp_tabItemTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)yp_tabItemImage {
    return objc_getAssociatedObject(self, kYPTabItemImage);
}

- (void)setYp_tabItemImage:(UIImage *)yp_tabItemImage {
    objc_setAssociatedObject(self, kYPTabItemImage, yp_tabItemImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIImage *)yp_tabItemSelectedImage {
    return objc_getAssociatedObject(self, kYPTabItemSelectedImage);
}

- (void)setYp_tabItemSelectedImage:(UIImage *)yp_tabItemSelectedImage {
    objc_setAssociatedObject(self, kYPTabItemSelectedImage, yp_tabItemSelectedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (YPTabItem *)yp_tabItem
{
    YPTabBar *tabBar = self.yp_tabBarController.tabBar;
    NSInteger index = [self.yp_tabBarController.viewControllers indexOfObject:self];
    return tabBar.items[index];
}
- (YPTabBarController *)yp_tabBarController
{
    return (YPTabBarController *)self.parentViewController;
}

@end
