//
//  RatingViewCell.m
//  MyTake
//
//  Created by Hema on 11/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "RatingViewCell.h"


@implementation RatingViewCell
@synthesize ratingImageView;
@synthesize displayRatingLabel;
@synthesize noAnswerLabel;

#pragma mark - Set star image
- (void)displayCellData:(BOOL)isSelected {
    if (isSelected) {
        //set selected star image
        ratingImageView.hidden=NO;
        displayRatingLabel.hidden=NO;
        ratingImageView.image=[UIImage imageNamed:@"fill_star"];
        noAnswerLabel.hidden=YES;
    }
    else {
        //set star image
        ratingImageView.hidden=NO;
        displayRatingLabel.hidden=NO;
        ratingImageView.image=[UIImage imageNamed:@"star"];
        noAnswerLabel.hidden=YES;
    }
}
#pragma mark - end
@end
