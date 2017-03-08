//
//  MainSideBarViewController.m
//  MyTake
//
//  Created by Hema on 27/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MainSideBarViewController.h"
#import "AMSlideMenuMainViewController.h"

@interface MainSideBarViewController ()

@end

@implementation MainSideBarViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Overriden Methods
//set segue identifier
- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    switch (indexPath.row) {
        case 0:
            identifier = @"mission";
            break;
        case 1:
            identifier = @"mission";
            break;
        case 2:
            identifier = @"community";
            break;
        case 3:
            identifier = @"instruction";
            break;
    }
    
    return identifier;
}
//set side bar width
- (CGFloat)leftMenuWidth {
    return 170;
}
//add left menu button
- (void)configureLeftMenuButton:(UIButton *)button {
    CGRect frame = button.frame;
    frame = CGRectMake(0, 0, 30, 30);
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
}

- (void) configureSlideLayer:(CALayer *)layer {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 5;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
}
//open sidebar animation
- (UIViewAnimationOptions) openAnimationCurve {
    return UIViewAnimationOptionCurveEaseOut;
}
//close sidebar animation
- (UIViewAnimationOptions) closeAnimationCurve {
    return UIViewAnimationOptionCurveEaseOut;
}
//set primary sidebar menu
- (AMPrimaryMenu)primaryMenu {
    return AMPrimaryMenuLeft;
}

// Enabling Deepnes on left menu
- (BOOL)deepnessForLeftMenu {
    return YES;
}

// Enabling darkness while left menu is opening
- (CGFloat)maxDarknessWhileLeftMenu {
    return 0.5;
}

@end
