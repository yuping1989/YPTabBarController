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
@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, strong) CALayer *separatorLayer;

@property (nonatomic, assign) CGFloat numberBadgeMarginTop;
@property (nonatomic, assign) CGFloat numberBadgeCenterMarginRight;
@property (nonatomic, assign) CGFloat numberBadgeTitleHorizonalSpace;
@property (nonatomic, assign) CGFloat numberBadgeTitleVerticalSpace;

@property (nonatomic, assign) CGFloat dotBadgeMarginTop;
@property (nonatomic, assign) CGFloat dotBadgeCenterMarginRight;
@property (nonatomic, assign) CGFloat dotBadgeSideLength;

@property (nonatomic, copy) void (^doubleTapHandler)(void);

@end

@implementation YPTabItem

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    YPTabItem *item = [super buttonWithType:buttonType];
    [item setup];
    return item;
}

- (void)setup {
    self.badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.badgeButton.userInteractionEnabled = NO;
    self.badgeButton.clipsToBounds = YES;
    [self addSubview:self.badgeButton];
    
    self.adjustsImageWhenHighlighted = NO;
    _badgeStyle = YPTabItemBadgeStyleNumber;
    _badge = 0;
    _indicatorInsets = UIEdgeInsetsZero;
}

/**
 *  覆盖父类的setHighlighted:方法，按下YPTabItem时，不高亮该item
 */
- (void)setHighlighted:(BOOL)highlighted {
    if (self.adjustsImageWhenHighlighted) {
        [super setHighlighted:highlighted];
    }
}

- (void)setContentHorizontalCenter:(BOOL)contentHorizontalCenter {
    _contentHorizontalCenter = contentHorizontalCenter;
    if (!_contentHorizontalCenter) {
        self.verticalOffset = 0;
        self.spacing = 0;
    }
    if (self.superview) {
        [self layoutSubviews];
    }
}

- (void)setContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                             spacing:(CGFloat)spacing {
    self.verticalOffset = verticalOffset;
    self.spacing = spacing;
    self.contentHorizontalCenter = YES;
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
    } else {
        self.imageEdgeInsets = UIEdgeInsetsZero;
        self.titleEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.doubleTapView) {
        self.doubleTapView.hidden = !selected;
    }
}

- (void)setDoubleTapHandler:(void (^)(void))handler {
    _doubleTapHandler = handler;
    if (!self.doubleTapView) {
        self.doubleTapView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.doubleTapView];
        UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(doubleTapped:)];
        doubleRecognizer.numberOfTapsRequired = 2;
        [self.doubleTapView addGestureRecognizer:doubleRecognizer];
    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer {
    if (self.doubleTapHandler) {
        self.doubleTapHandler();
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _frameWithOutTransform = frame;
    if (self.doubleTapView) {
        self.doubleTapView.frame = self.bounds;
    }
    [self updateBadge];
    [self calculateIndicatorFrame];
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

#pragma mark - Title and Image

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
    [self calculateTitleWidth];
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
    [self calculateTitleWidth];
}

- (void)calculateTitleWidth {
    if (self.title.length == 0 || !self.titleFont) {
        _titleWidth = 0;
        return;
    }
    CGSize size = [self.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName : self.titleFont}
                                           context:nil].size;
    _titleWidth = ceilf(size.width);
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    [self setImage:selectedImage forState:UIControlStateSelected];
}

- (void)setIndicatorInsets:(UIEdgeInsets)indicatorInsets {
    _indicatorInsets = indicatorInsets;
    [self calculateIndicatorFrame];
}

- (void)calculateIndicatorFrame {
    CGRect frame = self.frameWithOutTransform;
    UIEdgeInsets insets = self.indicatorInsets;
    _indicatorFrame = CGRectMake(frame.origin.x + insets.left,
                                 frame.origin.y + insets.top,
                                 frame.size.width - insets.left - insets.right,
                                 frame.size.height - insets.top - insets.bottom);
}

#pragma mark - Badge

- (void)setBadge:(NSInteger)badge {
    _badge = badge;
    [self updateBadge];
}

- (void)setBadgeStyle:(YPTabItemBadgeStyle)badgeStyle {
    _badgeStyle = badgeStyle;
    [self updateBadge];
}

- (void)updateBadge {
    if (self.badgeStyle == YPTabItemBadgeStyleNumber) {
        if (self.badge == 0) {
            self.badgeButton.hidden = YES;
        } else {
            NSString *badgeStr = @(self.badge).stringValue;
            if (self.badge > 99) {
                badgeStr = @"99+";
            } else if (self.badge < -99) {
                badgeStr = @"-99+";
            }
            
            // 计算badgeStr的size
            CGSize size = [badgeStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName : self.badgeButton.titleLabel.font}
                                                 context:nil].size;
            // 计算badgeButton的宽度和高度
            CGFloat width = ceilf(size.width) + self.numberBadgeTitleHorizonalSpace;
            CGFloat height = ceilf(size.height) + self.numberBadgeTitleVerticalSpace;
            
            // 宽度取width和height的较大值，使badge为个位数时，badgeButton为圆形
            width = MAX(width, height);
            
            // 设置badgeButton的frame
            self.badgeButton.frame = CGRectMake(self.bounds.size.width - width / 2 - self.numberBadgeCenterMarginRight,
                                                self.numberBadgeMarginTop,
                                                width,
                                                height);
            self.badgeButton.layer.cornerRadius = self.badgeButton.bounds.size.height / 2;
            [self.badgeButton setTitle:badgeStr forState:UIControlStateNormal];
            self.badgeButton.hidden = NO;
        }
    } else if (self.badgeStyle == YPTabItemBadgeStyleDot) {
        [self.badgeButton setTitle:nil forState:UIControlStateNormal];
        self.badgeButton.frame = CGRectMake(self.bounds.size.width - self.dotBadgeCenterMarginRight - self.dotBadgeSideLength,
                                            self.dotBadgeMarginTop,
                                            self.dotBadgeSideLength,
                                            self.dotBadgeSideLength);
        self.badgeButton.layer.cornerRadius = self.badgeButton.bounds.size.height / 2;
        self.badgeButton.hidden = NO;
    }
}

- (void)setNumberBadgeMarginTop:(CGFloat)marginTop
              centerMarginRight:(CGFloat)centerMarginRight
            titleHorizonalSpace:(CGFloat)titleHorizonalSpace
             titleVerticalSpace:(CGFloat)titleVerticalSpace {
    self.numberBadgeMarginTop = marginTop;
    self.numberBadgeCenterMarginRight = centerMarginRight;
    self.numberBadgeTitleHorizonalSpace = titleHorizonalSpace;
    self.numberBadgeTitleVerticalSpace = titleVerticalSpace;
    [self updateBadge];
}

- (void)setDotBadgeMarginTop:(CGFloat)marginTop
           centerMarginRight:(CGFloat)centerMarginRight
                  sideLength:(CGFloat)sideLength {
    self.dotBadgeMarginTop = marginTop;
    self.dotBadgeCenterMarginRight = centerMarginRight;
    self.dotBadgeSideLength = sideLength;
    [self updateBadge];
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
    [self updateBadge];
}

@end
