//
//  RatingViewCell.h
//  MyTake
//
//  Created by Hema on 11/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *noAnswerLabel;

- (void)displayCellData:(BOOL)isSelected;
@end
