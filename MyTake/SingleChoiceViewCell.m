//
//  SingleChoiceViewCell.m
//  MyTake
//
//  Created by Ranosys on 10/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SingleChoiceViewCell.h"

@implementation SingleChoiceViewCell

#pragma mark - Init nib
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
#pragma mark - end

#pragma mark - Display data
- (void)displayCellData:(AnswerOptionsModel*)answerOptionsObj {
    self.answerLabel.text=answerOptionsObj.answerText;
    //customise pleaseSpecifyView
    self.pleaseSpecifyView.layer.cornerRadius=5.0f;
    self.pleaseSpecifyView.layer.masksToBounds=YES;
    self.pleaseSpecifyAnswerTextView.placeholder=@"Please specify...";
    self.pleaseSpecifyAnswerTextView.placeholderTextColor=[UIColor colorWithRed:(80.0/255.0) green:(80.0/255.0) blue:(80.0/255.0) alpha:1.0f];
    self.thumbnailImageView.layer.cornerRadius=5.0f;
    self.thumbnailImageView.layer.masksToBounds=YES;
    if (answerOptionsObj.isSelected) {
        self.singleCellViewObject.hidden=NO;
        if ([answerOptionsObj.isOther intValue]==0) {
            self.pleaseSpecifyView.hidden=YES;
        }
        else {
            self.pleaseSpecifyView.hidden=NO;
        }
        //Set thumbnail image in cell
        [self customizationThumbnailImage:self answerOptionsObj:answerOptionsObj noThumbnailImage:@"radioSelected"];
    }
    else {
        self.singleCellViewObject.hidden=YES;
        self.pleaseSpecifyView.hidden=YES;
        //Set thumbnail image in cell
        [self customizationThumbnailImage:self answerOptionsObj:answerOptionsObj noThumbnailImage:@"radio"];
    }
}
#pragma mark - end

#pragma mark - Customization of thumbnail image according to cases
- (void)customizationThumbnailImage:(SingleChoiceViewCell *)cell answerOptionsObj:(AnswerOptionsModel*)answerOptionsObj noThumbnailImage:(NSString *)noThumbnailImageName {
    if ((nil==answerOptionsObj.answerThumbnailImage)||[answerOptionsObj.answerThumbnailImage isEqualToString:@""]) {
        cell.thumbnailImageView.contentMode=UIViewContentModeCenter;
        cell.thumbnailImageView.image = [UIImage imageNamed:noThumbnailImageName];
    }
    else {
        self.thumbnailImageView.contentMode=UIViewContentModeScaleAspectFill;
        [self downloadImages:cell imageUrl:answerOptionsObj.answerThumbnailImage placeholderImage:@"placeholder.png"];
    }
}
#pragma mark - end

#pragma mark - Download image using afnetworking
- (void)downloadImages:(SingleChoiceViewCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    __weak UIImageView *weakRef = cell.thumbnailImageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [cell.thumbnailImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
