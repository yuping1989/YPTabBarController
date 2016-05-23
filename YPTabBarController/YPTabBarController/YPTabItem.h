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
    YPTabItemBadgeStyleNumber, // 数字样式
    YPTabItemBadgeStyleDot, // 小圆点
};

struct YPTabItemBadgeFrame {
    CGFloat top;
    CGFloat right;
    CGFloat height;
};
typedef struct YPTabItemBadgeFrame YPTabItemBadgeFrame;
CG_INLINE YPTabItemBadgeFrame
YPTabItemBadgeFrameMake(CGFloat top, CGFloat right, CGFloat height) {
    YPTabItemBadgeFrame frame;
    frame.top = top;
    frame.right = right;
    frame.height = height;
    return frame;
}


@interface YPTabItem : UIButton

/**
 *  item在tabBar中的index
 */
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign, readonly) CGRect frameWithOutTransform;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;

/**
 *  badge > 99，显示99+
 *  badge <= 99 && badge > 0，显示具体数值
 *  badge == 0，隐藏badge
 *  badge < 0，显示一个小圆点，即YPTabItemBadgeStyleDot
 */
@property (nonatomic, assign) NSInteger badge;

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
 *  @param marginTop Image与顶部的距离
 *  @param spacing   Image与Title的间距
 */
- (void)setContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                             spacing:(CGFloat)spacing;
/**
 *  添加双击的target和action
 *
 *  @param target
 *  @param action
 */
- (void)addDoubleTapTarget:(id)target action:(SEL)action;

/**
 *  设置Badge的位置
 *
 *  @param marginTop   与TabItem顶部的距离
 *  @param marginRight 与TabItem右侧的距离
 *  @param height      Badge的高度，宽度为自适应
 *  @param badgeStyle  Badge样式，分为数字样式和小圆点样式
 */
- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle;

@end
