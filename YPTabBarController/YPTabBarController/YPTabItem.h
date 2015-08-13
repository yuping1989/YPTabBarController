//
//  YPTabItem.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPTabItem : UIButton
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger badge;

+ (YPTabItem *)instance;
/**
 *  将image和title设置为居中，并且调整其在竖直方向的位置
 *
 *  @param spacing   image和title的距离
 *  @param marginTop image与顶部的间距
 *  @param imageSize image的size
 */
- (void)setImageAndTitleCenterWithSpacing:(float)spacing
                                marginTop:(float)marginTop
                                imageSize:(CGSize)imageSize;
/**
 *  添加双击支持
 *
 *  @param target
 *  @param action
 */
- (void)addDoubleTapTarget:(id)target action:(SEL)action;
@end
