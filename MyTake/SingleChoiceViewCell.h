//
//  SingleChoiceViewCell.h
//  MyTake
//
//  Created by Ranosys on 10/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswerOptionsModel.h"
#import "UIPlaceHolderTextView.h"

@interface SingleChoiceViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *pleaseSpecifyAnswerTextView;
@property (strong, nonatomic) IBOutlet UIView *singleCellViewObject;
@property (strong, nonatomic) IBOutlet UILabel *answerLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UIView *pleaseSpecifyView;
@property (weak, nonatomic) IBOutlet UIButton *radioButton;
- (void)displayCellData:(AnswerOptionsModel*)answerOptionsObj;
@end
