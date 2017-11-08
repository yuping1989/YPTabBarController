//
//  YPTabItem.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Badge样式
 */
typedef NS_ENUM(NSInteger, YPTabItemBadgeStyle) {
    YPTabItemBadgeStyleNumber = 0, // 数字样式
    YPTabItemBadgeStyleDot = 1, // 小圆点
};

@interface YPTabItem : UIButton

/**
 *  item在tabBar中的index，此属性不能手动设置
 */
@property (nonatomic, assign) NSUInteger index;

/**
 *  用于记录tabItem在缩放前的frame，
 *  在YPTabBar的属性itemFontChangeFollowContentScroll == YES时会用到
 */
@property (nonatomic, assign, readonly) CGRect frameWithOutTransform;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, assign, readonly) CGFloat titleWidth;
@property (nonatomic, assign) UIEdgeInsets indicatorInsets;
@property (nonatomic, assign, readonly) CGRect indicatorFrame;

/**
 *  当badgeStyle == YPTabItemBadgeStyleNumber时，可以设置此属性，显示badge数值
 *  badge > 99，显示99+
 *  badge <= 99 && badge > -99，显示具体数值
 *  badge < -99，显示-99+
 */
@property (nonatomic, assign) NSInteger badge;

/**
 *  badge的样式，支持数字样式和小圆点
 */
@property (nonatomic, assign) YPTabItemBadgeStyle badgeStyle;

/**
 *  badge的背景颜色
 */
@property (nonatomic, strong) UIColor *badgeBackgroundColor;

/**
 *  badge的背景图片
 */
@property (nonatomic, strong) UIImage *badgeBackgroundImage;

/**
 *  badge的标题颜色
 */
@property (nonatomic, strong) UIColor *badgeTitleColor;

/**
 *  badge的标题字体，默认13号
 */
@property (nonatomic, strong) UIFont *badgeTitleFont;

/**
 *  设置Image和Title水平居中
 */
@property (nonatomic, assign, getter = isContentHorizontalCenter) BOOL contentHorizontalCenter;

/**
 *  设置Image和Title水平居中
 *
 *  @param verticalOffset   竖直方向的偏移量
 *  @param spacing          Image与Title的间距
 */
- (void)setContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                             spacing:(CGFloat)spacing;
/**
 *  添加双击事件回调
 */
- (void)setDoubleTapHandler:(void (^)(void))handler;

/**
 *  设置数字Badge的位置
 *
 *  @param marginTop            与TabItem顶部的距离
 *  @param centerMarginRight    中心与TabItem右侧的距离
 *  @param titleHorizonalSpace  标题水平方向的空间
 *  @param titleVerticalSpace   标题竖直方向的空间
 */
- (void)setNumberBadgeMarginTop:(CGFloat)marginTop
              centerMarginRight:(CGFloat)centerMarginRight
            titleHorizonalSpace:(CGFloat)titleHorizonalSpace
             titleVerticalSpace:(CGFloat)titleVerticalSpace;
/**
 *  设置小圆点Badge的位置
 *
 *  @param marginTop            与TabItem顶部的距离
 *  @param centerMarginRight    中心与TabItem右侧的距离
 *  @param sideLength           小圆点的边长
 */
- (void)setDotBadgeMarginTop:(CGFloat)marginTop
           centerMarginRight:(CGFloat)centerMarginRight
                  sideLength:(CGFloat)sideLength;

@end
