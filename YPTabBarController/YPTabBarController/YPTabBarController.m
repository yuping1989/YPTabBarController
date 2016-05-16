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

@interface YPTabBarController () <UIScrollViewDelegate>
{
    BOOL _didViewAppeared;
    UIScrollView *_scrollView;
}
@property (nonatomic, assign, readwrite) UIViewController *selectedController;
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
        [self awakeFromNib];
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
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat navigationAndStatusBarHeight = 0;
    if (self.navigationController) {
        navigationAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height + 20;
    }
    
    self.tabBar.frame = CGRectMake(0,
                                   screenSize.height - TAB_BAR_HEIGHT - navigationAndStatusBarHeight,
                                   screenSize.width,
                                   TAB_BAR_HEIGHT);
    
    self.contentViewFrame = CGRectMake(0,
                                       0,
                                       screenSize.width,
                                       screenSize.height - TAB_BAR_HEIGHT - navigationAndStatusBarHeight);
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_tabBar];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_didViewAppeared) {
        
        self.tabBar.selectedItemIndex = 0;
        _didViewAppeared = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIViewController *)selectedController {
    if (self.selectedControllerIndex >= 0) {
        return self.viewControllers[self.selectedControllerIndex];
    }
    return nil;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    for (UIViewController *controller in self.viewControllers) {
        [controller removeFromParentViewController];
        [controller.view removeFromSuperview];
        
    }
    _viewControllers = viewControllers;
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:obj];
    }];
    
    NSMutableArray *items = [NSMutableArray array];
    for (UIViewController *controller in _viewControllers) {
        YPTabItem *item = [YPTabItem instance];
        [item setImage:controller.yp_tabItemImage forState:UIControlStateNormal];
        [item setImage:controller.yp_tabItemSelectedImage forState:UIControlStateSelected];
        [item setTitle:controller.yp_tabItemTitle forState:UIControlStateNormal];
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

- (void)setContentScrollEnabled:(BOOL)contentScrollEnabled {
    [self setContentScrollEnabled:contentScrollEnabled switchAnimated:NO];
}

- (void)setContentSwitchAnimated:(BOOL)contentSwitchAnimated {
    [self setContentScrollEnabled:NO switchAnimated:contentSwitchAnimated];
}

- (void)setContentScrollEnabled:(BOOL)contentScrollEnabled switchAnimated:(BOOL)switchAnimated {
    _contentScrollEnabled = contentScrollEnabled;
    _contentSwitchAnimated = switchAnimated;
    self.tabBar.itemSelectedBgScrollFollowContent = contentScrollEnabled;
    if (_contentScrollEnabled) {
        if (_scrollView == nil) {
            _scrollView = [[UIScrollView alloc] initWithFrame:_contentViewFrame];
            _scrollView.pagingEnabled = YES;
            _scrollView.showsHorizontalScrollIndicator = NO;
            _scrollView.showsVerticalScrollIndicator = NO;
            _scrollView.scrollsToTop = NO;
            _scrollView.delegate = self;
        }
        [self.view addSubview:_scrollView];
        _scrollView.contentSize = CGSizeMake(_contentViewFrame.size.width * _viewControllers.count,
                                             _contentViewFrame.size.height);
    }
}

- (void)setSelectedControllerIndex:(NSInteger)selectedControllerIndex {
    UIViewController *oldController = nil;
    if (_selectedControllerIndex >= 0) {
        oldController = _viewControllers[_selectedControllerIndex];
    }
    UIViewController *curController = _viewControllers[selectedControllerIndex];
    BOOL isAppearFirstTime = YES;
    if (_contentScrollEnabled) {
        [oldController viewWillDisappear:NO];
        if (curController.view.superview == nil) {
            curController.view.frame = CGRectMake(selectedControllerIndex * _scrollView.frame.size.width,
                                                  0,
                                                  _scrollView.frame.size.width,
                                                  _scrollView.frame.size.height);
            [_scrollView addSubview:curController.view];
        } else {
            isAppearFirstTime = NO;
            [curController viewWillAppear:NO];
        }
        
        [_scrollView scrollRectToVisible:curController.view.frame animated:_contentSwitchAnimated];
        
    } else {
        if (oldController) {
            [oldController.view removeFromSuperview];
        }
        [self.view insertSubview:curController.view belowSubview:_tabBar];
        if (!CGRectEqualToRect(curController.view.frame, _contentViewFrame)) {
            curController.view.frame = _contentViewFrame;
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
    if (_contentScrollEnabled) {
        [oldController viewDidDisappear:NO];
        if (!isAppearFirstTime) {
            [curController viewDidAppear:NO];
        }
    }
}
- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSInteger)index {
    if (index == _selectedControllerIndex) {
        return;
    }
    self.selectedControllerIndex = index;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.tabBar.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"offset--->%f", scrollView.contentOffset.x);
    if (!_tabBar.itemSelectedBgScrollFollowContent) {
        return;
    }
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat frameWidth = scrollView.frame.size.width;
    if (offsetX < 0) {
        return;
    }
    
    if (offsetX > scrollView.contentSize.width - frameWidth) {
        return;
    }
    
    
    NSInteger leftIndex = offsetX / frameWidth;
    NSInteger rightIndex = leftIndex + 1;
    NSLog(@"left index--->%d, right index---%d", leftIndex, rightIndex);
    YPTabItem *leftItem = self.tabBar.items[leftIndex];
    YPTabItem *rightItem;
    if (rightIndex < self.tabBar.items.count) {
        rightItem = self.tabBar.items[rightIndex];
    }
    
    CGRect frame = _tabBar.itemSelectedBgImageView.frame;
    frame.origin.x = ceilf((offsetX / frameWidth) * self.tabBar.selectedItem.frame.size.width) + _tabBar.itemSelectedBgInsets.left;
    _tabBar.itemSelectedBgImageView.frame = frame;
    
    
    // 计算右边按钮偏移量
    CGFloat rightScale = offsetX / frameWidth;
    // 只想要 0~1
    rightScale = rightScale - leftIndex;
    CGFloat leftScale = 1 - rightScale;

    NSLog(@"leftScale--->%f  rightScale--->%f", leftScale, rightScale);
    
//    CGFloat normalFontSize = self.tabBar.itemTitleFont.pointSize;
//    CGFloat fontSizeDiff = self.tabBar.itemTitleSelectedFont.pointSize - normalFontSize;
//    leftItem.titleLabel.font = [leftItem.titleLabel.font fontWithSize:leftScale * fontSizeDiff + normalFontSize];
//    rightItem.titleLabel.font = [rightItem.titleLabel.font fontWithSize:rightScale * fontSizeDiff + normalFontSize];
    
    
    CGFloat normalRed, normalGreen, normalBlue;
    CGFloat selectedRed, selectedGreen, selectedBlue;
    [self.tabBar.itemTitleColor getRed:&normalRed green:&normalGreen blue:&normalBlue alpha:nil];
    [self.tabBar.itemTitleSelectedColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:nil];
    
    CGFloat redDiff = selectedRed - normalRed;
    CGFloat greenDiff = selectedGreen - normalGreen;
    CGFloat blueDiff = selectedBlue - normalBlue;
    
    leftItem.titleLabel.textColor = [UIColor colorWithRed:leftScale * redDiff + normalRed
                                                    green:leftScale * greenDiff + normalRed
                                                     blue:leftScale * blueDiff + normalRed
                                                    alpha:1];
    rightItem.titleLabel.textColor = [UIColor colorWithRed:rightScale * redDiff + normalRed
                                                     green:rightScale * greenDiff + normalRed
                                                      blue:rightScale * blueDiff + normalRed
                                                     alpha:1];
//    [leftItem setTitleColor:[UIColor colorWithRed:leftScale * redDiff + normalRed
//                                            green:leftScale * greenDiff + normalRed
//                                             blue:leftScale * blueDiff + normalRed
//                                            alpha:1]
//                   forState:UIControlStateNormal];
//    [rightItem setTitleColor:[UIColor colorWithRed:rightScale * redDiff + normalRed
//                                             green:rightScale * greenDiff + normalRed
//                                              blue:rightScale * blueDiff + normalRed
//                                             alpha:1]
//                    forState:UIControlStateNormal];
}
@end

@implementation UIViewController (YPTabBarController)

- (NSString *)yp_tabItemTitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYp_tabItemTitle:(NSString *)yp_tabItemTitle {
    objc_setAssociatedObject(self, @selector(yp_tabItemTitle), yp_tabItemTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
