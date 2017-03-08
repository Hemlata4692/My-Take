//
//  EmojiCollectionViewCell.m
//  MyTake
//
//  Created by Ranosys on 10/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "EmojiCollectionViewCell.h"

@implementation EmojiCollectionViewCell
@synthesize emojiImage;

//display selected un selected border
- (void)displayCellData:(NSString *)emojiImageName isSelected:(BOOL)isSelected {

    emojiImage.image = [UIImage imageNamed:emojiImageName];
    if (isSelected) {
        emojiImage.layer.borderColor = [UIColor colorWithRed:161.0/255.0 green:214.0/255.0 blue:84.0/255.0 alpha:1.0].CGColor;
        emojiImage.layer.borderWidth = 2.0f;
    }
    else {
        emojiImage.layer.borderColor = [UIColor clearColor].CGColor;
        emojiImage.layer.borderWidth = 0.0f;
    }
}
@end
