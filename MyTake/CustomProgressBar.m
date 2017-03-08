//
//  CustomProgressBar.m
//  CustomProgressbar
//
//  Created by Ranosys on 21/06/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "CustomProgressBar.h"

@interface CustomProgressBar (){
    
    UIView *innerProgressView;
    UIView *progressView;
    float paddingValue;
}
@end

@implementation CustomProgressBar

#pragma mark - Init progress with frame
//init bar with frame
- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)backgroundColor innerViewColor:(UIColor*)innerViewColor progressValue:(float)progressValue myView:(UIView *)myView padding:(float)padding {
    self=[super initWithFrame:frame];
    if (self) {
        paddingValue = padding;
        progressView = [[UIView alloc] initWithFrame:frame];
        progressView.backgroundColor = backgroundColor;
        [progressView setBorder:progressView color:[UIColor colorWithRed:194.0/255.0 green:224.0/255.0 blue:150.0/255.0 alpha:1.0]];
        [myView addSubview:progressView];
        float width = (progressView.frame.size.width - (padding * 2.0)) * progressValue ;
        innerProgressView = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, width, progressView.frame.size.height - (padding * 2.0))];
        innerProgressView.backgroundColor = innerViewColor;
        [progressView addSubview:innerProgressView];
        progressView.layer.cornerRadius = progressView.frame.size.height / 2.0;
        progressView.layer.masksToBounds = YES;
        innerProgressView.layer.cornerRadius = innerProgressView.frame.size.height / 2.0;
        innerProgressView.layer.masksToBounds = YES;
    }
    return self;
}
#pragma mark - end

#pragma mark - Change progress
//change progress
- (void)changeProgress:(float)value {
    float width = (progressView.frame.size.width - (paddingValue * 2.0)) * value ;
    innerProgressView.frame = CGRectMake(paddingValue, paddingValue, width, innerProgressView.frame.size.height);
}
#pragma mark - end
@end
