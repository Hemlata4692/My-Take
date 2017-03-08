//
//  EmojiCollectionViewCell.h
//  MyTake
//
//  Created by Ranosys on 10/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *emojiImage;
- (void)displayCellData:(NSString *)emojiImageName isSelected:(BOOL)isSelected;
@end
