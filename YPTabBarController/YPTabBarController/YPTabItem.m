//
//  YPTabItem.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabItem.h"
@interface YPTabItem ()
@property (nonatomic, strong) UIButton *badgeButton;
@property (nonatomic, strong) UIView *doubleTapView;
@end
@implementation YPTabItem
+ (YPTabItem *)instance
{
    YPTabItem *item = [YPTabItem buttonWithType:UIButtonTypeCustom];
    item.adjustsImageWhenHighlighted = NO;
    
    item.badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [item.badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    item.badgeButton.backgroundColor = [UIColor colorWithRed:252 / 255.0f green:15 / 255.0f blue:29 / 255.0f alpha:1.0f];
    item.badgeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    item.badgeButton.contentMode = UIViewContentModeCenter;
    item.badgeButton.userInteractionEnabled = NO;
    
    [item addSubview:item.badgeButton];
    return item;
}

- (void)setImageAndTitleCenterWithSpacing:(float)spacing
                             marginTop:(float)marginTop
                             imageSize:(CGSize)imageSize
{
    // get the size of the elements here for readability
//    CGSize imageSize = self.imageView.frame.size;
//    CGSize titleSize = self.titleLabel.frame.size;
    CGSize titleSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       attributes:@{NSFontAttributeName : self.titleLabel.font}
                                                          context:nil].size;
    titleSize = CGSizeMake(ceilf(titleSize.width), ceilf(titleSize.height));
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height - marginTop), 0, 0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(marginTop, - imageSize.width, - (totalHeight - titleSize.height), 0);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (_doubleTapView) {
        _doubleTapView.hidden = !selected;
    }
}
- (void)addDoubleTapTarget:(id)target action:(SEL)action
{
    if (self.doubleTapView == nil) {
        self.doubleTapView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_doubleTapView];
    }
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    doubleRecognizer.numberOfTapsRequired = 2;
    [_doubleTapView addGestureRecognizer:doubleRecognizer];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_doubleTapView) {
        _doubleTapView.frame = self.bounds;
    }
}

- (void)setBadge:(NSInteger)badge {
    _badge = badge;
    if (_badgeButton == nil) {
        _badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _badgeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _badgeButton.contentMode = UIViewContentModeCenter;
        _badgeButton.userInteractionEnabled = NO;
    }
    if (badge < 0) {
        _badgeButton.hidden = YES;
    } else if (badge == 0) {
        [_badgeButton setTitle:nil forState:UIControlStateNormal];
        _badgeButton.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame), 3, 10, 10);
        _badgeButton.layer.cornerRadius = _badgeButton.frame.size.height / 2;
    } else {
        _badgeButton.hidden = NO;
        NSString *badgeStr = @(badge).stringValue;
        if (badge > 99) {
            badgeStr = @"99+";
        }
        
        CGSize size = [badgeStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : _badgeButton.titleLabel.font}
                                                  context:nil].size;
        size = CGSizeMake(ceilf(size.width), ceilf(size.height));
        NSLog(@"size-->%@", NSStringFromCGSize(size));
        _badgeButton.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) - 5, 2, MAX(ceilf(size.width) + 8, size.height + 2), size.height + 2);
        NSLog(@"size-->%@", NSStringFromCGSize(_badgeButton.frame.size));
        _badgeButton.layer.cornerRadius = _badgeButton.frame.size.height / 2.0f;
        [_badgeButton setTitle:badgeStr forState:UIControlStateNormal];
    }
}
@end
