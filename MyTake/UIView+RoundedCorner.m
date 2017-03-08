//
//  UIView+RoundedCorner.m
//  WheelerButler
//
//  Created by Hema on 24/01/15.
//
//

#import "UIView+RoundedCorner.h"

@implementation UIView (RoundedCorner)
//set corner radius
- (void)setCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
//set text filed border
- (void)setTextBorder:(UITextField *)textField color:(UIColor *)color {
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = color.CGColor;
}
//set text view border
- (void)setTextViewBorder:(UITextView *)textView color:(UIColor *)color {
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = color.CGColor;
}
//set view border
- (void)setViewBorder: (UIView *)view  color:(UIColor *)color {
    view.layer.borderColor =color.CGColor;
    view.layer.borderWidth = 1.5f;
}
//set label border
- (void)setBorder: (UIView *)view  color:(UIColor *)color {
    view.layer.borderColor =color.CGColor;
    view.layer.borderWidth = 1.0f;
}
//set bottom border only
- (void)setBottomBorder: (UIView *)view color:(UIColor *)color {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, view.frame.size.height-1, view.frame.size.width, 2.0f);
    bottomBorder.backgroundColor = color.CGColor;
    [view.layer addSublayer:bottomBorder];
}
//add shadow
- (void)addShadow: (UIView *)view color:(UIColor *)color {
    view.layer.shadowColor =color.CGColor;
    view.layer.shadowOffset = CGSizeMake(1, 1);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 2.0;
}
//add shadow with corner radius
- (void)addShadowWithCornerRadius: (UIView *)_myView color:(UIColor *)color borderColor:(UIColor *)borderColor radius:(CGFloat)radius {
    [_myView.layer setCornerRadius:radius];
    
    // border
    [_myView.layer setBorderColor:borderColor.CGColor];
    [_myView.layer setBorderWidth:1.5f];
    
    // drop shadow
    [_myView.layer setShadowColor:color.CGColor];
    [_myView.layer setShadowOpacity:0.8];
    [_myView.layer setShadowRadius:3.0];
    [_myView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
}
@end
