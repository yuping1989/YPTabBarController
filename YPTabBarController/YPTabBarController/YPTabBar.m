//
//  YPTabBar.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBar.h"

#define BADGE_BG_COLOR_DEFAULT [UIColor colorWithRed:252 / 255.0f green:15 / 255.0f blue:29 / 255.0f alpha:1.0f]

@interface YPTabBar ()

// 当TabBar支持滚动时，使用此scrollView
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) YPTabItem *specialItem;
@property (nonatomic, copy) void (^specialItemHandler)(YPTabItem *item);

// 选中背景
@property (nonatomic, strong) UIImageView *itemSelectedBgImageView;

// 选中背景相对于YPTabItem的insets
@property (nonatomic, assign) UIEdgeInsets itemSelectedBgInsets;

// TabItem选中切换时，是否显示动画
@property (nonatomic, assign) BOOL itemSelectedBgSwitchAnimated;

// Item是否匹配title的文字宽度
@property (nonatomic, assign) BOOL itemFitTextWidth;

// 当Item匹配title的文字宽度时，左右留出的空隙，item的宽度 = 文字宽度 + spacing
@property (nonatomic, assign) CGFloat itemFitTextWidthSpacing;

// item的宽度
@property (nonatomic, assign) CGFloat itemWidth;

// item的内容水平居中时，image与顶部的距离
@property (nonatomic, assign) CGFloat itemContentHorizontalCenterVerticalOffset;

// item的内容水平居中时，title与image的距离
@property (nonatomic, assign) CGFloat itemContentHorizontalCenterSpacing;

// 数字样式的badge相关属性
@property (nonatomic, assign) CGFloat numberBadgeMarginTop;
@property (nonatomic, assign) CGFloat numberBadgeCenterMarginRight;
@property (nonatomic, assign) CGFloat numberBadgeTitleHorizonalSpace;
@property (nonatomic, assign) CGFloat numberBadgeTitleVerticalSpace;

// 小圆点样式的badge相关属性
@property (nonatomic, assign) CGFloat dotBadgeMarginTop;
@property (nonatomic, assign) CGFloat dotBadgeCenterMarginRight;
@property (nonatomic, assign) CGFloat dotBadgeSideLength;

// 分割线相关属性
@property (nonatomic, strong) NSMutableArray *separatorLayers;
@property (nonatomic, strong) UIColor *itemSeparatorColor;
@property (nonatomic, assign) CGFloat itemSeparatorWidth;
@property (nonatomic, assign) CGFloat itemSeparatorMarginTop;
@property (nonatomic, assign) CGFloat itemSeparatorMarginBottom;

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
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    _selectedItemIndex = NSNotFound;
    _itemTitleColor = [UIColor whiteColor];
    _itemTitleSelectedColor = [UIColor blackColor];
    _itemTitleFont = [UIFont systemFontOfSize:10];
    _itemSelectedBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _itemContentHorizontalCenter = YES;
    _itemFontChangeFollowContentScroll = NO;
    _itemColorChangeFollowContentScroll = YES;
    _itemSelectedBgScrollFollowContent = NO;
    
    _badgeTitleColor = [UIColor whiteColor];
    _badgeTitleFont = [UIFont systemFontOfSize:13];
    _badgeBackgroundColor = BADGE_BG_COLOR_DEFAULT;
    
    _numberBadgeMarginTop = 2;
    _numberBadgeCenterMarginRight = 30;
    _numberBadgeTitleHorizonalSpace = 8;
    _numberBadgeTitleVerticalSpace = 2;
    
    _dotBadgeMarginTop = 5;
    _dotBadgeCenterMarginRight = 25;
    _dotBadgeSideLength = 10;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // 更新items的frame
    [self updateItemsFrame];
    
    // 更新选中背景的frame
    [self updateSelectedBgFrameWithIndex:self.selectedItemIndex];
    
    // 更新分割线
    [self updateSeperators];
    
    if (self.scrollView) {
        self.scrollView.frame = self.bounds;
    }
}

- (void)setItems:(NSArray *)items {
    _selectedItemIndex = NSNotFound;
    [self updateSelectedBgFrameWithIndex:self.selectedItemIndex];
    
    // 将老的item从superview上删除
    [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _items = [items copy];
    
    // 初始化每一个item
    for (YPTabItem *item in self.items) {
        item.titleColor = self.itemTitleColor;
        item.titleSelectedColor = self.itemTitleSelectedColor;
        item.titleFont = self.itemTitleFont;
        
        [item setContentHorizontalCenterWithVerticalOffset:5 spacing:5];

        item.badgeTitleFont = self.badgeTitleFont;
        item.badgeTitleColor = self.badgeTitleColor;
        item.badgeBackgroundColor = self.badgeBackgroundColor;
        item.badgeBackgroundImage = self.badgeBackgroundImage;
        
        [item setNumberBadgeMarginTop:self.numberBadgeMarginTop
                    centerMarginRight:self.numberBadgeCenterMarginRight
                  titleHorizonalSpace:self.numberBadgeTitleHorizonalSpace
                   titleVerticalSpace:self.numberBadgeTitleVerticalSpace];
        [item setDotBadgeMarginTop:self.dotBadgeMarginTop
                 centerMarginRight:self.dotBadgeCenterMarginRight
                        sideLength:self.dotBadgeSideLength];
        
        [item addTarget:self action:@selector(tabItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    // 更新每个item的位置
    [self updateItemsFrame];
    
    // 更新item的大小缩放
    [self updateItemsScaleIfNeeded];
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

- (void)setleftAndRightSpacing:(CGFloat)leftAndRightSpacing {
    _leftAndRightSpacing = leftAndRightSpacing;
    [self updateItemsFrame];
}

- (void)updateItemsFrame {
    if (self.items.count == 0) {
        return;
    }
    // 将item从superview上删除
    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 将item的选中背景从superview上删除
    [self.itemSelectedBgImageView removeFromSuperview];
    if (self.scrollView) {
        // 支持滚动
        
        [self.scrollView addSubview:self.itemSelectedBgImageView];
        CGFloat x = self.leftAndRightSpacing;
        for (NSUInteger index = 0; index < self.items.count; index++) {
            YPTabItem *item = self.items[index];
            CGFloat width = 0;
            // item的宽度为一个固定值
            if (self.itemWidth > 0) {
                width = self.itemWidth;
            }
            // item的宽度为根据字体大小和spacing进行适配
            if (self.itemFitTextWidth) {
                CGSize size = [item.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName : self.itemTitleFont}
                                                       context:nil].size;
                width = ceilf(size.width) + self.itemFitTextWidthSpacing;
            }
            
            item.frame = CGRectMake(x, 0, width, self.frame.size.height);
            item.index = index;
            x += width;
            [self.scrollView addSubview:item];
        }
        self.scrollView.contentSize = CGSizeMake(MAX(x + self.leftAndRightSpacing, self.scrollView.frame.size.width),
                                                 self.scrollView.frame.size.height);
    } else {
        // 不支持滚动
        
        [self addSubview:self.itemSelectedBgImageView];
        CGFloat x = self.leftAndRightSpacing;
        CGFloat allItemsWidth = self.frame.size.width - self.leftAndRightSpacing * 2;
        if (self.specialItem && self.specialItem.frame.size.width != 0) {
            self.itemWidth = (allItemsWidth - self.specialItem.frame.size.width) / self.items.count;
        } else {
            self.itemWidth = allItemsWidth / self.items.count;
        }
        
        // 四舍五入，取整，防止字体模糊
        self.itemWidth = floorf(self.itemWidth + 0.5f);

        for (NSUInteger index = 0; index < self.items.count; index++) {
            YPTabItem *item = self.items[index];
            if (index == self.items.count - 1) {
                self.itemWidth = self.frame.size.width - x;
            }
            item.frame = CGRectMake(x, 0, self.itemWidth, self.frame.size.height);
            item.index = index;
            
            x += self.itemWidth;
            [self addSubview:item];
            
            // 如果有特殊的单独item，设置其位置
            if (self.specialItem && self.specialItem.index == index) {
                CGFloat width = self.specialItem.frame.size.width;
                // 如果宽度为0，将其宽度设置为itemWidth
                if (width == 0) {
                    width = self.itemWidth;
                }
                CGFloat height = self.specialItem.frame.size.height;
                // 如果高度为0，将其宽度设置为tabBar的高度
                if (height == 0) {
                    height = self.frame.size.height;
                }
                self.specialItem.frame = CGRectMake(x, self.frame.size.height - height, width, height);
                x += width;
            }
        }
    }
}

- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex {
    if (selectedItemIndex == _selectedItemIndex ||
        selectedItemIndex >= self.items.count ||
        self.items.count == 0) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:shouldSelectItemAtIndex:)]) {
        BOOL should = [self.delegate yp_tabBar:self shouldSelectItemAtIndex:selectedItemIndex];
        if (!should) {
            return;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:willSelectItemAtIndex:)]) {
        [self.delegate yp_tabBar:self willSelectItemAtIndex:selectedItemIndex];
    }
    
    if (_selectedItemIndex != NSNotFound) {
        YPTabItem *oldSelectedItem = self.items[_selectedItemIndex];
        oldSelectedItem.selected = NO;
        if (self.itemFontChangeFollowContentScroll) {
            // 如果支持字体平滑渐变切换，则设置item的scale
            oldSelectedItem.transform = CGAffineTransformMakeScale(self.itemTitleUnselectedFontScale,
                                                                   self.itemTitleUnselectedFontScale);
        } else {
            // 如果支持字体平滑渐变切换，则直接设置字体
            oldSelectedItem.titleFont = self.itemTitleFont;
        }
    }
    
    YPTabItem *newSelectedItem = self.items[selectedItemIndex];
    newSelectedItem.selected = YES;
    if (self.itemFontChangeFollowContentScroll) {
        // 如果支持字体平滑渐变切换，则设置item的scale
        newSelectedItem.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        // 如果支持字体平滑渐变切换，则直接设置字体
        if (self.itemTitleSelectedFont) {
            newSelectedItem.titleFont = self.itemTitleSelectedFont;
        }
    }
    
    if (self.itemSelectedBgSwitchAnimated && _selectedItemIndex != NSNotFound) {
        [UIView animateWithDuration:0.25f animations:^{
            [self updateSelectedBgFrameWithIndex:selectedItemIndex];
        }];
    } else {
        [self updateSelectedBgFrameWithIndex:selectedItemIndex];
    }

    _selectedItemIndex = selectedItemIndex;
    
    // 如果tabbar支持滚动，将选中的item放到tabbar的中央
    [self setSelectedItemCenter];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:didSelectedItemAtIndex:)]) {
        [self.delegate yp_tabBar:self didSelectedItemAtIndex:selectedItemIndex];
    }
}

/**
 *  更新选中背景的frame
 */
- (void)updateSelectedBgFrameWithIndex:(NSUInteger)index {
    if (index == NSNotFound) {
        self.itemSelectedBgImageView.frame = CGRectZero;
        return;
    }
    YPTabItem *item = self.items[index];
    CGFloat width = item.frameWithOutTransform.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right;
    CGFloat height = item.frameWithOutTransform.size.height - self.itemSelectedBgInsets.top - self.itemSelectedBgInsets.bottom;
    self.itemSelectedBgImageView.frame = CGRectMake(item.frameWithOutTransform.origin.x + self.itemSelectedBgInsets.left,
                                                    item.frameWithOutTransform.origin.y + self.itemSelectedBgInsets.top,
                                                    width,
                                                    height);
}

- (void)setScrollEnabledAndItemWidth:(CGFloat)width {
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
    }
    self.itemWidth = width;
    self.itemFitTextWidth = NO;
    self.itemFitTextWidthSpacing = 0;
    [self updateItemsFrame];
}

- (void)setScrollEnabledAndItemFitTextWidthWithSpacing:(CGFloat)spacing {
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
    }
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


/**
 *  获取未选中字体与选中字体大小的比例
 */
- (CGFloat)itemTitleUnselectedFontScale {
    if (_itemTitleSelectedFont) {
        return self.itemTitleFont.pointSize / _itemTitleSelectedFont.pointSize;
    }
    return 1.0f;
}

- (void)tabItemClicked:(YPTabItem *)item {
    self.selectedItemIndex = item.index;
}

- (void)specialItemClicked:(YPTabItem *)item {
    if (self.specialItemHandler) {
        self.specialItemHandler(item);
    }
}

- (YPTabItem *)selectedItem {
    if (self.selectedItemIndex == NSNotFound) {
        return nil;
    }
    return self.items[self.selectedItemIndex];
}

- (void)setSpecialItem:(YPTabItem *)item afterItemWithIndex:(NSUInteger)index tapHandler:(void (^)(YPTabItem *item))handler {
    self.specialItem = item;
    self.specialItem.index = index;
    [self.specialItem addTarget:self action:@selector(specialItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:item];
    [self updateItemsFrame];
    
    self.specialItemHandler = handler;
}

#pragma mark - ItemSelectedBg

- (void)setItemSelectedBgColor:(UIColor *)itemSelectedBgColor {
    _itemSelectedBgColor = itemSelectedBgColor;
    self.itemSelectedBgImageView.backgroundColor = itemSelectedBgColor;
}

- (void)setItemSelectedBgImage:(UIImage *)itemSelectedBgImage {
    _itemSelectedBgImage = itemSelectedBgImage;
    self.itemSelectedBgImageView.image = itemSelectedBgImage;
}

- (void)setItemSelectedBgCornerRadius:(CGFloat)itemSelectedBgCornerRadius {
    _itemSelectedBgCornerRadius = itemSelectedBgCornerRadius;
    self.itemSelectedBgImageView.clipsToBounds = YES;
    self.itemSelectedBgImageView.layer.cornerRadius = itemSelectedBgCornerRadius;
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets
              tapSwitchAnimated:(BOOL)animated{
    self.itemSelectedBgInsets = insets;
    self.itemSelectedBgSwitchAnimated = animated;
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)itemSelectedBgInsets {
    _itemSelectedBgInsets = itemSelectedBgInsets;
    if (self.items.count > 0 && self.selectedItemIndex != NSNotFound) {
        [self updateSelectedBgFrameWithIndex:self.selectedItemIndex];
    }
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
    if (self.itemFontChangeFollowContentScroll) {
        // item字体支持平滑切换，更新每个item的scale
        [self updateItemsScaleIfNeeded];
    } else {
        // item字体不支持平滑切换，更新item的字体
        if (self.itemTitleSelectedFont) {
            // 设置了选中字体，则只更新未选中的item
            for (YPTabItem *item in self.items) {
                if (!item.selected) {
                    [item setTitleFont:itemTitleFont];
                }
            }
        } else {
            // 未设置选中字体，更新所有item
            [self.items makeObjectsPerformSelector:@selector(setTitleFont:) withObject:itemTitleFont];
        }
    }
    if (self.itemFitTextWidth) {
        // 如果item的宽度是匹配文字的，更新item的位置
        [self updateItemsFrame];
    }
}

- (void)setItemTitleSelectedFont:(UIFont *)itemTitleSelectedFont {
    _itemTitleSelectedFont = itemTitleSelectedFont;
    self.selectedItem.titleFont = itemTitleSelectedFont;
    [self updateItemsScaleIfNeeded];
}

- (void)setItemFontChangeFollowContentScroll:(BOOL)itemFontChangeFollowContentScroll {
    _itemFontChangeFollowContentScroll = itemFontChangeFollowContentScroll;
    [self updateItemsScaleIfNeeded];
}

- (void)updateItemsScaleIfNeeded {
    if (self.itemTitleSelectedFont &&
        self.itemFontChangeFollowContentScroll &&
        self.itemTitleSelectedFont.pointSize != self.itemTitleFont.pointSize) {
        [self.items makeObjectsPerformSelector:@selector(setTitleFont:) withObject:self.itemTitleSelectedFont];
        for (YPTabItem *item in self.items) {
            if (!item.selected) {
                item.transform = CGAffineTransformMakeScale(self.itemTitleUnselectedFontScale,
                                                            self.itemTitleUnselectedFontScale);
            }
        }
    }
}

#pragma mark - Item Content

- (void)setItemContentHorizontalCenter:(BOOL)itemContentHorizontalCenter {
    _itemContentHorizontalCenter = itemContentHorizontalCenter;
    if (itemContentHorizontalCenter) {
        [self setItemContentHorizontalCenterWithVerticalOffset:5 spacing:5];
    } else {
        self.itemContentHorizontalCenterVerticalOffset = 0;
        self.itemContentHorizontalCenterSpacing = 0;
        [self.items makeObjectsPerformSelector:@selector(setContentHorizontalCenter:) withObject:@(NO)];
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

- (void)setNumberBadgeMarginTop:(CGFloat)marginTop
              centerMarginRight:(CGFloat)centerMarginRight
            titleHorizonalSpace:(CGFloat)titleHorizonalSpace
             titleVerticalSpace:(CGFloat)titleVerticalSpace {
    self.numberBadgeMarginTop = marginTop;
    self.numberBadgeCenterMarginRight = centerMarginRight;
    self.numberBadgeTitleHorizonalSpace = titleHorizonalSpace;
    self.numberBadgeTitleVerticalSpace = titleVerticalSpace;
    
    for (YPTabItem *item in self.items) {
        [item setNumberBadgeMarginTop:marginTop
                    centerMarginRight:centerMarginRight
                  titleHorizonalSpace:titleHorizonalSpace
                   titleVerticalSpace:titleVerticalSpace];
    }
}

- (void)setDotBadgeMarginTop:(CGFloat)marginTop
           centerMarginRight:(CGFloat)centerMarginRight
                  sideLength:(CGFloat)sideLength {
    self.dotBadgeMarginTop = marginTop;
    self.dotBadgeCenterMarginRight = centerMarginRight;
    self.dotBadgeSideLength = sideLength;
    
    for (YPTabItem *item in self.items) {
        [item setDotBadgeMarginTop:marginTop
                 centerMarginRight:centerMarginRight
                        sideLength:sideLength];
    }
}

#pragma mark - Separator

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                        width:(CGFloat)width
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom {
    self.itemSeparatorColor = itemSeparatorColor;
    self.itemSeparatorWidth = width;
    self.itemSeparatorMarginTop = marginTop;
    self.itemSeparatorMarginBottom = marginBottom;
    [self updateSeperators];
}

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom {
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat onePixel;
    if ([mainScreen respondsToSelector:@selector(nativeScale)]) {
        onePixel = 1.0f / mainScreen.nativeScale;
    } else {
        onePixel = 1.0f / mainScreen.scale;
    }
    [self setItemSeparatorColor:itemSeparatorColor
                          width:onePixel
                      marginTop:marginTop
                   marginBottom:marginBottom];
}

- (void)updateSeperators {
    if (self.itemSeparatorColor) {
        if (!self.separatorLayers) {
            self.separatorLayers = [[NSMutableArray alloc] init];
        }
        [self.separatorLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.separatorLayers removeAllObjects];
        [self.items enumerateObjectsUsingBlock:^(YPTabItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx > 0) {
                CALayer *layer = [[CALayer alloc] init];
                layer.backgroundColor = self.itemSeparatorColor.CGColor;
                layer.frame = CGRectMake(item.frame.origin.x - self.itemSeparatorWidth / 2,
                                         self.itemSeparatorMarginTop,
                                         self.itemSeparatorWidth,
                                         self.bounds.size.height - self.itemSeparatorMarginTop - self.itemSeparatorMarginBottom);
                [self.layer addSublayer:layer];
                [self.separatorLayers addObject:layer];
            }
        }];
    } else {
        [self.separatorLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.separatorLayers removeAllObjects];
        self.separatorLayers = nil;
    }
}

#pragma mark - Others

- (void)updateSubViewsWhenParentScrollViewScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    
    NSUInteger leftIndex = offsetX / scrollViewWidth;
    NSUInteger rightIndex = leftIndex + 1;
    
    YPTabItem *leftItem = self.items[leftIndex];
    YPTabItem *rightItem = nil;
    if (rightIndex < self.items.count) {
        rightItem = self.items[rightIndex];
    }
    
    // 计算右边按钮偏移量
    CGFloat rightScale = offsetX / scrollViewWidth;
    // 只想要 0~1
    rightScale = rightScale - leftIndex;
    CGFloat leftScale = 1 - rightScale;
    
    if (self.itemFontChangeFollowContentScroll && self.itemTitleUnselectedFontScale != 1.0f) {
        // 如果支持title大小跟随content的拖动进行变化，并且未选中字体和已选中字体的大小不一致
        
        // 计算字体大小的差值
        CGFloat diff = self.itemTitleUnselectedFontScale - 1;
        // 根据偏移量和差值，计算缩放值
        leftItem.transform = CGAffineTransformMakeScale(rightScale * diff + 1, rightScale * diff + 1);
        rightItem.transform = CGAffineTransformMakeScale(leftScale * diff + 1, leftScale * diff + 1);
    }
    
    if (self.itemColorChangeFollowContentScroll) {
        CGFloat normalRed, normalGreen, normalBlue, normalAlpha;
        CGFloat selectedRed, selectedGreen, selectedBlue, selectedAlpha;
        
        [self.itemTitleColor getRed:&normalRed green:&normalGreen blue:&normalBlue alpha:&normalAlpha];
        [self.itemTitleSelectedColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:&selectedAlpha];
        // 获取选中和未选中状态的颜色差值
        CGFloat redDiff = selectedRed - normalRed;
        CGFloat greenDiff = selectedGreen - normalGreen;
        CGFloat blueDiff = selectedBlue - normalBlue;
        CGFloat alphaDiff = selectedAlpha - normalAlpha;
        // 根据颜色值的差值和偏移量，设置tabItem的标题颜色
        leftItem.titleLabel.textColor = [UIColor colorWithRed:leftScale * redDiff + normalRed
                                                        green:leftScale * greenDiff + normalGreen
                                                         blue:leftScale * blueDiff + normalBlue
                                                        alpha:leftScale * alphaDiff + normalAlpha];
        rightItem.titleLabel.textColor = [UIColor colorWithRed:rightScale * redDiff + normalRed
                                                         green:rightScale * greenDiff + normalGreen
                                                          blue:rightScale * blueDiff + normalBlue
                                                         alpha:rightScale * alphaDiff + normalAlpha];
    }
    
    // 计算背景的frame
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
