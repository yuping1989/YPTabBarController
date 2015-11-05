//
//  YPTabItem.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, YPTabItemBadgeStyle) {
    YPTabItemStyleNumber,
    YPTabItemStyleDot,
};


@interface YPTabItem : UIButton
+ (YPTabItem *)instance;

/**
 *  item在tabBar中的index
 */
@property (nonatomic, assign) NSInteger index;

/**
 *  badge > 99，显示99+
 *  badge < 99 && badge > 0，显示具体数值
 *  badge == 0，隐藏badge
 *  badge < 0，显示一个小圆点，即YPTabItemStyleDot
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

- (void)setImageAndTitleMarginTop:(CGFloat)marginTop
                          spacing:(CGFloat)spacing;
- (void)setImageAndTitleMarginTop:(CGFloat)marginTop
                          spacing:(CGFloat)spacing
                        imageSize:(CGSize)imageSize;
/**
 *  添加双击支持
 *
 *  @param target
 *  @param action
 */
- (void)addDoubleTapTarget:(id)target action:(SEL)action;

- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle;

@end
