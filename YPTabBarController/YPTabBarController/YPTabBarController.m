//
//  YPTabBarController.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBarController.h"
#import "UIViewController+YPTabBarController.h"
#import "UIScrollView+YPTabBarController.h"
#import <objc/runtime.h>

#define TAB_BAR_HEIGHT 50

static NSString *const kContentOffset = @"contentOffset";

#pragma mark - YPTabContentScrollView

/**
 *  自定义UIScrollView，在需要时可以拦截其滑动手势
 */

@class YPTabContentScrollView;

@protocol YPTabContentScrollViewDelegate <NSObject>

@optional

- (BOOL)scrollView:(YPTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index;

@end

@interface YPTabContentScrollView : UIScrollView

@property (nonatomic, weak) id <YPTabContentScrollViewDelegate> yp_delegate;

@property (nonatomic, assign) BOOL interceptLeftSlideGuetureInLastPage;
@property (nonatomic, assign) BOOL interceptRightSlideGuetureInFirstPage;

@end

@interface UIViewController (Private)

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, assign) BOOL hasAddedContentOffsetObserver;

@end

@implementation UIViewController (Private)

- (void)setHasBeenDisplayed:(BOOL)hasBeenDisplayed {
    objc_setAssociatedObject(self, @selector(hasBeenDisplayed), @(hasBeenDisplayed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasBeenDisplayed {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHasAddedContentOffsetObserver:(BOOL)hasAddedContentOffsetObserver {
    objc_setAssociatedObject(self, @selector(hasAddedContentOffsetObserver), @(hasAddedContentOffsetObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasAddedContentOffsetObserver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end


#pragma mark - YPTabBarController

@interface YPTabBarController () <UIScrollViewDelegate, YPTabContentScrollViewDelegate> {
    BOOL _didViewAppeared;
    CGFloat _lastContentScrollViewOffsetX;
    CGFloat _currentScrollViewOffsetY;
}

@property (nonatomic, strong) YPTabContentScrollView *contentScrollView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) CGFloat headerViewDefaultHeight;
@property (nonatomic, assign) CGFloat tabBarStopOnTopHeight;
@property (nonatomic, assign) BOOL headerViewNeedStretch;

@property (nonatomic, assign) BOOL contentScrollEnabled;
@property (nonatomic, assign) BOOL contentSwitchAnimated;

@end

@implementation YPTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _selectedControllerIndex = NSNotFound;
    _tabBar = [[YPTabBar alloc] init];
    _tabBar.delegate = self;

    _contentScrollView = [[YPTabContentScrollView alloc] init];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.scrollEnabled = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.scrollsToTop = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.yp_delegate = self;
    _contentScrollView.interceptRightSlideGuetureInFirstPage = self.interceptRightSlideGuetureInFirstPage;
    _contentScrollView.interceptLeftSlideGuetureInLastPage = self.interceptLeftSlideGuetureInLastPage;

    _loadViewOfChildContollerWhileAppear = NO;
    _removeViewOfChildContollerWhileDeselected = YES;
    _defaultSelectedControllerIndex = 0;
}

- (void)dealloc {
    for (UIViewController *controller in self.viewControllers) {
        if (controller.hasAddedContentOffsetObserver) {
            // 如果vc注册了contentOffset的观察者，需移除
            [controller.yp_displayView removeObserver:self forKeyPath:kContentOffset];
            controller.hasAddedContentOffsetObserver = NO;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupFrameOfTabBarAndContentView];

    [self.view addSubview:self.tabBar];
    [self.view insertSubview:self.contentScrollView belowSubview:self.tabBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 在第一次调用viewWillAppear方法时，初始化选中的item
    if (!_didViewAppeared) {
        self.tabBar.selectedItemIndex = self.defaultSelectedControllerIndex;
        _didViewAppeared = YES;
    }
}

- (void)setupFrameOfTabBarAndContentView {
    // 设置默认的tabBar的frame和contentViewFrame
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    CGFloat contentViewY = 0;
    CGFloat tabBarY = screenSize.height - TAB_BAR_HEIGHT;
    if (screenSize.height == 812) {
        tabBarY -= 34;
    }
    CGFloat contentViewHeight = tabBarY;
    // 如果parentViewController为UINavigationController及其子类
    if ([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            !self.navigationController.navigationBarHidden &&
            !self.navigationController.navigationBar.hidden) {

        CGFloat navMaxY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        if (!self.navigationController.navigationBar.translucent ||
                self.edgesForExtendedLayout == UIRectEdgeNone ||
                self.edgesForExtendedLayout == UIRectEdgeTop) {
            tabBarY = screenSize.height - TAB_BAR_HEIGHT - navMaxY;
            contentViewHeight = tabBarY;
        } else {
            contentViewY = navMaxY;
            contentViewHeight = screenSize.height - TAB_BAR_HEIGHT - contentViewY;
        }
    }

    [self setTabBarFrame:CGRectMake(0, tabBarY, screenSize.width, TAB_BAR_HEIGHT)
        contentViewFrame:CGRectMake(0, contentViewY, screenSize.width, contentViewHeight)];
}

- (void)setContentViewFrame:(CGRect)contentViewFrame {
    _contentViewFrame = contentViewFrame;
    self.contentScrollView.frame = contentViewFrame;
    [self updateContentViewsFrame];
}

- (void)setTabBarFrame:(CGRect)tabBarFrame contentViewFrame:(CGRect)contentViewFrame {
    if (self.headerView) {
        return;
    }
    self.tabBar.frame = tabBarFrame;
    self.contentViewFrame = contentViewFrame;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *controller in _viewControllers) {
        if (controller.hasAddedContentOffsetObserver) {
            [controller.yp_displayView removeObserver:self forKeyPath:kContentOffset];
            controller.hasAddedContentOffsetObserver = NO;
        }
        [controller removeFromParentViewController];
        if (controller.isViewLoaded) {
            [controller.yp_displayView removeFromSuperview];
        }
    }

    _viewControllers = [viewControllers copy];

    NSMutableArray *items = [NSMutableArray array];
    for (UIViewController *controller in _viewControllers) {
        [self addChildViewController:controller];

        YPTabItem *item = [YPTabItem buttonWithType:UIButtonTypeCustom];
        item.image = controller.yp_tabItemImage;
        item.selectedImage = controller.yp_tabItemSelectedImage;
        item.title = controller.yp_tabItemTitle;
        [items addObject:item];
    }
    self.tabBar.items = items;

    if (_didViewAppeared) {
        _selectedControllerIndex = NSNotFound;
        self.tabBar.selectedItemIndex = 0;
    }

    // 更新scrollView的content size
    if (self.contentScrollEnabled) {
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.bounds.size.width * _viewControllers.count,
                self.contentScrollView.bounds.size.height);
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

- (void)setSelectedControllerIndex:(NSUInteger)selectedControllerIndex {
    self.tabBar.selectedItemIndex = selectedControllerIndex;
}

- (UIViewController *)selectedController {
    if (self.selectedControllerIndex != NSNotFound) {
        return self.viewControllers[self.selectedControllerIndex];
    }
    return nil;
}

- (void)didSelectViewControllerAtIndex:(NSUInteger)index {
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
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
    [self.view addSubview:self.headerView];

    self.headerViewNeedStretch = needStretch;
    self.headerViewDefaultHeight = headerHeight;

    self.tabBar.frame = CGRectMake(0,
                                   CGRectGetMaxY(self.headerView.frame),
                                   self.view.frame.size.width,
                                   tabBarHeight);

    self.contentScrollView.frame = CGRectMake(0,
                                              0,
                                              self.view.frame.size.width,
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
    CGPoint point = [gesture translationInView:self.view];
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
            headerFrame = CGRectMake(0, -minHeaderY, self.view.frame.size.width, self.headerViewDefaultHeight);
        } else if (offsetY >= 0 && offsetY <= minHeaderY) {
            headerFrame = CGRectMake(0, -offsetY, self.view.frame.size.width, self.headerViewDefaultHeight);
        } else {
            CGFloat height = self.headerViewDefaultHeight - (self.headerViewNeedStretch ? offsetY : 0);
            headerFrame = CGRectMake(0, 0, self.view.frame.size.width, height);
        }
        self.headerView.frame = headerFrame;

        CGRect tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.y = CGRectGetMaxY(headerFrame);
        self.tabBar.frame = tabBarFrame;
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

- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSUInteger)index {
    if (index == self.selectedControllerIndex) {
        return;
    }
    UIViewController *oldController = nil;
    if (self.selectedControllerIndex != NSNotFound) {
        oldController = self.viewControllers[self.selectedControllerIndex];
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
    BOOL hasBeenDisplayed = curController.hasBeenDisplayed;
    if (hasBeenDisplayed) {
        [curController yp_tabItemDidSelected:NO];
    } else {
        [curController yp_tabItemDidSelected:YES];
        curController.hasBeenDisplayed = YES;
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
            curScrollView.minContentSizeHeight = self.contentScrollView.frame.size.height - self.tabBar.frame.size.height - self.tabBarStopOnTopHeight;

            if (oldController && oldController.hasAddedContentOffsetObserver) {
                // 移除oldController的yp_displayView注册的观察者
                [oldController.yp_displayView removeObserver:self forKeyPath:kContentOffset];
                oldController.hasAddedContentOffsetObserver = NO;
            }
            if (!curController.hasAddedContentOffsetObserver) {
                // 注册curScrollView的观察者
                [curScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:NULL];
                curController.hasAddedContentOffsetObserver = YES;
            }
            [self updateContentOffsetOfDisplayScrollView:curScrollView];
        }
    }

    _selectedControllerIndex = index;

    [self didSelectViewControllerAtIndex:_selectedControllerIndex];
}

#pragma mark - YPTabContentScrollViewDelegate

- (BOOL)scrollView:(YPTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index {
    if ([self respondsToSelector:@selector(yp_tabBar:shouldSelectItemAtIndex:)]) {
        return [self yp_tabBar:self.tabBar shouldSelectItemAtIndex:index];
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
    if ([self respondsToSelector:@selector(yp_tabBar:shouldSelectItemAtIndex:)] && !scrollView.isDecelerating) {
        NSUInteger targetIndex;
        if (_lastContentScrollViewOffsetX < (CGFloat) offsetX) {
            // 向左
            targetIndex = rightIndex;
        } else {
            // 向右
            targetIndex = leftIndex;
        }
        if (targetIndex != self.selectedControllerIndex) {
            if (![self yp_tabBar:self.tabBar shouldSelectItemAtIndex:targetIndex]) {
                [scrollView setContentOffset:CGPointMake(self.selectedControllerIndex * scrollViewWidth, 0) animated:NO];
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
                UIScrollView *scrollView = (UIScrollView *) controller.yp_displayView;
                // 如果有headerView，需要更新contentOffset
                UIEdgeInsets insets = scrollView.contentInset;
                insets.top = self.headerViewDefaultHeight + self.tabBar.frame.size.height;
                scrollView.contentInset = insets;
                scrollView.scrollIndicatorInsets = insets;
                scrollView.minContentSizeHeight = self.contentScrollView.frame.size.height - self.tabBar.frame.size.height - self.tabBarStopOnTopHeight;
                [self updateContentOffsetOfDisplayScrollView:scrollView];
            }
        }
    }

    // 同步修改tarBar的子视图状态
    [self.tabBar updateSubViewsWhenParentScrollViewScroll:self.contentScrollView];
}

@end


@implementation YPTabContentScrollView

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

