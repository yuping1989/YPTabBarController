//
//  YPTabBar.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBar.h"

@interface YPTabBar ()
{
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIImageView *itemSelectedBgImageView;
@property (nonatomic, assign) UIEdgeInsets itemSelectedBgInsets;
@end
@implementation YPTabBar
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    _selectedItemIndex = -1;
    _itemTitleColor = [UIColor whiteColor];
    _itemSelectedTitleColor = [UIColor blackColor];
    _itemTitleFont = [UIFont systemFontOfSize:10];
    self.itemSelectedBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.itemContentHorizontalCenter = YES;
    [self insertSubview:_itemSelectedBgImageView atIndex:0];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateItemsFrame];
}

- (void)setItems:(NSArray *)items {
    for (YPTabItem *item in _items) {
        [item removeFromSuperview];
    }
    _items = items;
    for (YPTabItem *item in _items) {
        [item setTitleColor:_itemTitleColor forState:UIControlStateNormal];
        [item setTitleColor:_itemSelectedTitleColor forState:UIControlStateSelected];
        if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
            item.titleLabel.font = _itemTitleFont;
        }
        [self addSubview:item];
    }
    [self updateItemsFrame];
}

- (void)setTitles:(NSArray *)titles {
    for (YPTabItem *item in _items) {
        [item removeFromSuperview];
    }
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *title in titles) {
        YPTabItem *item = [YPTabItem instance];
        [item setTitle:title forState:UIControlStateNormal];
        [item setTitleColor:_itemTitleColor forState:UIControlStateNormal];
        [item setTitleColor:_itemSelectedTitleColor forState:UIControlStateSelected];
        if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
            item.titleLabel.font = _itemTitleFont;
        }
        [items addObject:item];
        [self addSubview:item];
    }
    self.items = items;
}



- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
    if (self.items.count == 0) {
        return;
    }
    if (_itemSelectedBgImageView) {
        if (_itemSelectedBgSwitchAnimated && _selectedItemIndex >= 0 && !_itemSelectedBgScrollFollowContent) {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 [self changeSelectedBgWithIndex:selectedItemIndex];
                             }];
        } else {
            [self changeSelectedBgWithIndex:selectedItemIndex];
        }
    }
    for (YPTabItem *item in _items) {
        if (selectedItemIndex == item.index) {
            item.selected = YES;
            if (self.itemSelectedTitleFont) {
                item.titleLabel.font = self.itemSelectedTitleFont;
            }
        } else {
            if (item.selected) {
                item.selected = NO;
                if (self.itemSelectedTitleFont) {
                    item.titleLabel.font = self.itemTitleFont;
                }
            }
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(yp_tabBar:didSelectedItemAtIndex:)]) {
        [_delegate yp_tabBar:self didSelectedItemAtIndex:selectedItemIndex];
    }
    _selectedItemIndex = selectedItemIndex;
}


- (void)changeSelectedBgWithIndex:(NSInteger)index {
    YPTabItem *item = _items[index];
    _itemSelectedBgImageView.frame = CGRectMake(item.frame.origin.x + self.itemSelectedBgInsets.left,
                                                item.frame.origin.y + self.itemSelectedBgInsets.top,
                                                item.frame.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right,
                                                item.frame.size.height - self.itemSelectedBgInsets.top - self.itemSelectedBgInsets.bottom);
}

- (void)tabItemClicked:(YPTabItem *)item
{
    if (_selectedItemIndex == item.index) {
        return;
    }
    BOOL will = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(yp_tabBar:willSelectItemAtIndex:)]) {
        will = [_delegate yp_tabBar:self willSelectItemAtIndex:item.index];
    }
    if (will) {
        self.selectedItemIndex = item.index;
    }
}

- (void)updateItemsFrame {
    if (_items.count == 0) {
        return;
    }
    float x = 0;
    float width = self.frame.size.width / _items.count;
    for (int i = 0; i < _items.count; i++) {
        YPTabItem *item = _items[i];
        item.frame = CGRectMake(x, 0, width, self.frame.size.height);
        item.index = i;
        [item addTarget:self action:@selector(tabItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        x += width;
    }
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor
{
    _itemTitleColor = itemTitleColor;
    for (YPTabItem *item in _items) {
        [item setTitleColor:_itemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setItemSelectedTitleColor:(UIColor *)itemSelectedTitleColor
{
    _itemSelectedTitleColor = itemSelectedTitleColor;
    for (YPTabItem *item in _items) {
        [item setTitleColor:_itemSelectedTitleColor forState:UIControlStateSelected];
    }
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont
{
    _itemTitleFont = itemTitleFont;
    for (YPTabItem *item in _items) {
        item.titleLabel.font = itemTitleFont;
    }
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    _badgeBackgroundColor = badgeBackgroundColor;
    for (YPTabItem *item in _items) {
        item.badgeBackgroundColor = badgeBackgroundColor;
    }
}

- (void)setBadgeBackgroundImage:(UIImage *)badgeBackgroundImage {
    _badgeBackgroundImage = badgeBackgroundImage;
    for (YPTabItem *item in _items) {
        item.badgeBackgroundImage = badgeBackgroundImage;
    }
}

- (void)setBadgeTitleColor:(UIColor *)badgeTitleColor {
    _badgeTitleColor = badgeTitleColor;
    for (YPTabItem *item in _items) {
        item.badgeTitleColor = badgeTitleColor;
    }
}

- (void)setBadgeTitleFont:(UIFont *)badgeTitleFont {
    _badgeTitleFont = badgeTitleFont;
    for (YPTabItem *item in _items) {
        item.badgeTitleFont = badgeTitleFont;
    }
}


- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle {
    for (YPTabItem *item in _items) {
        [item setBadgeMarginTop:marginTop
                    marginRight:marginRight
                         height:height
                       forStyle:badgeStyle];
    }
}

- (void)setItemContentHorizontalCenter:(BOOL)itemContentHorizontalCenter {
    _itemContentHorizontalCenter = itemContentHorizontalCenter;
    for (YPTabItem *item in _items) {
        if (itemContentHorizontalCenter) {
            [item setContentHorizontalCenterWithMarginTop:5 spacing:5];
        } else {
            item.contentHorizontalCenter = NO;
        }
    }
}


- (void)setItemContentHorizontalCenterWithMarginTop:(float)marginTop
                                            spacing:(float)spacing {
    _itemContentHorizontalCenter = YES;
    for (YPTabItem *item in _items) {
        [item setContentHorizontalCenterWithMarginTop:marginTop spacing:spacing];
    }
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets switchAnimated:(BOOL)animated{
    self.itemSelectedBgInsets = insets;
    self.itemSelectedBgSwitchAnimated = animated;
}

- (void)setScrollEnabledWithItemWith:(float)width {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    if (_scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    [self addSubview:_scrollView];
    float x = 0;
    for (int i = 0; i < _items.count; i++) {
        YPTabItem *item = _items[i];
        item.frame = CGRectMake(x, 0, width, self.frame.size.height);
        item.index = i;
        [item addTarget:self action:@selector(tabItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:item];
        x += width;
    }
    _scrollView.contentSize = CGSizeMake(_items.count * width, _scrollView.frame.size.height);
}


@end
