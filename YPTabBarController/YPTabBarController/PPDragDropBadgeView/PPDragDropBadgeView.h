/**
 * PPDragDropBadgeView.h
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

#import <UIKit/UIKit.h>

/**
 * A badge view support drag and drop.
 *
 * @Note please use addSubview to add PPDragDropBadgeView.
 * currently, not support like tableViewCell.accessoryView = badge or [[UIBarButtonItem alloc] initWithCustomView:badge].
 */
@interface PPDragDropBadgeView : UIView

/** return the version of PPDragDropBadgeView */
+ (NSString* )version;

/**
 * init badge view
 *
 * @param frame The frame rect
 * @param dragdropCompletion The completion block when drag drop done.
 */
- (instancetype)initWithFrame:(CGRect)frame
           dragdropCompletion:(void(^)())dragdropCompletion;

/** The completion block when drag drop done. */
@property (nonatomic, copy) void(^dragdropCompletion)();

/** The tint color of badge view. Default is red */
@property (nonatomic, strong) UIColor* tintColor;

/** Hide the badge view when text is zero. Default is YES */
@property (nonatomic, assign) BOOL hiddenWhenZero;

/** The font of text, Default System font 16.0f */
@property (nonatomic, strong) UIFont* font;

/** The font size of text, Default System font 16.0f */
@property (nonatomic, assign) CGFloat fontSize;

/** Auto fit font size, Default is NO */
@property (nonatomic, assign) BOOL fontSizeAutoFit;

/** The text of badge view. */
@property (nonatomic, strong) NSString* text;

/** The text color of badge view. */
@property (nonatomic, strong) UIColor* textColor;

@end
