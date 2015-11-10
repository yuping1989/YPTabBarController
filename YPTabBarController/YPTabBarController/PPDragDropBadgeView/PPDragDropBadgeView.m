/**
 * PPDragDropBadgeView.c
 *
 * A badge view with drag and drop.
 *
 * MIT licence follows:
 *
 * Copyright (C) 2015 Wenva <lvyexuwenfa100@126.com>
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "PPDragDropBadgeView.h"
#import "PRTween.h"
#import "PRTweenTimingFunctions.h"

#define kDefaultTintColor               [UIColor redColor]
#define kDefaultBorderColor             [UIColor clearColor]
#define kDefaultBorderWidth             1.0f
#define kElasticDuration                0.5f
#define kFromRadiusScaleCoefficient     0.09f
#define kToRadiusScaleCoefficient       0.05f
#define kMaxDistanceScaleCoefficient    8.0f
#define kFollowTimeInterval             0.016f
#define kBombDuration                   0.5f
#define kValidRadius                    20.0f
#define kDefaultFontSize                16.0f

#define kPaddingSize                    10.0f

CGFloat distanceBetweenPoints (CGPoint p1, CGPoint p2) {
    CGFloat deltaX = p2.x - p1.x;
    CGFloat deltaY = p2.y - p1.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
};

@interface PPDragDropBadgeView () {
    UIControl*              _overlayView;       //拖动时self依附的view
    UIView*                 _originSuperView;   //原self容器
    CGFloat                 _viscosity;         //粘度
    CGSize                  _size;              //圆大小
    CGPoint                 _originPoint;       //源点
    CGFloat                 _radius;            //圆半径
    BOOL                    _padding;           //配置内边距
    
    CGPoint                 _fromPoint;
    CGPoint                 _toPoint;
    CGFloat                 _fromRadius;
    CGFloat                 _toRadius;
    
    CGPoint                 _elasticBeginPoint;
    
    BOOL                    _missed;
    BOOL                    _beEnableDragDrop;
    CGFloat                 _maxDistance;
    CGFloat                 _distance;
    PRTweenOperation*       _activeTweenOperation;
    
    UILabel*                _textLabel;
    UIImageView*            _bombImageView;
    
    CAShapeLayer*           _shapeLayer;
    
    UIPanGestureRecognizer* _panGestureRecognizer;
}

@property (nonatomic, strong) UIControl* overlayView;

@end

@implementation PPDragDropBadgeView

+ (NSString* )version {
    return @"2.1";
}

- (void)awakeFromNib {
    _padding = YES;
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame dragdropCompletion:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
           dragdropCompletion:(void(^)())dragdropCompletion {
    self = [super initWithFrame:frame];
    if (self) {
        self.dragdropCompletion = dragdropCompletion;
        [self setup];
    }
    return self;
}

- (void)setup {
    //为了便于拖拽，扩大空间区域
    _size = self.frame.size;
    
    if (!_padding) {
        CGRect wapperFrame = self.frame;
        wapperFrame.origin.x -= kPaddingSize;
        wapperFrame.origin.y -= kPaddingSize;
        wapperFrame.size.width += kPaddingSize*2;
        wapperFrame.size.height += kPaddingSize*2;
        self.frame = wapperFrame;
        _padding = YES;
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    _tintColor = kDefaultTintColor;
    _hiddenWhenZero = YES;
    _fontSizeAutoFit = NO;
    
    _shapeLayer = [CAShapeLayer new];
    [self.layer addSublayer:_shapeLayer];
    _shapeLayer.frame = CGRectMake(0, 0, _size.width, _size.height);
    _shapeLayer.fillColor = _tintColor.CGColor;
    
    _radius = _size.width/2;
    _originPoint = CGPointMake(kPaddingSize+_radius, kPaddingSize+_radius);
    
    //爆炸效果
    _bombImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    _bombImageView.animationImages = @[[UIImage imageNamed:@"PPDragDropBadgeView.bundle/bomb0"],
                                       [UIImage imageNamed:@"PPDragDropBadgeView.bundle/bomb1"],
                                       [UIImage imageNamed:@"PPDragDropBadgeView.bundle/bomb2"],
                                       [UIImage imageNamed:@"PPDragDropBadgeView.bundle/bomb3"],
                                       [UIImage imageNamed:@"PPDragDropBadgeView.bundle/bomb4"]];
    _bombImageView.animationRepeatCount = 1;
    _bombImageView.animationDuration = kBombDuration;
    [self addSubview:_bombImageView];
    
    //文字
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingSize, kPaddingSize, _size.width, _size.width)];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.text = @"";
    [self addSubview:_textLabel];
    
    //拖动手势
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onGestureAction:)];
    [_panGestureRecognizer setDelaysTouchesBegan:YES];
    [_panGestureRecognizer setDelaysTouchesEnded:YES];
    [self addGestureRecognizer:_panGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self reset];
}

- (void)dealloc {
    [self removeGestureRecognizer:_panGestureRecognizer];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor?tintColor:kDefaultTintColor;
    _shapeLayer.fillColor = _tintColor.CGColor;
}

- (void)setFont:(UIFont *)font {
    [_textLabel setFont:font];
}

- (void)setFontSize:(CGFloat)fontSize {
    [_textLabel setFont:[_textLabel.font fontWithSize:fontSize]];
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    _textLabel.hidden = NO;
    
    self.hidden = NO;
    if (_hiddenWhenZero
        && ([text isEqualToString:@"0"] || [text isEqualToString:@""])) {
        self.hidden = YES;
    }
    
    [self reset];
}

- (void)setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
}

- (void)reset {
    _fromPoint = _originPoint;
    _toPoint = _fromPoint;
    _maxDistance = kMaxDistanceScaleCoefficient*_radius;

    [self updateRadius];
}

- (void)update:(PRTweenPeriod*)period {
    CGFloat c = period.tweenedValue;
    if (isnan(c) || c > 10000000.0f || c < -10000000.0f) return;
    
    if (_missed) {
        CGFloat x = (_distance != 0)?((_toPoint.x-_elasticBeginPoint.x)*c/_distance):0;
        CGFloat y = (_distance != 0)?((_toPoint.y-_elasticBeginPoint.y)*c/_distance):0;
        
        _fromPoint = CGPointMake(_elasticBeginPoint.x+x, _elasticBeginPoint.y+y);
    } else {
        CGFloat x = (_distance != 0)?((_fromPoint.x - _elasticBeginPoint.x)*c/_distance):0;
        CGFloat y = (_distance != 0)?((_fromPoint.y - _elasticBeginPoint.y)*c/_distance):0;
        
        _toPoint = CGPointMake(_elasticBeginPoint.x+x, _elasticBeginPoint.y+y);
    }
    
    [self updateRadius];
}


- (void)updateRadius {
    CGFloat r = distanceBetweenPoints(_fromPoint, _toPoint);
    
    _fromRadius = _radius-kFromRadiusScaleCoefficient*r;
    _toRadius = _radius-kToRadiusScaleCoefficient*r;
    _viscosity = (_maxDistance != 0)?(1.0-r/_maxDistance):1.0f;
    
    if (_fontSizeAutoFit) {
        _textLabel.font = [_textLabel.font fontWithSize:(_textLabel.text.length)?((2*_toRadius)/(1.2*_textLabel.text.length)):kDefaultFontSize];
    }
    _textLabel.center = _toPoint;

    [self setNeedsDisplay];
}


- (UIBezierPath* )bezierPathWithFromPoint:(CGPoint)fromPoint
                                  toPoint:(CGPoint)toPoint
                               fromRadius:(CGFloat)fromRadius
                                 toRadius:(CGFloat)toRadius scale:(CGFloat)scale{
    
    if (isnan(fromRadius) || isnan(toRadius)||isnan(fromRadius)||isnan(toRadius)) return nil;

    UIBezierPath* path = [[UIBezierPath alloc] init];
    CGFloat r = distanceBetweenPoints(fromPoint, toPoint);
    CGFloat offsetY = fabs(fromRadius-toRadius);
    if (r <= offsetY) {
        CGPoint center;
        CGFloat radius;
        if (fromRadius >= toRadius) {
            center = fromPoint;
            radius = fromRadius;
        } else {
            center = toPoint;
            radius = toRadius;
        }
        [path addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    } else {
        CGFloat originX = toPoint.x - fromPoint.x;
        CGFloat originY = toPoint.y - fromPoint.y;
        
        CGFloat fromOriginAngel = (originX >= 0)?atan(originY/originX):(atan(originY/originX)+M_PI);
        CGFloat fromOffsetAngel = (fromRadius >= toRadius)?acos(offsetY/r):(M_PI-acos(offsetY/r));
        CGFloat fromStartAngel = fromOriginAngel + fromOffsetAngel;
        CGFloat fromEndAngel = fromOriginAngel - fromOffsetAngel;
        
        CGPoint fromStartPoint = CGPointMake(fromPoint.x+cos(fromStartAngel)*fromRadius, fromPoint.y+sin(fromStartAngel)*fromRadius);
        
        CGFloat toOriginAngel = (originX < 0)?atan(originY/originX):(atan(originY/originX)+M_PI);
        CGFloat toOffsetAngel = (fromRadius < toRadius)?acos(offsetY/r):(M_PI-acos(offsetY/r));
        CGFloat toStartAngel = toOriginAngel + toOffsetAngel;
        CGFloat toEndAngel = toOriginAngel - toOffsetAngel;
        CGPoint toStartPoint = CGPointMake(toPoint.x+cos(toStartAngel)*toRadius, toPoint.y+sin(toStartAngel)*toRadius);
        
        CGPoint middlePoint = CGPointMake(fromPoint.x+(toPoint.x-fromPoint.x)/2, fromPoint.y+(toPoint.y-fromPoint.y)/2);
        CGFloat middleRadius = (fromRadius+toRadius)/2;
        
        CGPoint fromControlPoint = CGPointMake(middlePoint.x+sin(fromOriginAngel)*middleRadius*scale, middlePoint.y-cos(fromOriginAngel)*middleRadius*scale);
        
        CGPoint toControlPoint = CGPointMake(middlePoint.x+sin(toOriginAngel)*middleRadius*scale, middlePoint.y-cos(toOriginAngel)*middleRadius*scale);
        
        [path moveToPoint:fromStartPoint];
        
        //绘制from弧形
        [path addArcWithCenter:fromPoint radius:fromRadius startAngle:fromStartAngel endAngle:fromEndAngel clockwise:YES];
        
        //绘制from到to之间的贝塞尔曲线
        if (r > (fromRadius+toRadius)) {
            [path addQuadCurveToPoint:toStartPoint controlPoint:fromControlPoint];
        }
        
        //绘制to弧形
        [path addArcWithCenter:toPoint radius:toRadius startAngle:toStartAngel endAngle:toEndAngel clockwise:YES];
        
        //绘制to到from之间的贝塞尔曲线
        if (r > (fromRadius+toRadius)) {
            [path addQuadCurveToPoint:fromStartPoint controlPoint:toControlPoint];
        }
    }
    
    [path closePath];
    
    return path;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath* path = [self bezierPathWithFromPoint:_fromPoint toPoint:_toPoint fromRadius:_fromRadius toRadius:_toRadius scale:_viscosity];
    _shapeLayer.path = path.CGPath;
}

#pragma mark - Touch
- (void)onGestureAction:(UIPanGestureRecognizer* )gesture {
    CGPoint point = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self touchesBegan:point];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self touchesEnded:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self touchesMoved:point];
            break;
        default:
            break;
    }
}

- (void)touchesBegan:(CGPoint)point {
    _missed = NO;
    _beEnableDragDrop = YES;
    [self becomeUpper];
}

- (UIControl *)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
    }
    return _overlayView;
}

- (void)becomeUpper {
    if(!self.overlayView.superview){
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
        }
    } else {
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }

    _originSuperView = self.superview;
    self.center = [_originSuperView convertPoint:self.center toView:self.overlayView];
    
    if ([_originSuperView isKindOfClass:[UITableViewCell class]]
        && self == ((UITableViewCell* )_originSuperView).accessoryView) {
        ((UITableViewCell* )_originSuperView).accessoryView = nil;
    }
    
    [self.overlayView addSubview:self];
}

- (void)resignUpper {
    [_overlayView removeFromSuperview];
    self.center = [_overlayView convertPoint:self.center toView:_originSuperView];
    
    if ([_originSuperView isKindOfClass:[UITableViewCell class]]
        && self == ((UITableViewCell* )_originSuperView).accessoryView) {
        ((UITableViewCell* )_originSuperView).accessoryView = self;
    } else {
        [_originSuperView addSubview:self];
    }
    
    _overlayView = nil;
}

- (void)touchesEnded:(CGPoint)point {
    if (!_beEnableDragDrop) return;
    
    if (!_missed) {
        _elasticBeginPoint = _toPoint;
        _distance = distanceBetweenPoints(_fromPoint, _toPoint);
        
        [[PRTween sharedInstance] removeTweenOperation:_activeTweenOperation];
        PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:0 endValue:_distance duration:kElasticDuration];
        _activeTweenOperation = [[PRTween sharedInstance] addTweenPeriod:period target:self selector:@selector(update:) timingFunction:&PRTweenTimingFunctionElasticOut];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kElasticDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resignUpper];
        });
    } else {
        if (CGRectContainsPoint(CGRectMake(_originPoint.x-kValidRadius, _originPoint.y-kValidRadius, 2*kValidRadius, 2*kValidRadius), point)) {
            [self resignUpper];
            [self reset];
        } else {
            _bombImageView.center = _toPoint;
            _toRadius = 0;
            _fromRadius = 0;
            _textLabel.hidden = YES;
            [_bombImageView startAnimating];
            _activeTweenOperation.updateSelector = nil;
            [[PRTween sharedInstance] removeTweenOperation:_activeTweenOperation];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBombDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resignUpper];
            });
            
            if (self.dragdropCompletion) {
                self.dragdropCompletion();
            }
        }
        
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(CGPoint)point {
    if (!_beEnableDragDrop) return;
    
    CGFloat r = distanceBetweenPoints(_fromPoint, point);
    if (_missed) {
        _activeTweenOperation.updateSelector = nil;
        if (!CGPointEqualToPoint(point, CGPointZero)) {
            _fromPoint = _toPoint = point;
            [self updateRadius];
        }
    } else {
        _toPoint = point;
        if (r > _maxDistance) {
            _missed = YES;
            _elasticBeginPoint = _fromPoint;
            _distance = distanceBetweenPoints(_fromPoint, _toPoint);
            
            [[PRTween sharedInstance] removeTweenOperation:_activeTweenOperation];
            
            PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:0 endValue:_distance duration:kElasticDuration];
            _activeTweenOperation = [[PRTween sharedInstance] addTweenPeriod:period target:self selector:@selector(update:) timingFunction:&PRTweenTimingFunctionElasticOut];
        } else {
            [self updateRadius];
        }
    }
    
}

@end
