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
@property (nonatomic, assign) YPTabItemBadgeFrame numberBadgeFrame;
@property (nonatomic, assign) YPTabItemBadgeFrame dotBadgeFrame;
@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat spacing;
@end

@implementation YPTabItem

- (instancetype)init {
    self = [super init];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    self.badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.badgeButton.userInteractionEnabled = NO;
    self.badgeButton.clipsToBounds = YES;
    [self addSubview:self.badgeButton];
    
    self.badge = 0;
//    _verticalOffset = 5;
//    _spacing = 5;
//    _contentHorizontalCenter = YES;
//    self.badgeTitleColor = [UIColor whiteColor];
//    self.badgeTitleFont = [UIFont systemFontOfSize:13];
//    self.badgeBackgroundColor = BADGE_BG_COLOR_DEFAULT;
//    self.numberBadgeFrame = YPTabItemBadgeFrameMake(2, 20, 16);
//    self.dotBadgeFrame = YPTabItemBadgeFrameMake(5, 25, 10);
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

- (void)setContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                             spacing:(CGFloat)spacing {
    self.contentHorizontalCenter = YES;
    self.verticalOffset = verticalOffset;
    self.spacing = spacing;
    if (self.superview) {
        [self layoutSubviews];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self imageForState:UIControlStateNormal] && self.contentHorizontalCenter) {
        CGSize titleSize = self.titleLabel.frame.size;
        CGSize imageSize = self.imageView.frame.size;
        titleSize = CGSizeMake(ceilf(titleSize.width), ceilf(titleSize.height));
        CGFloat totalHeight = (imageSize.height + titleSize.height + self.spacing);
        self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height - self.verticalOffset), 0, 0, - titleSize.width);
        self.titleEdgeInsets = UIEdgeInsetsMake(self.verticalOffset, - imageSize.width, - (totalHeight - titleSize.height), 0);
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.doubleTapView) {
        self.doubleTapView.hidden = !selected;
    }
}
- (void)addDoubleTapTarget:(id)target action:(SEL)action {
    if (!self.doubleTapView) {
        self.doubleTapView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.doubleTapView];
    }

    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    doubleRecognizer.numberOfTapsRequired = 2;
    [self.doubleTapView addGestureRecognizer:doubleRecognizer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _frameWithOutTransform = frame;
    if (self.doubleTapView) {
        self.doubleTapView.frame = self.bounds;
    }
}

#pragma mark - Title and Image

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [self setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor {
    _titleSelectedColor = titleSelectedColor;
    [self setTitleColor:titleSelectedColor forState:UIControlStateSelected];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
        self.titleLabel.font = titleFont;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    [self setImage:selectedImage forState:UIControlStateSelected];
}


#pragma mark - Badge

- (void)setBadge:(NSInteger)badge {
    _badge = badge;
    
    if (_badge < 0) {
        [self.badgeButton setTitle:nil forState:UIControlStateNormal];
        self.badgeButton.frame = CGRectMake(self.frame.size.width - self.dotBadgeFrame.right - self.dotBadgeFrame.height,
                                        self.dotBadgeFrame.top,
                                        self.dotBadgeFrame.height,
                                        self.dotBadgeFrame.height);
        self.badgeButton.layer.cornerRadius = self.badgeButton.frame.size.height / 2;
        self.badgeButton.hidden = NO;
    } else if (badge == 0) {
        self.badgeButton.hidden = YES;
    } else {
        
        NSString *badgeStr = @(badge).stringValue;
        if (badge > 99) {
            badgeStr = @"99+";
        }
        
        CGSize size = [badgeStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : self.badgeButton.titleLabel.font}
                                                  context:nil].size;
        CGFloat height = MAX(ceilf(size.height) + 2, self.numberBadgeFrame.height);
        CGFloat width = MAX(ceilf(size.width) + 8, height);
        self.badgeButton.frame = CGRectMake(self.frame.size.width - width - self.numberBadgeFrame.right,
                                        self.numberBadgeFrame.top,
                                        width,
                                        height);
        self.badgeButton.layer.cornerRadius = self.badgeButton.frame.size.height / 2.0f;
        [self.badgeButton setTitle:badgeStr forState:UIControlStateNormal];
        self.badgeButton.hidden = NO;
    }
}

- (void)setBadgeMarginTop:(CGFloat)marginTop
              marginRight:(CGFloat)marginRight
                   height:(CGFloat)height
                 forStyle:(YPTabItemBadgeStyle)badgeStyle {
    if (badgeStyle == YPTabItemBadgeStyleNumber) {
        self.numberBadgeFrame = YPTabItemBadgeFrameMake(marginTop, marginRight, height);
        self.badgeButton.frame = CGRectMake(self.frame.size.width - self.badgeButton.frame.size.width - self.numberBadgeFrame.right,
                                            self.numberBadgeFrame.top,
                                            self.badgeButton.frame.size.width,
                                            self.numberBadgeFrame.height);
    } else if (badgeStyle == YPTabItemBadgeStyleDot) {
        self.dotBadgeFrame = YPTabItemBadgeFrameMake(marginTop, marginRight, height);
        self.badgeButton.frame = CGRectMake(self.frame.size.width - self.dotBadgeFrame.right - self.dotBadgeFrame.height,
                                            self.dotBadgeFrame.top,
                                            self.dotBadgeFrame.height,
                                            self.dotBadgeFrame.height);
    }
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
@end
