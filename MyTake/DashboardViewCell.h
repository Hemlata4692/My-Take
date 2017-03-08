//
//  DashboardViewCell.h
//  MyTake
//
//  Created by Hema on 29/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MissionDataModel.h"

@interface DashboardViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *topSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *missionStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *missionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomSeparator;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *missionImageView;
@property (weak, nonatomic) IBOutlet UILabel *missionNameLabel;
@property (weak, nonatomic) IBOutlet UIView *timeContainerView;
@property (weak, nonatomic) IBOutlet UILabel *missionTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
//Display data on cell
- (void)displayMissionListData :(MissionDataModel *)missionListData indexPath:(int)indexPath;
@end
