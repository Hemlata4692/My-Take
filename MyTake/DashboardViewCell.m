//
//  DashboardViewCell.m
//  MyTake
//
//  Created by Hema on 29/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "DashboardViewCell.h"

@implementation DashboardViewCell
@synthesize timeContainerView;
@synthesize missionStatusImageView;
@synthesize missionStatusLabel;
@synthesize missionImageView;
@synthesize missionNameLabel;
@synthesize missionTimeLabel;
@synthesize topSeparator;
@synthesize statusView;
@synthesize imageContainerView;

#pragma mark - Load nib
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
#pragma mark - end

#pragma mark - Display data on cells
- (void)displayMissionListData :(MissionDataModel *)missionListData indexPath:(int)indexPath {
    missionStatusLabel.translatesAutoresizingMaskIntoConstraints=YES;
    statusView.translatesAutoresizingMaskIntoConstraints=YES;
    //set corner radius
    [timeContainerView setCornerRadius:12.0];
    [imageContainerView setCornerRadius:2.0];
    [missionStatusImageView addShadow:missionStatusImageView color:[UIColor grayColor]];
    //set text in labels
    missionNameLabel.text=missionListData.missionTitle;
    [missionNameLabel addShadow:missionNameLabel color:[UIColor grayColor]];
    if([missionListData.missionStatus isEqualToString:@"pending"]) {
        missionListData.missionStatus=@"Pending Submission";
    }
    
    //set dynamic height of status label
    CGSize size = CGSizeMake(73,50);
    CGRect  textRect=[self setDynamicHeight:size textString:missionListData.missionStatus fontSize:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:13]];
    missionStatusLabel.numberOfLines = 0;
    statusView.frame = CGRectMake(5, 46, 74, textRect.size.height+10);
    //add shadow and corner radius on stats view
    [statusView addShadowWithCornerRadius:statusView color:[UIColor grayColor] borderColor:[UIColor whiteColor] radius:statusView.frame.size.height/2.0];
    missionStatusLabel.frame = CGRectMake(4, 6, 67, textRect.size.height);
    
    //change status images according to mission status
    if ([missionListData.missionStatus isEqualToString:@"none"]) {
        missionStatusLabel.text=@"Not Started";
        missionStatusImageView.image=[UIImage imageNamed:@"not_started"];
        missionStatusLabel.textColor=[UIColor colorWithRed:0.0/255.0 green:43.0/255.0 blue:57.0/255.0 alpha:1.0];
        timeContainerView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:43.0/255.0 blue:57.0/255.0 alpha:0.7];
    }
    else if([missionListData.missionStatus isEqualToString:@"In Progress"]){
        missionStatusLabel.text=missionListData.missionStatus;
        missionStatusLabel.textColor=[UIColor colorWithRed:255.0/255.0 green:67.0/255.0 blue:79.0/255.0 alpha:1.0];
        timeContainerView.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:67.0/255.0 blue:79.0/255.0 alpha:0.7];
        missionStatusImageView.image=[UIImage imageNamed:@"in_progress"];
    }
    else if([missionListData.missionStatus isEqualToString:@"Pending Submission"]){
        missionStatusLabel.text=missionListData.missionStatus;
        missionStatusLabel.textColor=[UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:23.0/255.0 alpha:1.0];
        timeContainerView.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:23.0/255.0 alpha:0.7];
        missionStatusImageView.image=[UIImage imageNamed:@"pending"];
    }
    else if([missionListData.missionStatus isEqualToString:@"complete"]){
        missionStatusLabel.text=@"Completed";
        missionStatusImageView.image=[UIImage imageNamed:@"completed_mission"];
        missionStatusLabel.textColor=[UIColor colorWithRed:161.0/255.0 green:214.0/255.0 blue:82.0/255.0 alpha:1.0];
        timeContainerView.backgroundColor=[UIColor colorWithRed:161.0/255.0 green:214.0/255.0 blue:82.0/255.0 alpha:0.7];
    }
    //set mission image
    [self downloadImages:missionImageView imageUrl:missionListData.missionImage placeholderImage:@"placeholder.png"];
    //set time stamp
    if ([missionListData.status isEqualToString:@"Expired"]) {
        missionTimeLabel.text=@"Expired";
    }
    else {
    missionTimeLabel.text=missionListData.missionStartDate;
    }
}

//get dynamic height
- (CGRect)setDynamicHeight:(CGSize)rectSize textString:(NSString *)textString fontSize:(UIFont *)fontSize{
    CGRect textHeight = [textString
                         boundingRectWithSize:rectSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:fontSize}
                         context:nil];
    return textHeight;
}
#pragma mark - end

#pragma mark - Downloading image using afnetworking
- (void)downloadImages:(UIImageView *)imageView imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = imageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
