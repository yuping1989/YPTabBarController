//
//  YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBarController.h"
#import "UIViewController+YPTab.h"
#import "UIScrollView+YPTab.h"
#import <objc/runtime.h>

#pragma mark - _YPTabContentScrollView

/**
 *  自定义UIScrollView，在需要时可以拦截其滑动手势
 */

@class _YPTabContentScrollView;

@protocol _YPTabContentScrollViewDelegate <NSObject>

@optional

- (BOOL)scrollView:(_YPTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index;

@end

@interface _YPTabContentScrollView : UIScrollView

@property (nonatomic, weak) id <_YPTabContentScrollViewDelegate> yp_delegate;

@property (nonatomic, assign) BOOL interceptLeftSlideGuetureInLastPage;
@property (nonatomic, assign) BOOL interceptRightSlideGuetureInFirstPage;
@property (nonatomic, assign) CGFloat interceptRightSlideGuetureMaxAllowedDistance;

@end

typedef void (^_YPViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (Private)

@property (nonatomic, assign) BOOL yp_hasBeenDisplayed;

@property (nonatomic, copy) _YPViewControllerWillAppearInjectBlock yp_willAppearInjectBlock;

@end

@implementation UIViewController (Private)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(yp_viewWillAppear:);
        
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

- (void)yp_viewWillAppear:(BOOL)animated {
    [self yp_viewWillAppear:animated];
    
    if (self.yp_willAppearInjectBlock) {
        self.yp_willAppearInjectBlock(self, animated);
    }
}

- (void)setYp_hasBeenDisplayed:(BOOL)yp_hasBeenDisplayed {
    objc_setAssociatedObject(self, @selector(yp_hasBeenDisplayed), @(yp_hasBeenDisplayed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)yp_hasBeenDisplayed {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setYp_willAppearInjectBlock:(_YPViewControllerWillAppearInjectBlock)block {
    objc_setAssociatedObject(self, @selector(yp_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (_YPViewControllerWillAppearInjectBlock)yp_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark - YPTabContentView

@interface YPTabContentView () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, _YPTabContentScrollViewDelegate> {
    
    CGFloat _lastContentScrollViewOffsetX;
    NSUInteger _lastCenterIndex;
}

@property (nonatomic, strong) _YPTabContentScrollView *contentScrollView;
@property (nonatomic, assign) BOOL isMoveToSuperviewFirstTime;

@property (nonatomic, assign) CGFloat headerViewDefaultHeight;
@property (nonatomic, assign) CGFloat tabBarStopOnTopHeight;

@property (nonatomic, assign) BOOL contentScrollEnabled;
@property (nonatomic, assign) BOOL contentSwitchAnimated;

@property (nonatomic, strong, readwrite) UIView *headerView;
@property (nonatomic, strong) UITableViewCell *containerTableViewCell;
@property (nonatomic, assign) BOOL canChildScroll;
@property (nonatomic, assign) BOOL canContentScroll;
@property (nonatomic, assign) YPTabHeaderStyle headerStyle;
@property (nonatomic, strong) UIView *tabBarContainerView;

@end

@implementation YPTabContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    _tabBar = [[YPTabBar alloc] init];
    _tabBar.delegate = self;
    
    _contentScrollView = [[_YPTabContentScrollView alloc] initWithFrame:self.frame];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.scrollEnabled = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.scrollsToTop = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.yp_delegate = self;
    _contentScrollView.interceptRightSlideGuetureInFirstPage = self.interceptRightSlideGuetureInFirstPage;
    _contentScrollView.interceptLeftSlideGuetureInLastPage = self.interceptLeftSlideGuetureInLastPage;
    [self addSubview:_contentScrollView];

    _loadViewOfChildContollerWhileAppear = NO;
    _removeViewOfChildContollerWhileDeselected = YES;
    _selectedTabIndex = NSNotFound;
    _defaultSelectedTabIndex = 0;
    _isMoveToSuperviewFirstTime = YES;
}

- (void)setTabBar:(YPTabBar *)tabBar {
    _tabBar = tabBar;
    _tabBar.delegate = self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return;
    }
    if (self.headerView) {
        self.headerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.headerViewDefaultHeight);
        
        self.tabBarContainerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.tabBarContainerView.frame.size.height);
        self.tabBar.frame = self.tabBarContainerView.bounds;
        self.contentScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - self.tabBarContainerView.frame.size.height - self.tabBarStopOnTopHeight);
        [self.containerTableView reloadData];
    } else {
        self.contentScrollView.frame = self.bounds;
    }
    [self updateContentViewsFrame];
}


- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *vc in _viewControllers) {
        [vc removeFromParentViewController];
        if (vc.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
    }

    _viewControllers = [viewControllers copy];
    
    UIViewController *containerVC = [self containerViewController];

    NSMutableArray *items = [NSMutableArray array];
    for (UIViewController *vc in _viewControllers) {
        if (containerVC) {
            [containerVC addChildViewController:vc];
        }
        
        YPTabItem *item = [YPTabItem buttonWithType:UIButtonTypeCustom];
        item.image = vc.yp_tabItemImage;
        item.selectedImage = vc.yp_tabItemSelectedImage;
        item.title = vc.yp_tabItemTitle;
        [items addObject:item];
    }
    self.tabBar.items = items;

    // 更新scrollView的content size
    if (self.contentScrollEnabled) {
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.bounds.size.width * _viewControllers.count,
                self.contentScrollView.bounds.size.height);
    }
    
    _selectedTabIndex = NSNotFound;
    self.tabBar.selectedItemIndex = self.defaultSelectedTabIndex;
}

- (void)setContentScrollEnabledAndTapSwitchAnimated:(BOOL)switchAnimated {
    self.contentScrollView.scrollEnabled = YES;
    self.contentScrollEnabled = YES;
    [self updateContentViewsFrame];
    self.contentSwitchAnimated = switchAnimated;
}

- (void)setContentScrollEnabled:(BOOL)enabled tapSwitchAnimated:(BOOL)animated {
    if (!self.contentScrollEnabled && enabled) {
        self.contentScrollEnabled = enabled;
        [self updateContentViewsFrame];
    }
    self.contentScrollView.scrollEnabled = enabled;
    self.contentSwitchAnimated = animated;
}

- (void)updateContentViewsFrame {
    if (self.contentScrollEnabled) {
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.bounds.size.width * self.viewControllers.count, self.contentScrollView.bounds.size.height);
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *_Nonnull controller,
                NSUInteger idx, BOOL *_Nonnull stop) {
            if (controller.isViewLoaded) {
                controller.view.frame = [self frameForControllerAtIndex:idx];
            }
        }];
        [self.contentScrollView scrollRectToVisible:self.selectedController.view.frame animated:NO];
    } else {
        self.contentScrollView.contentSize = self.contentScrollView.bounds.size;
        self.selectedController.view.frame = self.contentScrollView.bounds;
    }
}

- (CGRect)frameForControllerAtIndex:(NSUInteger)index {
    return CGRectMake(index * self.contentScrollView.bounds.size.width,
                      0,
                      self.contentScrollView.bounds.size.width,
                      self.contentScrollView.bounds.size.height);
}

- (void)setInterceptRightSlideGuetureInFirstPage:(BOOL)interceptRightSlideGuetureInFirstPage {
    _interceptRightSlideGuetureInFirstPage = interceptRightSlideGuetureInFirstPage;
    self.contentScrollView.interceptRightSlideGuetureInFirstPage = interceptRightSlideGuetureInFirstPage;
}

- (void)setInterceptLeftSlideGuetureInLastPage:(BOOL)interceptLeftSlideGuetureInLastPage {
    _interceptLeftSlideGuetureInLastPage = interceptLeftSlideGuetureInLastPage;
    self.contentScrollView.interceptLeftSlideGuetureInLastPage = interceptLeftSlideGuetureInLastPage;
}

- (void)setInterceptRightSlideGuetureMaxAllowedDistance:(CGFloat)interceptRightSlideGuetureMaxAllowedDistance {
    _interceptRightSlideGuetureMaxAllowedDistance = interceptRightSlideGuetureMaxAllowedDistance;
    self.contentScrollView.interceptRightSlideGuetureMaxAllowedDistance = interceptRightSlideGuetureMaxAllowedDistance;
}

- (void)setSelectedTabIndex:(NSUInteger)selectedTabIndex {
    self.tabBar.selectedItemIndex = selectedTabIndex;
}

- (UIViewController *)selectedController {
    if (self.selectedTabIndex != NSNotFound) {
        return self.viewControllers[self.selectedTabIndex];
    }
    return nil;
}

- (UIScrollView *)containerScrollView {
    return self.contentScrollView;
}

- (UIViewController *)containerViewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - Super

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (!self.isMoveToSuperviewFirstTime) {
        return;
    }
    
    UIViewController *vc = [self containerViewController];
    vc.automaticallyAdjustsScrollViewInsets = NO;
    __weak UIViewController *weakVC = vc;
    __weak YPTabContentView *weakSelf = self;
    vc.yp_willAppearInjectBlock = ^(UIViewController *viewController, BOOL animated) {
        __strong UIViewController *strongVC = weakVC;
        __strong YPTabContentView *strongSelf = weakSelf;
        strongSelf.selectedTabIndex = self.defaultSelectedTabIndex;
        strongSelf.isMoveToSuperviewFirstTime = NO;
        strongVC.yp_willAppearInjectBlock = nil;
    };
}

#pragma mark - HeaderView

- (void)setHeaderView:(UIView *)headerView
                style:(YPTabHeaderStyle)style
         headerHeight:(CGFloat)headerHeight
         tabBarHeight:(CGFloat)tabBarHeight
tabBarStopOnTopHeight:(CGFloat)tabBarStopOnTopHeight
                frame:(CGRect)frame {
    if (!headerView) {
        return;
    }
    self.headerStyle = style;
    self.headerViewDefaultHeight = headerHeight;
    self.tabBarStopOnTopHeight = tabBarStopOnTopHeight;
    
    self.frame = frame;
    self.headerView = headerView;
    self.headerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.headerViewDefaultHeight);
    
    [self.contentScrollView removeFromSuperview];
    self.containerTableView = [[YPContainerTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.containerTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerTableView.delegate = self;
    self.containerTableView.dataSource = self;
    
    if (style == YPTabHeaderStyleStretch) {
        UIView *view = [[UIView alloc] initWithFrame:self.headerView.bounds];
        self.containerTableView.tableHeaderView = view;
        [self.containerTableView addSubview:self.headerView];
    } else {
        self.containerTableView.tableHeaderView = self.headerView;
    }
    
    if (@available(iOS 11.0, *)) {
        self.containerTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self addSubview:self.containerTableView];
    
    self.contentScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - tabBarHeight - self.tabBarStopOnTopHeight);
    self.containerTableViewCell = [[UITableViewCell alloc] init];
    self.containerTableViewCell.backgroundColor = [UIColor clearColor];
    [self.containerTableViewCell.contentView addSubview:self.contentScrollView];
    
    self.tabBarContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, tabBarHeight)];
    self.tabBar.frame = self.tabBarContainerView.bounds;
    [self.tabBar removeFromSuperview];
    [self.tabBarContainerView addSubview:self.tabBar];
    
    self.canContentScroll = YES;
    self.canChildScroll = NO;
}

- (void)containerTableViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.containerTableView) {
        return;
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat stopY = self.headerViewDefaultHeight - self.tabBarStopOnTopHeight;
    if (!self.canContentScroll) {
        // 这里通过固定contentOffset的值，来实现不滚动
        self.containerTableView.contentOffset = CGPointMake(0, stopY);
    } else if (self.containerTableView.contentOffset.y >= stopY) {
        self.containerTableView.contentOffset = CGPointMake(0, stopY);
        self.canContentScroll = NO;
        self.canChildScroll = YES;
    }
    
    scrollView.showsVerticalScrollIndicator = !_canChildScroll;
    
    if (self.headerStyle == YPTabHeaderStyleStretch) {
        if (offsetY <= 0) {
            self.headerView.frame = CGRectMake(0,
                                               offsetY,
                                               self.headerView.frame.size.width,
                                               self.headerViewDefaultHeight - offsetY);
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:didChangedContentOffsetY:)]) {
        [self.delegate tabContentView:self didChangedContentOffsetY:scrollView.contentOffset.y];
    }
}

- (void)childScrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canChildScroll) {
        self.selectedController.yp_scrollView.contentOffset = CGPointZero;
    } else if (self.selectedController.yp_scrollView.contentOffset.y <= 0) {
        self.selectedController.yp_scrollView.contentOffset = CGPointZero;
        self.canChildScroll = NO;
        self.canContentScroll = YES;
        for (UIViewController *vc in self.viewControllers) {
            if (vc.isViewLoaded) {
                vc.yp_scrollView.contentOffset = CGPointZero;
            }
        }
    }
    scrollView.showsVerticalScrollIndicator = _canChildScroll;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.containerTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.contentScrollView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.tabBarContainerView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tabBarContainerView;
}

#pragma mark - YPTabBarDelegate

- (BOOL)yp_tabBar:(YPTabBar *)tabBar shouldSelectItemAtIndex:(NSUInteger)index {
    return [self shouldSelectItemAtIndex:index];
}

- (void)yp_tabBar:(YPTabBar *)tabBar willSelectItemAtIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:willSelectTabAtIndex:)]) {
        [self.delegate tabContentView:self willSelectTabAtIndex:index];
    }
}

- (void)yp_tabBar:(YPTabBar *)tabBar didClickedItemAtIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:didClickedTabAtIndex:)]) {
        [self.delegate tabContentView:self didClickedTabAtIndex:index];
    }
}

- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSUInteger)index {
    if (index == self.selectedTabIndex) {
        return;
    }
    UIViewController *oldController = nil;
    if (self.selectedTabIndex != NSNotFound) {
        oldController = self.viewControllers[self.selectedTabIndex];
        [oldController yp_tabItemDidDeselected];
        if ([oldController respondsToSelector:@selector(tabItemDidDeselected)]) {
            [oldController performSelector:@selector(tabItemDidDeselected)];
        }
        if (!self.contentScrollEnabled ||
                (self.contentScrollEnabled && self.removeViewOfChildContollerWhileDeselected)) {
            [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *_Nonnull controller, NSUInteger idx, BOOL *_Nonnull stop) {
                if (idx != index && controller.isViewLoaded && controller.view.superview) {
                    [controller.view removeFromSuperview];
                }
            }];
        }
    }
    UIViewController *curController = self.viewControllers[index];
    if (self.contentScrollEnabled) {
        // contentView支持滚动
        curController.view.frame = [self frameForControllerAtIndex:index];

        [self.contentScrollView addSubview:curController.view];
        // 切换到curController
        [self.contentScrollView scrollRectToVisible:curController.view.frame animated:self.contentSwitchAnimated];

    } else {
        // contentView不支持滚动
        // 设置curController.view的frame
        curController.view.frame = self.contentScrollView.bounds;
        [self.contentScrollView addSubview:curController.view];
    }
    
    if (self.headerView && !curController.yp_scrollView.yp_didScrollHandler) {
        __weak YPTabContentView *weakSelf = self;
        curController.yp_scrollView.yp_didScrollHandler = ^(UIScrollView *scrollView) {
            __strong YPTabContentView *strongSelf = weakSelf;
            [strongSelf childScrollViewDidScroll:scrollView];
        };
    }

    // 获取是否是第一次被选中的标识
    
    if (curController.yp_hasBeenDisplayed) {
        [curController yp_tabItemDidSelected:NO];
    } else {
        [curController yp_tabItemDidSelected:YES];
        curController.yp_hasBeenDisplayed = YES;
    }

    if ([curController respondsToSelector:@selector(tabItemDidSelected)]) {
        [curController performSelector:@selector(tabItemDidSelected)];
    }

    // 当contentView为scrollView及其子类时，设置它支持点击状态栏回到顶部
    if (oldController && [oldController.view isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *) oldController.view setScrollsToTop:NO];
    }
    if ([curController.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *curScrollView = (UIScrollView *) curController.view;
        [curScrollView setScrollsToTop:YES];
    }

    _selectedTabIndex = index;

    if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:didSelectedTabAtIndex:)]) {
        [self.delegate tabContentView:self didSelectedTabAtIndex:index];
    }
}

#pragma mark - _YPTabContentScrollViewDelegate

- (BOOL)scrollView:(_YPTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index {
    return [self shouldSelectItemAtIndex:index];
}

- (BOOL)shouldSelectItemAtIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:shouldSelectTabAtIndex:)]) {
        return [self.delegate tabContentView:self shouldSelectTabAtIndex:index];
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        self.containerTableView.scrollEnabled = YES;
        NSUInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.tabBar.selectedItemIndex = page;
        if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewDidEndDecelerating:)]) {
            [self.delegate contentViewDidEndDecelerating:scrollView];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.containerTableView) {
        [self containerTableViewDidScroll:scrollView];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewDidScroll:)]) {
        [self.delegate contentViewDidScroll:scrollView];
    }
    
    if (self.tabBar.scrollEnabled &&
        self.tabBar.autoScrollSelectedItemToCenter &&
        self.tabBar.scrollSelectedItemToCenterAnimated) {
        CGRect visibleBounds = self.contentScrollView.bounds;
        NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
        if (index >= 0 && _lastCenterIndex != index) {
            [self.tabBar scrollItemToCenterWithIndex:index animated:self.tabBar.scrollSelectedItemToCenterAnimated];
            _lastCenterIndex = index;
        }
    }
    
    // 如果不是手势拖动导致的此方法被调用，不处理
    if (!(scrollView.isDragging || scrollView.isDecelerating)) {
        if (scrollView.contentOffset.x == 0) {
            // 解决有时候滑动冲突后scrollView跳动导致的item颜色显示错乱的问题
            [self.tabBar updateSubViewsWhenParentScrollViewScroll:self.contentScrollView];
        }
        
        return;
    }
    self.containerTableView.scrollEnabled = NO;
    // 滑动越界不处理
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = scrollView.frame.size.width;

    if (offsetX < 0) {
        return;
    }
    if (offsetX > scrollView.contentSize.width - scrollViewWidth) {
        return;
    }

    NSUInteger leftIndex = offsetX / scrollViewWidth;
    NSUInteger rightIndex = leftIndex + 1;

    // 这里处理shouldSelectItemAtIndex方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:shouldSelectTabAtIndex:)] && !scrollView.isDecelerating) {
        NSUInteger targetIndex;
        if (_lastContentScrollViewOffsetX < (CGFloat)offsetX) {
            // 向左
            targetIndex = rightIndex;
        } else {
            // 向右
            targetIndex = leftIndex;
        }
        if (targetIndex != self.selectedTabIndex) {
            if (![self shouldSelectItemAtIndex:targetIndex]) {
                [scrollView setContentOffset:CGPointMake(self.selectedTabIndex * scrollViewWidth, 0) animated:NO];
            }
        }
    }
    _lastContentScrollViewOffsetX = offsetX;

    // 刚好处于能完整显示一个child view的位置
    if (leftIndex == offsetX / scrollViewWidth) {
        rightIndex = leftIndex;
    }
    // 将需要显示的child view放到scrollView上
    for (NSUInteger index = leftIndex; index <= rightIndex; index++) {
        UIViewController *controller = self.viewControllers[index];

        if (!controller.isViewLoaded && self.loadViewOfChildContollerWhileAppear) {
            CGRect frame = [self frameForControllerAtIndex:index];
            controller.view.frame = frame;
        }
        if (controller.isViewLoaded && !controller.view.superview) {
            [self.contentScrollView addSubview:controller.view];
        }
    }

    // 同步修改tarBar的子视图状态
    [self.tabBar updateSubViewsWhenParentScrollViewScroll:self.contentScrollView];
}

@end

@implementation _YPTabContentScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UISlider class]]) {
        self.scrollEnabled = NO;
    } else {
        self.scrollEnabled = YES;
    }
    return view;
}

/**
 *  重写此方法，在需要的时候，拦截UIPanGestureRecognizer
 */
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    NSLog(@"view-->%@", gestureRecognizer.view.description);
    if (![gestureRecognizer respondsToSelector:@selector(translationInView:)]) {
        return YES;
    }
    // 计算可能切换到的index
    NSInteger currentIndex = self.contentOffset.x / self.frame.size.width;
    NSInteger targetIndex = currentIndex;
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    if (translation.x > 0) {
        targetIndex = currentIndex - 1;
    } else {
        targetIndex = currentIndex + 1;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = self.interceptRightSlideGuetureMaxAllowedDistance;
    int x = (int)beginningLocation.x % (int)self.frame.size.width;
    if (maxAllowedInitialDistance > 0 && x < maxAllowedInitialDistance) {
        return NO;
    }
    
    // 第一页往右滑动
    if (self.interceptRightSlideGuetureInFirstPage && targetIndex < 0) {
        return NO;
    }
    
    // 最后一页往左滑动
    if (self.interceptLeftSlideGuetureInLastPage) {
        NSUInteger numberOfPage = self.contentSize.width / self.frame.size.width;
        if (targetIndex >= numberOfPage) {
            return NO;
        }
    }
    
    // 其他情况
    if (self.yp_delegate && [self.yp_delegate respondsToSelector:@selector(scrollView:shouldScrollToPageIndex:)]) {
        return [self.yp_delegate scrollView:self shouldScrollToPageIndex:targetIndex];
    }
    
    return YES;
}

@end

