//
//  CustomProgressBar.h
//  CustomProgressbar
//
//  Created by Ranosys on 21/06/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProgressBar : UIView

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)backgroundColor innerViewColor:(UIColor*)innerViewColor progressValue:(float)progressValue myView:(UIView *)myView padding:(float)padding;
- (void)changeProgress:(float)value;
@end
