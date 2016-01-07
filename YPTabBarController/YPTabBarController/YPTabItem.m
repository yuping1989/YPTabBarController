//
//  YPTabItem.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabItem.h"
struct BadgeFrame {
    CGFloat top;
    CGFloat right;
    CGFloat height;
};
typedef struct BadgeFrame BadgeFrame;
CG_INLINE BadgeFrame
BadgeFrameMake(CGFloat top, CGFloat right, CGFloat height)
{
    BadgeFrame frame;
    frame.top = top;
    frame.right = right;
    frame.height = height;
    return frame;
}

@interface YPTabItem ()
@property (nonatomic, strong) UIButton *badgeButton;
@property (nonatomic, strong) UIView *doubleTapView;
@property (nonatomic, assign) BadgeFrame numberBadgeFrame;
@property (nonatomic, assign) BadgeFrame dotBadgeFrame;
@property (nonatomic, assign) CGFloat marginTop;
@property (nonatomic, assign) CGFloat spacing;
@end
@implementation YPTabItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        self.marginTop = 5;
        self.spacing = 5;
        self.contentHorizontalCenter = YES;
    }
    return self;
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    _badgeBackgroundColor = badgeBackgroundColor;
    self.badgeButton.backgroundColor = badgeBackgroundColor;
}

- (void)setBadgeTitleColor:(UIColor *)badgeTitleColor {
    _badgeTitleColor = badgeTitleColor;
    [self.badgeButton setTitleColor:badgeTitleColor forState:UIControlStateNormal];
}

- (void)setBadgeBackgroundImage:(UIImage *)badgeBackgroundImage {
    _badgeBackgroundImage = badgeBackgroundImage;
    [self.badgeButton setBackgroundImage:badgeBackgroundImage forState:UIControlStateNormal];
}

- (void)setBadgeTitleFont:(UIFont *)badgeTitleFont {
    _badgeTitleFont = badgeTitleFont;
    self.badgeButton.titleLabel.font = badgeTitleFont;
}

+ (YPTabItem *)instance
{
    YPTabItem *item = [[YPTabItem alloc] init];
    return item;
}
- (void)setContentHorizontalCenterWithMarginTop:(CGFloat)marginTop
                                        spacing:(CGFloat)spacing
{
    self.contentHorizontalCenter = YES;
    self.marginTop = marginTop;
    self.spacing = spacing;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self imageForState:UIControlStateNormal] && self.contentHorizontalCenter) {
        CGSize titleSize = self.titleLabel.frame.size;
        CGSize imageSize = self.imageView.frame.size;
        titleSize = CGSizeMake(ceilf(titleSize.width), ceilf(titleSize.height));
        CGFloat totalHeight = (imageSize.height + titleSize.height + self.spacing);
        self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height - self.marginTop), 0, 0, - titleSize.width);
        self.titleEdgeInsets = UIEdgeInsetsMake(self.marginTop, - imageSize.width, - (totalHeight - titleSize.height), 0);
    }
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
    if (_badgeButton == nil) {
        self.badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.badgeTitleFont = self.badgeTitleFont ? self.badgeTitleFont : [UIFont systemFontOfSize:13];
        self.badgeBackgroundColor = self.badgeBackgroundColor ? self.badgeBackgroundColor : [UIColor colorWithRed:252 / 255.0f green:15 / 255.0f blue:29 / 255.0f alpha:1.0f];
        self.badgeTitleColor = self.badgeTitleColor ? self.badgeTitleColor : [UIColor whiteColor];
        self.badgeBackgroundImage = self.badgeBackgroundImage ? self.badgeBackgroundImage : nil;
        
        self.badgeButton.contentMode = UIViewContentModeCenter;
        self.badgeButton.userInteractionEnabled = NO;
        
        CGSize size = [@"text" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:@{NSFontAttributeName : _badgeButton.titleLabel.font}
                                            context:nil].size;
        size = CGSizeMake(ceilf(size.width), ceilf(size.height));
        self.numberBadgeFrame = BadgeFrameMake(2, 20, size.height + 2);
        self.dotBadgeFrame = BadgeFrameMake(5, 25, 10);
        [self addSubview:self.badgeButton];
    }
    
    
    _badge = badge;

    if (badge < 0) {
        [_badgeButton setTitle:nil forState:UIControlStateNormal];
        _badgeButton.frame = CGRectMake(self.frame.size.width - self.dotBadgeFrame.right - self.dotBadgeFrame.height,
                                        self.dotBadgeFrame.top,
                                        self.dotBadgeFrame.height,
                                        self.dotBadgeFrame.height);
        _badgeButton.layer.cornerRadius = _badgeButton.frame.size.height / 2;
        _badgeButton.hidden = NO;
    } else if (badge == 0) {
        _badgeButton.hidden = YES;
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
        CGFloat height = MAX(size.height + 2, self.numberBadgeFrame.height);
        CGFloat width = MAX(ceilf(size.width) + 8, height);
        _badgeButton.frame = CGRectMake(self.frame.size.width - width - self.numberBadgeFrame.right,
                                        self.numberBadgeFrame.top,
                                        width,
                                        height);
        _badgeButton.layer.cornerRadius = _badgeButton.frame.size.height / 2.0f;
        [_badgeButton setTitle:badgeStr forState:UIControlStateNormal];
    }
}

- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle {
    if (badgeStyle == YPTabItemStyleNumber) {
        self.numberBadgeFrame = BadgeFrameMake(marginTop, marginRight, height);
        _badgeButton.frame = CGRectMake(self.frame.size.width - _badgeButton.frame.size.width - self.numberBadgeFrame.right,
                                        self.numberBadgeFrame.top,
                                        _badgeButton.frame.size.width,
                                        self.numberBadgeFrame.height);
    } else if (badgeStyle == YPTabItemStyleDot) {
        self.dotBadgeFrame = BadgeFrameMake(marginTop, marginRight, height);
        _badgeButton.frame = CGRectMake(self.frame.size.width - self.dotBadgeFrame.right - self.dotBadgeFrame.height,
                                        self.dotBadgeFrame.top,
                                        self.dotBadgeFrame.height,
                                        self.dotBadgeFrame.height);
    }
}
@end
