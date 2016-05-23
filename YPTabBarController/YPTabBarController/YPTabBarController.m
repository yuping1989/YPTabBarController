//
//  YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBarController.h"
#import <objc/runtime.h>

#define TAB_BAR_HEIGHT 50

@interface YPTabBarController () {
    BOOL _didViewAppeared;
}
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL contentScrollEnabled;
@property (nonatomic, assign) BOOL contentSwitchAnimated;
@end

@implementation YPTabBarController
- (instancetype)init {
    self = [super init];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    _selectedControllerIndex = -1;
    self.tabBar = [[YPTabBar alloc] init];
    self.tabBar.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置默认的tabBar frame
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat navigationAndStatusBarHeight = 0;
    if (self.navigationController) {
        navigationAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height + 20;
    }
    self.tabBar.frame = CGRectMake(0,
                                   screenSize.height - TAB_BAR_HEIGHT - navigationAndStatusBarHeight,
                                   screenSize.width,
                                   TAB_BAR_HEIGHT);
    [self.view addSubview:self.tabBar];
    
    // 设置默认的contentViewFrame
    self.contentViewFrame = CGRectMake(0,
                                       0,
                                       screenSize.width,
                                       screenSize.height - TAB_BAR_HEIGHT - navigationAndStatusBarHeight);
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_didViewAppeared) {
        self.tabBar.selectedItemIndex = 0;
        _didViewAppeared = YES;
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *controller in self.viewControllers) {
        [controller removeFromParentViewController];
        [controller.view removeFromSuperview];
        
    }
    _viewControllers = [viewControllers copy];
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:obj];
    }];
    
    NSMutableArray *items = [NSMutableArray array];
    for (UIViewController *controller in _viewControllers) {
        YPTabItem *item = [[YPTabItem alloc] init];
        item.image = controller.yp_tabItemImage;
        item.selectedImage = controller.yp_tabItemSelectedImage;
        item.title = controller.yp_tabItemTitle;
        [items addObject:item];
    }
    self.tabBar.items = items;
    if (_didViewAppeared) {
        _selectedControllerIndex = -1;
        self.tabBar.selectedItemIndex = 0;
    }
}

- (void)setContentViewFrame:(CGRect)contentViewFrame {
    _contentViewFrame = contentViewFrame;
    self.selectedController.view.frame = contentViewFrame;
}

- (void)setContentScrollEnabledAndTapSwitchAnimated:(BOOL)switchAnimated {
    self.contentScrollEnabled = YES;
    self.contentSwitchAnimated = switchAnimated;
    if (_contentScrollEnabled) {
        [self.view addSubview:self.scrollView];
        self.scrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * _viewControllers.count,
                                                 self.contentViewFrame.size.height);
    }
}


- (void)setSelectedControllerIndex:(NSInteger)selectedControllerIndex {
    UIViewController *oldController = nil;
    if (_selectedControllerIndex >= 0) {
        oldController = self.viewControllers[_selectedControllerIndex];
    }
    UIViewController *curController = self.viewControllers[selectedControllerIndex];
    BOOL isAppearFirstTime = YES;
    if (self.contentScrollEnabled) {
        [oldController viewWillDisappear:NO];
        if (curController.view.superview == nil) {
            curController.view.frame = CGRectMake(selectedControllerIndex * self.scrollView.frame.size.width,
                                                  0,
                                                  self.scrollView.frame.size.width,
                                                  self.scrollView.frame.size.height);
            [self.scrollView addSubview:curController.view];
        } else {
            isAppearFirstTime = NO;
            [curController viewWillAppear:NO];
        }
        
        [self.scrollView scrollRectToVisible:curController.view.frame animated:self.contentSwitchAnimated];
    } else {
        if (oldController) {
            [oldController.view removeFromSuperview];
        }
        [self.view insertSubview:curController.view belowSubview:self.tabBar];
        if (!CGRectEqualToRect(curController.view.frame, self.contentViewFrame)) {
            curController.view.frame = self.contentViewFrame;
        }
    }
    
    if (oldController && [oldController.view isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)oldController.view setScrollsToTop:NO];
    }
    if ([curController.view isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)curController.view setScrollsToTop:YES];
    }
    _selectedControllerIndex = selectedControllerIndex;
    [oldController tabItemDidDeselected];
    [curController tabItemDidSelected];
    if (self.contentScrollEnabled) {
        [oldController viewDidDisappear:NO];
        if (!isAppearFirstTime) {
            [curController viewDidAppear:NO];
        }
    }
}

- (UIViewController *)selectedController {
    if (self.selectedControllerIndex >= 0) {
        return self.viewControllers[self.selectedControllerIndex];
    }
    return nil;
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.contentViewFrame];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self.tabBar;
    }
    return _scrollView;
}

#pragma mark - YPTabBarDelegate
- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSInteger)index {
    if (index == self.selectedControllerIndex) {
        return;
    }
    self.selectedControllerIndex = index;
}


@end

@implementation UIViewController (YPTabBarController)

- (NSString *)yp_tabItemTitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemTitle:(NSString *)yp_tabItemTitle {
    objc_setAssociatedObject(self, @selector(yp_tabItemTitle), yp_tabItemTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)yp_tabItemImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemImage:(UIImage *)yp_tabItemImage {
    objc_setAssociatedObject(self, @selector(yp_tabItemImage), yp_tabItemImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)yp_tabItemSelectedImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemSelectedImage:(UIImage *)yp_tabItemSelectedImage {
    objc_setAssociatedObject(self, @selector(yp_tabItemSelectedImage), yp_tabItemSelectedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YPTabItem *)yp_tabItem {
    YPTabBar *tabBar = self.yp_tabBarController.tabBar;
    NSInteger index = [self.yp_tabBarController.viewControllers indexOfObject:self];
    return tabBar.items[index];
}

- (YPTabBarController *)yp_tabBarController {
    return (YPTabBarController *)self.parentViewController;
}

- (void)tabItemDidSelected {
    
}

- (void)tabItemDidDeselected {
    
}
@end
