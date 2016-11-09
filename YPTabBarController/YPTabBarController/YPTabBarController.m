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

/**
 *  自定义UIScrollView，在需要时可以拦截其滑动手势
 */

@class YPTabContentScrollView;

@protocol YPTabContentScrollViewDelegate <NSObject>

@optional

- (BOOL)scrollView:(YPTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index;

@end

@interface YPTabContentScrollView : UIScrollView

@property (nonatomic, weak) id<YPTabContentScrollViewDelegate> yp_delegate;

@property (nonatomic, assign) BOOL interceptLeftSlideGuetureInLastPage;
@property (nonatomic, assign) BOOL interceptRightSlideGuetureInFirstPage;

@end


@interface YPTabBarController () <UIScrollViewDelegate, YPTabContentScrollViewDelegate> {
    BOOL _didViewAppeared;
}

@property (nonatomic, strong) YPTabContentScrollView *contentScrollView;

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
    _selectedControllerIndex = -1;
    _tabBar = [[YPTabBar alloc] init];
    _tabBar.delegate = self;
    
    _loadViewOfChildContollerWhileAppear = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupFrameOfTabBarAndContentView];
    
    [self.view addSubview:self.tabBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 在第一次调用viewWillAppear方法时，初始化选中的item
    if (!_didViewAppeared) {
        self.tabBar.selectedItemIndex = 0;
        _didViewAppeared = YES;
    }
}

- (void)setupFrameOfTabBarAndContentView {
    // 设置默认的tabBar的frame和contentViewFrame
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat contentViewY = 0;
    CGFloat tabBarY = screenSize.height - TAB_BAR_HEIGHT;
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
    [self updateContentViewsFrame];
}

- (void)setTabBarFrame:(CGRect)tabBarFrame contentViewFrame:(CGRect)contentViewFrame {
    self.tabBar.frame = tabBarFrame;
    self.contentViewFrame = contentViewFrame;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    
    for (UIViewController *controller in _viewControllers) {
        [controller removeFromParentViewController];
        [controller.view removeFromSuperview];
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
        _selectedControllerIndex = -1;
        self.tabBar.selectedItemIndex = 0;
    }
    
    // 更新scrollView的content size
    if (self.contentScrollView) {
        self.contentScrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * _viewControllers.count,
                                                 self.contentViewFrame.size.height);
    }
}

- (void)setContentScrollEnabledAndTapSwitchAnimated:(BOOL)switchAnimated {
    if (!self.contentScrollView) {
        self.contentScrollView = [[YPTabContentScrollView alloc] initWithFrame:self.contentViewFrame];
        self.contentScrollView.pagingEnabled = YES;
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.showsVerticalScrollIndicator = NO;
        self.contentScrollView.scrollsToTop = NO;
        self.contentScrollView.delegate = self;
        self.contentScrollView.yp_delegate = self;
        [self.view insertSubview:self.contentScrollView belowSubview:self.tabBar];
        self.contentScrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * self.viewControllers.count, self.contentViewFrame.size.height);
    }
    [self updateContentViewsFrame];
    self.contentSwitchAnimated = switchAnimated;
}

- (void)updateContentViewsFrame {
    if (self.contentScrollView) {
        self.contentScrollView.frame = self.contentViewFrame;
        self.contentScrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * self.viewControllers.count,
                                                 self.contentViewFrame.size.height);
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller,
                                                           NSUInteger idx, BOOL * _Nonnull stop) {
            if (controller.isViewLoaded) {
                controller.view.frame = [self frameForControllerAtIndex:idx];
            }
        }];
        [self.contentScrollView scrollRectToVisible:self.selectedController.view.frame animated:NO];
    } else {
        self.selectedController.view.frame = self.contentViewFrame;
    }
}

- (CGRect)frameForControllerAtIndex:(NSInteger)index {
    return CGRectMake(index * self.contentViewFrame.size.width,
                      0,
                      self.contentViewFrame.size.width,
                      self.contentViewFrame.size.height);
}

- (void)setInterceptRightSlideGuetureInFirstPage:(BOOL)interceptRightSlideGuetureInFirstPage {
    _interceptRightSlideGuetureInFirstPage = interceptRightSlideGuetureInFirstPage;
    self.contentScrollView.interceptRightSlideGuetureInFirstPage = interceptRightSlideGuetureInFirstPage;
}

- (void)setInterceptLeftSlideGuetureInLastPage:(BOOL)interceptLeftSlideGuetureInLastPage {
    _interceptLeftSlideGuetureInLastPage = interceptLeftSlideGuetureInLastPage;
    self.contentScrollView.interceptLeftSlideGuetureInLastPage = interceptLeftSlideGuetureInLastPage;
}

- (void)setSelectedControllerIndex:(NSInteger)selectedControllerIndex {
    self.tabBar.selectedItemIndex = selectedControllerIndex;
}

- (UIViewController *)selectedController {
    if (self.selectedControllerIndex >= 0) {
        return self.viewControllers[self.selectedControllerIndex];
    }
    return nil;
}

#pragma mark - YPTabBarDelegate

- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSInteger)index {
    if (index == self.selectedControllerIndex) {
        return;
    }
    UIViewController *oldController = nil;
    if (self.selectedControllerIndex >= 0) {
        oldController = self.viewControllers[self.selectedControllerIndex];
        [oldController tabItemDidDeselected];
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != index && controller.isViewLoaded && controller.view.superview) {
                [controller.view removeFromSuperview];
            }
        }];
    }
    UIViewController *curController = self.viewControllers[index];
    if (self.contentScrollView) {
        // contentView支持滚动
        if (!curController.isViewLoaded) {
            curController.view.frame = [self frameForControllerAtIndex:index];
        }
        
        [self.contentScrollView addSubview:curController.view];
        // 切换到curController
        [self.contentScrollView scrollRectToVisible:curController.view.frame animated:self.contentSwitchAnimated];
    } else {
        // contentView不支持滚动
        
        [self.view insertSubview:curController.view belowSubview:self.tabBar];
        // 设置curController.view的frame
        if (!CGRectEqualToRect(curController.view.frame, self.contentViewFrame)) {
            curController.view.frame = self.contentViewFrame;
        }
    }
    
    [curController tabItemDidSelected];
    
    // 当contentView为scrollView及其子类时，设置它支持点击状态栏回到顶部
    if (oldController && [oldController.view isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)oldController.view setScrollsToTop:NO];
    }
    if ([curController.view isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)curController.view setScrollsToTop:YES];
    }
//    UIResponder
    _selectedControllerIndex = index;
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
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.tabBar.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果不是手势拖动导致的此方法被调用，不处理
    if (!(scrollView.isDragging || scrollView.isDecelerating)) {
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

    NSInteger leftIndex = offsetX / scrollViewWidth;
    NSInteger rightIndex = leftIndex + 1;
    if (leftIndex == offsetX / scrollViewWidth) {
        rightIndex = leftIndex;
    }
    // 将需要显示的child view放到scrollView上
    for (NSInteger index = leftIndex; index <= rightIndex; index++) {
        UIViewController *controller = self.viewControllers[index];
        
        if (!controller.isViewLoaded && self.loadViewOfChildContollerWhileAppear) {
            controller.view.frame = [self frameForControllerAtIndex:index];
        }
        if (controller.isViewLoaded && !controller.view.superview) {
            [self.contentScrollView addSubview:controller.view];
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
        NSInteger numberOfPage = self.contentSize.width / self.frame.size.width;
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
