//
//  MultiChoiceCell.h
//  MyTake
//
//  Created by Ranosys on 11/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswerOptionsModel.h"
#import "UIPlaceHolderTextView.h"

@interface MultiChoiceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *pleaseSpecifyAnswerTextView;
@property (strong, nonatomic) IBOutlet UIView *multiCellViewObject;
@property (strong, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UIView *pleaseSpecifyView;
- (void)displayCellData:(AnswerOptionsModel*)answerOptionsObj isCurrentSelectedIndex:(BOOL)isCurrentSelectedIndex isExclusive:(BOOL)isExclusive;
@end
