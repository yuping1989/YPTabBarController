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

static NSString *const kContentOffset = @"contentOffset";

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

@end

typedef void (^_YPViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (Private)

@property (nonatomic, assign) BOOL yp_hasBeenDisplayed;

@property (nonatomic, assign) BOOL yp_hasAddedContentOffsetObserver;

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

- (void)setYp_hasAddedContentOffsetObserver:(BOOL)yp_hasAddedContentOffsetObserver {
    objc_setAssociatedObject(self, @selector(yp_hasAddedContentOffsetObserver), @(yp_hasAddedContentOffsetObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)yp_hasAddedContentOffsetObserver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setYp_willAppearInjectBlock:(_YPViewControllerWillAppearInjectBlock)block {
    objc_setAssociatedObject(self, @selector(yp_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (_YPViewControllerWillAppearInjectBlock)yp_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark - YPTabBarController

@interface YPTabContentView () <UIScrollViewDelegate, _YPTabContentScrollViewDelegate> {
    BOOL _isDefaultSelectedTabIndexSetuped;
    CGFloat _lastContentScrollViewOffsetX;
    CGFloat _currentScrollViewOffsetY;
}

@property (nonatomic, strong) _YPTabContentScrollView *contentScrollView;

@property (nonatomic, strong, readwrite) UIView *headerView;
@property (nonatomic, assign) CGFloat headerViewDefaultHeight;
@property (nonatomic, assign) CGFloat tabBarStopOnTopHeight;
@property (nonatomic, assign) BOOL headerViewNeedStretch;

@property (nonatomic, assign) BOOL contentScrollEnabled;
@property (nonatomic, assign) BOOL contentSwitchAnimated;

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
    _isDefaultSelectedTabIndexSetuped = NO;
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
    self.contentScrollView.frame = self.bounds;
    [self updateContentViewsFrame];
}

- (void)dealloc {
    for (UIViewController *controller in self.viewControllers) {
        if (controller.yp_hasAddedContentOffsetObserver) {
            // 如果vc注册了contentOffset的观察者，需移除
            [controller.yp_displayView removeObserver:self forKeyPath:kContentOffset];
            controller.yp_hasAddedContentOffsetObserver = NO;
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *vc in _viewControllers) {
        if (vc.yp_hasAddedContentOffsetObserver) {
            [vc.yp_displayView removeObserver:self forKeyPath:kContentOffset];
            vc.yp_hasAddedContentOffsetObserver = NO;
        }
        [vc removeFromParentViewController];
        if (vc.isViewLoaded) {
            [vc.yp_displayView removeFromSuperview];
        }
    }

    _viewControllers = [viewControllers copy];
    
    UIViewController *containerVC = [self contarinerViewController];

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
    
    if (_isDefaultSelectedTabIndexSetuped) {
        _selectedTabIndex = NSNotFound;
        self.tabBar.selectedItemIndex = 0;
    }
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
                controller.yp_displayView.frame = [self frameForControllerAtIndex:idx];
            }
        }];
        [self.contentScrollView scrollRectToVisible:self.selectedController.yp_displayView.frame animated:NO];
    } else {
        self.contentScrollView.contentSize = self.contentScrollView.bounds.size;
        self.selectedController.yp_displayView.frame = self.contentScrollView.bounds;
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

- (void)setSelectedTabIndex:(NSUInteger)selectedTabIndex {
    self.tabBar.selectedItemIndex = selectedTabIndex;
}

- (UIViewController *)selectedController {
    if (self.selectedTabIndex != NSNotFound) {
        return self.viewControllers[self.selectedTabIndex];
    }
    return nil;
}

- (UIViewController *)contarinerViewController {
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
    
    if (_isDefaultSelectedTabIndexSetuped) {
        return;
    }
    
    UIViewController *vc = [self contarinerViewController];
    vc.automaticallyAdjustsScrollViewInsets = NO;
    __weak UIViewController *weakVC = vc;
    vc.yp_willAppearInjectBlock = ^(UIViewController *viewController, BOOL animated) {
        __strong UIViewController *strongVC = weakVC;
        self.selectedTabIndex = self.defaultSelectedTabIndex;
        _isDefaultSelectedTabIndexSetuped = YES;
        strongVC.yp_willAppearInjectBlock = nil;
    };
}

#pragma mark - HeaderView

- (void)setHeaderView:(UIView *)headerView
          needStretch:(BOOL)needStretch
         headerHeight:(CGFloat)headerHeight
         tabBarHeight:(CGFloat)tabBarHeight
    contentViewHeight:(CGFloat)contentViewHeight
tabBarStopOnTopHeight:(CGFloat)tabBarStopOnTopHeight {
    if (!headerView) {
        return;
    }
    self.headerView = headerView;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.headerView.frame = CGRectMake(0, 0, self.frame.size.width, headerHeight);
    [self addSubview:self.headerView];

    self.headerViewNeedStretch = needStretch;
    self.headerViewDefaultHeight = headerHeight;

    self.tabBar.frame = CGRectMake(0,
                                   CGRectGetMaxY(self.headerView.frame),
                                   self.frame.size.width,
                                   tabBarHeight);

    self.contentScrollView.frame = CGRectMake(0,
                                              0,
                                              self.frame.size.width,
                                              headerHeight + tabBarHeight + contentViewHeight);

    self.tabBarStopOnTopHeight = tabBarStopOnTopHeight;

    UIPanGestureRecognizer *gesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.headerView addGestureRecognizer:gesture1];
    [self.tabBar addGestureRecognizer:gesture2];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIScrollView *scrollView = (UIScrollView *) [self.selectedController yp_displayView];
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _currentScrollViewOffsetY = scrollView.contentOffset.y;
    }
    CGPoint point = [gesture translationInView:self];
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, _currentScrollViewOffsetY - point.y);
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat defaultOffsetY = -(self.headerViewDefaultHeight + self.tabBar.frame.size.height);
        if (scrollView.contentOffset.y < defaultOffsetY) {
            [scrollView scrollRectToVisible:CGRectMake(0, scrollView.frame.size.height + defaultOffsetY - 1, scrollView.frame.size.width, 1) animated:YES];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([kContentOffset isEqualToString:keyPath]) {
        NSValue *value = change[NSKeyValueChangeNewKey];
        CGFloat offsetY = [value CGPointValue].y + self.headerViewDefaultHeight + self.tabBar.frame.size.height;
        CGRect headerFrame;
        CGFloat minHeaderY = self.headerViewDefaultHeight - self.tabBarStopOnTopHeight;
        if (offsetY > minHeaderY) {
            headerFrame = CGRectMake(0, -minHeaderY, self.frame.size.width, self.headerViewDefaultHeight);
        } else if (offsetY >= 0 && offsetY <= minHeaderY) {
            headerFrame = CGRectMake(0, -offsetY, self.frame.size.width, self.headerViewDefaultHeight);
        } else {
            CGFloat height = self.headerViewDefaultHeight - (self.headerViewNeedStretch ? offsetY : 0);
            headerFrame = CGRectMake(0, 0, self.frame.size.width, height);
        }
        self.headerView.frame = headerFrame;

        CGRect tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.y = CGRectGetMaxY(headerFrame);
        self.tabBar.frame = tabBarFrame;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabContentView:didChangedContentOffsetY:)]) {
            [self.delegate tabContentView:self didChangedContentOffsetY:offsetY];
        }
    }
}

- (void)updateContentOffsetOfDisplayScrollView:(UIScrollView *)scrollView {
    CGFloat tabBarY = self.tabBar.frame.origin.y;
    if (tabBarY > self.tabBarStopOnTopHeight ||
            scrollView.contentOffset.y == 0 ||
            scrollView.contentOffset.y <= -CGRectGetMaxY(self.tabBar.frame)) {
        scrollView.contentOffset = CGPointMake(0, -(tabBarY + self.tabBar.frame.size.height));
    }
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
                if (idx != index && controller.isViewLoaded && controller.yp_displayView.superview) {
                    [controller.yp_displayView removeFromSuperview];
                }
            }];
        }
    }
    UIViewController *curController = self.viewControllers[index];
    if (self.contentScrollEnabled) {
        // contentView支持滚动
        if (!curController.isViewLoaded) {
            CGRect frame = [self frameForControllerAtIndex:index];
            if (![curController.view isEqual:curController.yp_displayView]) {
                curController.view.frame = frame;
            }
            curController.yp_displayView.frame = frame;
        }

        [self.contentScrollView addSubview:curController.yp_displayView];
        // 切换到curController
        [self.contentScrollView scrollRectToVisible:curController.yp_displayView.frame animated:self.contentSwitchAnimated];

    } else {
        // contentView不支持滚动

        [self.contentScrollView addSubview:curController.yp_displayView];
        // 设置curController.view的frame
        if (!CGRectEqualToRect(curController.yp_displayView.frame, self.contentScrollView.bounds)) {
            if (![curController.view isEqual:curController.yp_displayView]) {
                curController.view.frame = self.contentScrollView.bounds;
            }
            curController.yp_displayView.frame = self.contentScrollView.bounds;
        }
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
    if (oldController && [oldController.yp_displayView isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *) oldController.yp_displayView setScrollsToTop:NO];
    }
    if ([curController.yp_displayView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *curScrollView = (UIScrollView *) curController.yp_displayView;
        [curScrollView setScrollsToTop:YES];
        if (self.headerView) {
            UIEdgeInsets insets = curScrollView.contentInset;
            insets.top = self.headerViewDefaultHeight + self.tabBar.frame.size.height;
            curScrollView.contentInset = insets;
            curScrollView.scrollIndicatorInsets = insets;
            if (![curController yp_disableMinContentHeight]) {
                curScrollView.minContentSizeHeight = self.contentScrollView.frame.size.height - self.tabBar.frame.size.height - self.tabBarStopOnTopHeight;
            }

            if (oldController && oldController.yp_hasAddedContentOffsetObserver) {
                // 移除oldController的yp_displayView注册的观察者
                [oldController.yp_displayView removeObserver:self forKeyPath:kContentOffset];
                oldController.yp_hasAddedContentOffsetObserver = NO;
            }
            if (!curController.yp_hasAddedContentOffsetObserver) {
                // 注册curScrollView的观察者
                [curScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:NULL];
                curController.yp_hasAddedContentOffsetObserver = YES;
            }
            [self updateContentOffsetOfDisplayScrollView:curScrollView];
        }
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
    NSUInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.tabBar.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果不是手势拖动导致的此方法被调用，不处理
    if (!(scrollView.isDragging || scrollView.isDecelerating)) {
        if (scrollView.contentOffset.x == 0) {
            // 解决有时候滑动冲突后scrollView跳动导致的item颜色显示错乱的问题
            [self.tabBar updateSubViewsWhenParentScrollViewScroll:self.contentScrollView];
        }
        return;
    }

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
            if (![controller.view isEqual:controller.yp_displayView]) {
                controller.view.frame = frame;
            }
            [controller.yp_displayView removeFromSuperview];
            controller.yp_displayView.frame = frame;
        }
        if (controller.isViewLoaded && !controller.yp_displayView.superview) {
            [self.contentScrollView addSubview:controller.yp_displayView];

            if (self.headerView) {
                UIScrollView *scrollView = (UIScrollView *)controller.yp_displayView;
                // 如果有headerView，需要更新contentOffset
                UIEdgeInsets insets = scrollView.contentInset;
                insets.top = self.headerViewDefaultHeight + self.tabBar.frame.size.height;
                scrollView.contentInset = insets;
                scrollView.scrollIndicatorInsets = insets;
                if (![controller yp_disableMinContentHeight]) {
                    scrollView.minContentSizeHeight = self.contentScrollView.frame.size.height - self.tabBar.frame.size.height - self.tabBarStopOnTopHeight;
                }
                [self updateContentOffsetOfDisplayScrollView:scrollView];
            }
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

