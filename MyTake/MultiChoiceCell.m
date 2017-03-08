//
//  MultiChoiceCell.m
//  MyTake
//
//  Created by Ranosys on 11/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MultiChoiceCell.h"

@implementation MultiChoiceCell

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
- (void)displayCellData:(AnswerOptionsModel*)answerOptionsObj isCurrentSelectedIndex:(BOOL)isCurrentSelectedIndex isExclusive:(BOOL)isExclusive {
    
    self.answerLabel.text=answerOptionsObj.answerText;
    //customise please specify view
    self.pleaseSpecifyView.layer.cornerRadius=5.0f;
    self.pleaseSpecifyView.layer.masksToBounds=YES;
    self.pleaseSpecifyAnswerTextView.placeholder=@"Please specify...";
    self.pleaseSpecifyAnswerTextView.placeholderTextColor=[UIColor colorWithRed:(80.0/255.0) green:(80.0/255.0) blue:(80.0/255.0) alpha:1.0f];
    self.thumbnailImageView.layer.cornerRadius=5.0f;
    self.thumbnailImageView.layer.masksToBounds=YES;
       if (answerOptionsObj.isSelected) {
        self.multiCellViewObject.hidden=NO;
        if ([answerOptionsObj.isOther intValue]==0) {
            self.pleaseSpecifyView.hidden=YES;
        }
        else {
            self.pleaseSpecifyView.hidden=NO;
        }
        //set thumbnail image in cell
        [self customizationThumbnailImage:self answerOptionsObj:answerOptionsObj noThumbnailImage:@"checkSelected"];
    }
    else {
        self.multiCellViewObject.hidden=YES;
        self.pleaseSpecifyView.hidden=YES;
        //set thumbnail image in cell
        [self customizationThumbnailImage:self answerOptionsObj:answerOptionsObj noThumbnailImage:@"check"];
    }
    //if isexclusive is 1 then disable all other cells
    if (isExclusive&&!isCurrentSelectedIndex) {
        self.userInteractionEnabled=NO;
        self.answerLabel.alpha=0.5f;
        self.thumbnailImageView.alpha=0.5f;
    }
    //if isexclusive is 0 enable all other cells
    else {
        self.userInteractionEnabled=YES;
        self.answerLabel.alpha=1.0f;
        self.thumbnailImageView.alpha=1.0f;
    }
}
#pragma mark - end

#pragma mark - Customization of thumbnail image according to cases
- (void)customizationThumbnailImage:(MultiChoiceCell *)cell answerOptionsObj:(AnswerOptionsModel*)answerOptionsObj noThumbnailImage:(NSString *)noThumbnailImageName {
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

#pragma mark - Downloading image using afnetworking
- (void)downloadImages:(MultiChoiceCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
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
