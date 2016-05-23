//
//  YPTabBar.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBar.h"
#define BADGE_BG_COLOR_DEFAULT [UIColor colorWithRed:252 / 255.0f green:15 / 255.0f blue:29 / 255.0f alpha:1.0f]
@interface YPTabBar ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIImageView *itemSelectedBgImageView;
@property (nonatomic, assign) BOOL itemSelectedBgSwitchAnimated;  // TabItem选中切换时，是否显示动画
@property (nonatomic, assign) UIEdgeInsets itemSelectedBgInsets;
@property (nonatomic, assign) BOOL itemFitTextWidth;
@property (nonatomic, assign) CGFloat itemFitTextWidthSpacing;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) YPTabItemBadgeFrame numberBadgeFrame;
@property (nonatomic, assign) YPTabItemBadgeFrame dotBadgeFrame;
@property (nonatomic, assign) CGFloat itemContentHorizontalCenterVerticalOffset;
@property (nonatomic, assign) CGFloat itemContentHorizontalCenterSpacing;
@end

@implementation YPTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    _selectedItemIndex = -1;
    _itemTitleColor = [UIColor whiteColor];
    _itemTitleSelectedColor = [UIColor blackColor];
    _itemTitleFont = [UIFont systemFontOfSize:10];
    _itemSelectedBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _itemContentHorizontalCenter = YES;
    _itemFontChangeFollowContentScroll = NO;
    _itemColorChangeFollowContentScroll = YES;
    _itemSelectedBgScrollFollowContent = YES;
    
    _badgeTitleColor = [UIColor whiteColor];
    _badgeTitleFont = [UIFont systemFontOfSize:13];
    _badgeBackgroundColor = BADGE_BG_COLOR_DEFAULT;
    
    _numberBadgeFrame = YPTabItemBadgeFrameMake(2, 20, 16);
    _dotBadgeFrame = YPTabItemBadgeFrameMake(5, 25, 10);
    
    
    
    self.clipsToBounds = YES;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateItemsFrame];
}

- (void)setItems:(NSArray *)items {
    _items = [items copy];
    for (YPTabItem *item in self.items) {
        item.titleColor = self.itemTitleColor;
        item.titleSelectedColor = self.itemTitleSelectedColor;
        item.titleFont = self.itemTitleFont;
        
        [item setContentHorizontalCenterWithVerticalOffset:5 spacing:5];

        item.badgeTitleFont = self.badgeTitleFont;
        item.badgeTitleColor = self.badgeTitleColor;
        item.badgeBackgroundColor = self.badgeBackgroundColor;
        item.badgeBackgroundImage = self.badgeBackgroundImage;
        [item setBadgeMarginTop:self.numberBadgeFrame.top
                    marginRight:self.numberBadgeFrame.right
                         height:self.numberBadgeFrame.height
                       forStyle:YPTabItemBadgeStyleNumber];
        [item setBadgeMarginTop:self.dotBadgeFrame.top
                    marginRight:self.dotBadgeFrame.right
                         height:self.dotBadgeFrame.height
                       forStyle:YPTabItemBadgeStyleDot];
        [item addTarget:self action:@selector(tabItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self updateItemsFrame];
}

- (void)setTitles:(NSArray *)titles {
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *title in titles) {
        YPTabItem *item = [[YPTabItem alloc] init];
        item.title = title;
        [items addObject:item];
    }
    self.items = items;
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    NSLog(@"index--->%ld", (long)selectedItemIndex);
    if (self.items.count == 0 || selectedItemIndex < 0 || selectedItemIndex >= self.items.count) {
        return;
    }
    
    if (_selectedItemIndex >= 0) {
        YPTabItem *oldSelectedItem = self.items[_selectedItemIndex];
        oldSelectedItem.selected = NO;
        if (self.itemFontChangeFollowContentScroll) {
            oldSelectedItem.transform = CGAffineTransformMakeScale(self.itemTitleUnselectedFontScale,
                                                                   self.itemTitleUnselectedFontScale);
        } else {
            oldSelectedItem.titleFont = self.itemTitleFont;
        }
    }
    
    YPTabItem *newSelectedItem = self.items[selectedItemIndex];
    newSelectedItem.selected = YES;
    if (self.itemFontChangeFollowContentScroll) {
        newSelectedItem.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        if (self.itemTitleSelectedFont) {
            newSelectedItem.titleFont = self.itemTitleSelectedFont;
        }
    }
    
    if (self.itemSelectedBgScrollFollowContent) {
        if (_selectedItemIndex == -1) {
            [self updateFrameOfSelectedBgWithIndex:selectedItemIndex];
        }
    } else {
        if (self.itemSelectedBgSwitchAnimated) {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 [self updateFrameOfSelectedBgWithIndex:selectedItemIndex];
                             }];
        } else {
            [self updateFrameOfSelectedBgWithIndex:selectedItemIndex];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:didSelectedItemAtIndex:)]) {
        [self.delegate yp_tabBar:self didSelectedItemAtIndex:selectedItemIndex];
    }
    _selectedItemIndex = selectedItemIndex;
    [self setSelectedItemCenter];
}

- (void)updateFrameOfSelectedBgWithIndex:(NSInteger)index {
    YPTabItem *item = self.items[index];
    CGFloat width = item.frameWithOutTransform.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right;
    CGFloat height = item.frameWithOutTransform.size.height - self.itemSelectedBgInsets.top - self.itemSelectedBgInsets.bottom;
    self.itemSelectedBgImageView.frame = CGRectMake(item.frameWithOutTransform.origin.x + self.itemSelectedBgInsets.left,
                                                    item.frameWithOutTransform.origin.y + self.itemSelectedBgInsets.top,
                                                    width,
                                                    height);
}

- (YPTabItem *)selectedItem {
    if (self.selectedItemIndex < 0) {
        return nil;
    }
    return self.items[self.selectedItemIndex];
}

- (void)tabItemClicked:(YPTabItem *)item {
    NSLog(@"index--->%d", item.index);
    if (self.selectedItemIndex == item.index) {
        return;
    }
    BOOL will = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:willSelectItemAtIndex:)]) {
        will = [self.delegate yp_tabBar:self willSelectItemAtIndex:item.index];
    }
    if (will) {
        self.selectedItemIndex = item.index;
    }
}

- (void)updateItemsFrame {
    if (self.items.count == 0) {
        return;
    }
    
    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemSelectedBgImageView removeFromSuperview];
    if (self.itemFitTextWidth || self.itemWidth > 0) {
        [self.scrollView addSubview:self.itemSelectedBgImageView];
        CGFloat x = 0;
        for (int i = 0; i < self.items.count; i++) {
            YPTabItem *item = self.items[i];
            CGFloat width = 0;
            if (self.itemWidth > 0) {
                width = self.itemWidth;
            }
            if (self.itemFitTextWidth) {
                CGSize size = [item.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                  attributes:@{NSFontAttributeName : self.itemTitleFont}
                                                     context:nil].size;
                NSLog(@"size-->%f", size.width);
                width = ceilf(size.width) + self.itemFitTextWidthSpacing;
            }
            
            item.frame = CGRectMake(x, 0, width, self.frame.size.height);
            item.index = i;
            x += width;
            [self.scrollView addSubview:item];
        }
        self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.size.height);
    } else {
        [self addSubview:self.itemSelectedBgImageView];
        CGFloat x = 0;
        CGFloat itemWidth = self.frame.size.width / self.items.count;
        for (int i = 0; i < self.items.count; i++) {
            YPTabItem *item = self.items[i];
            item.frame = CGRectMake(x, 0, itemWidth, self.frame.size.height);
            item.index = i;
            
            x += itemWidth;
            [self addSubview:item];
            item.clipsToBounds = YES;
        }
    }
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets switchAnimated:(BOOL)animated{
    self.itemSelectedBgInsets = insets;
    self.itemSelectedBgSwitchAnimated = animated;
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)itemSelectedBgInsets {
    _itemSelectedBgInsets = itemSelectedBgInsets;
    if (self.items.count > 0 && self.selectedItemIndex >= 0) {
        [self updateFrameOfSelectedBgWithIndex:self.selectedItemIndex];
    }
}

- (void)setScrollEnabledAndItemWidth:(CGFloat)width {
    self.itemWidth = width;
    self.itemFitTextWidth = NO;
    [self updateItemsFrame];
}

- (void)setScrollEnabledAndItemFitTextWidthWithSpacing:(CGFloat)spacing {
    self.itemFitTextWidth = YES;
    self.itemFitTextWidthSpacing = spacing;
    self.itemWidth = 0;
    [self updateItemsFrame];
}


- (void)setSelectedItemCenter {
    if (!self.scrollView) {
        return;
    }
    // 修改偏移量
    CGFloat offsetX = self.selectedItem.center.x - self.scrollView.frame.size.width * 0.5f;
    
    // 处理最小滚动偏移量
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 处理最大滚动偏移量
    CGFloat maxOffsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}
- (CGFloat)itemTitleUnselectedFontScale {
    if (_itemTitleSelectedFont) {
        return self.itemTitleFont.pointSize / _itemTitleSelectedFont.pointSize;
    }
    return 1.0f;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

#pragma mark - ItemTitle
- (void)setItemTitleColor:(UIColor *)itemTitleColor {
    _itemTitleColor = itemTitleColor;
    [self.items makeObjectsPerformSelector:@selector(setTitleColor:) withObject:itemTitleColor];
}

- (void)setItemTitleSelectedColor:(UIColor *)itemTitleSelectedColor {
    _itemTitleSelectedColor = itemTitleSelectedColor;
    [self.items makeObjectsPerformSelector:@selector(setTitleSelectedColor:) withObject:itemTitleSelectedColor];
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    [self.items makeObjectsPerformSelector:@selector(setTitleFont:) withObject:itemTitleFont];
}

- (void)setItemTitleSelectedFont:(UIFont *)itemTitleSelectedFont {
    _itemTitleSelectedFont = itemTitleSelectedFont;
    if (itemTitleSelectedFont && itemTitleSelectedFont.pointSize != self.itemTitleFont.pointSize) {
        self.itemFontChangeFollowContentScroll = YES;
        [self.items makeObjectsPerformSelector:@selector(setTitleFont:) withObject:itemTitleSelectedFont];
        for (YPTabItem *item in self.items) {
            if (!item.selected) {
                item.transform = CGAffineTransformMakeScale(self.itemTitleUnselectedFontScale,
                                                            self.itemTitleUnselectedFontScale);
            }
        }
    }
}

#pragma mark - ItemContent

- (void)setItemContentHorizontalCenter:(BOOL)itemContentHorizontalCenter {
    _itemContentHorizontalCenter = itemContentHorizontalCenter;
    for (YPTabItem *item in self.items) {
        if (itemContentHorizontalCenter) {
            [item setContentHorizontalCenterWithVerticalOffset:5 spacing:5];
        } else {
            item.contentHorizontalCenter = NO;
        }
    }
}

- (void)setItemContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                                 spacing:(CGFloat)spacing {
    _itemContentHorizontalCenter = YES;
    self.itemContentHorizontalCenterVerticalOffset = verticalOffset;
    self.itemContentHorizontalCenterSpacing = spacing;
    for (YPTabItem *item in self.items) {
        [item setContentHorizontalCenterWithVerticalOffset:verticalOffset spacing:spacing];
    }
}

#pragma mark - Badge
- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    _badgeBackgroundColor = badgeBackgroundColor;
    [self.items makeObjectsPerformSelector:@selector(setBadgeBackgroundColor:) withObject:badgeBackgroundColor];
}

- (void)setBadgeBackgroundImage:(UIImage *)badgeBackgroundImage {
    _badgeBackgroundImage = badgeBackgroundImage;
    [self.items makeObjectsPerformSelector:@selector(setBadgeBackgroundImage:) withObject:badgeBackgroundImage];
}

- (void)setBadgeTitleColor:(UIColor *)badgeTitleColor {
    _badgeTitleColor = badgeTitleColor;
    [self.items makeObjectsPerformSelector:@selector(setBadgeTitleColor:) withObject:badgeTitleColor];
}

- (void)setBadgeTitleFont:(UIFont *)badgeTitleFont {
    _badgeTitleFont = badgeTitleFont;
    [self.items makeObjectsPerformSelector:@selector(setBadgeTitleFont:) withObject:badgeTitleFont];
}


- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle {
    YPTabItemBadgeFrame frame = YPTabItemBadgeFrameMake(marginTop, marginRight, height);
    if (badgeStyle == YPTabItemBadgeStyleNumber) {
        self.numberBadgeFrame = frame;
    } else if (badgeStyle == YPTabItemBadgeStyleDot) {
        self.dotBadgeFrame = frame;
    }
    
    for (YPTabItem *item in self.items) {
        [item setBadgeMarginTop:marginTop
                    marginRight:marginRight
                         height:height
                       forStyle:badgeStyle];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
    YPTabItem *leftItem = self.items[leftIndex];
    YPTabItem *rightItem;
    if (rightIndex < self.items.count) {
        rightItem = self.items[rightIndex];
    }
    
    // 计算右边按钮偏移量
    CGFloat rightScale = offsetX / scrollViewWidth;
    // 只想要 0~1
    rightScale = rightScale - leftIndex;
    CGFloat leftScale = 1 - rightScale;
    
    if (scrollView.isDragging || scrollView.isDecelerating) {
        if (self.itemFontChangeFollowContentScroll && self.itemTitleUnselectedFontScale != 1.0f) {
            CGFloat diff = self.itemTitleUnselectedFontScale - 1;
            leftItem.transform = CGAffineTransformMakeScale(rightScale * diff + 1, rightScale * diff + 1);
            rightItem.transform = CGAffineTransformMakeScale(leftScale * diff + 1, leftScale * diff + 1);
        }
        
        if (self.itemColorChangeFollowContentScroll) {
            static CGFloat normalRed, normalGreen, normalBlue;
            static CGFloat selectedRed, selectedGreen, selectedBlue;
            [self.itemTitleColor getRed:&normalRed green:&normalGreen blue:&normalBlue alpha:nil];
            [self.itemTitleSelectedColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:nil];
            // 获取选中和未选中状态的颜色差值
            CGFloat redDiff = selectedRed - normalRed;
            CGFloat greenDiff = selectedGreen - normalGreen;
            CGFloat blueDiff = selectedBlue - normalBlue;
            // 根据颜色值的差和偏移量，设置tabItem的标题颜色
            leftItem.titleLabel.textColor = [UIColor colorWithRed:leftScale * redDiff + normalRed
                                                            green:leftScale * greenDiff + normalGreen
                                                             blue:leftScale * blueDiff + normalBlue
                                                            alpha:1];
            rightItem.titleLabel.textColor = [UIColor colorWithRed:rightScale * redDiff + normalRed
                                                             green:rightScale * greenDiff + normalGreen
                                                              blue:rightScale * blueDiff + normalBlue
                                                             alpha:1];
        }
    }
    
    if (self.itemSelectedBgScrollFollowContent) {
        CGRect frame = self.itemSelectedBgImageView.frame;
        CGFloat xDiff = rightItem.frameWithOutTransform.origin.x - leftItem.frameWithOutTransform.origin.x;
        frame.origin.x = rightScale * xDiff + leftItem.frameWithOutTransform.origin.x + self.itemSelectedBgInsets.left;
        
        CGFloat widthDiff = rightItem.frameWithOutTransform.size.width - leftItem.frameWithOutTransform.size.width;
        if (widthDiff != 0) {
            CGFloat leftSelectedBgWidth = leftItem.frameWithOutTransform.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right;
            frame.size.width = rightScale * widthDiff + leftSelectedBgWidth;
        }
        
        self.itemSelectedBgImageView.frame = frame;
    }
}
@end
