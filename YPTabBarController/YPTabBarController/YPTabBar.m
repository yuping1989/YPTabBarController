//
//  YPTabBar.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBar.h"
#import "YPTabItem.h"
@interface YPTabBar ()
{
}
@end
@implementation YPTabBar
- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedItemIndex = -1;
    }
    return self;
}
- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
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
        } else {
            if (item.selected) {
                item.selected = NO;
            }
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(yp_tabBar:didSelectItemAtIndex:)]) {
        [_delegate yp_tabBar:self didSelectItemAtIndex:selectedItemIndex];
    }
    _selectedItemIndex = selectedItemIndex;
}

- (void)setTitles:(NSArray *)titles {
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *title in titles) {
        YPTabItem *item = [YPTabItem instance];
        [item setTitle:title forState:UIControlStateNormal];
        [items addObject:item];
    }
    self.items = items;
}

- (void)changeSelectedBgWithIndex:(NSInteger)index {
    CGRect frame = _itemSelectedBgImageView.frame;
    YPTabItem *item = _items[index];
    frame.origin.x = item.frame.origin.x;
    frame.size.width = item.frame.size.width;
    _itemSelectedBgImageView.frame = frame;
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
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
        [self addSubview:item];
        x += width;
    }
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor
{
    _titleNormalColor = titleNormalColor;
    for (YPTabItem *item in _items) {
        [item setTitleColor:_titleNormalColor forState:UIControlStateNormal];
    }
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor
{
    _titleSelectedColor = titleSelectedColor;
    for (YPTabItem *item in _items) {
        [item setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
    }
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    for (YPTabItem *item in _items) {
        item.titleLabel.font = titleFont;
    }
}

- (void)setItemImageAndTitleCenterWithSpacing:(int)spacing
                                 marginTop:(float)marginTop
                                 imageSize:(CGSize)imageSize
{
    for (YPTabItem *item in _items) {
        [item setImageAndTitleCenterWithSpacing:spacing marginTop:marginTop imageSize:imageSize];
    }
}

- (void)setItemSelectedBgEnabledWithY:(float)y height:(float)height switchAnimated:(BOOL)animated{
    if (_itemSelectedBgImageView == nil) {
        self.itemSelectedBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 0, height)];
        [self insertSubview:_itemSelectedBgImageView atIndex:0];
    }
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
