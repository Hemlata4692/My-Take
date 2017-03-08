//
//  MissionDataModel.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissionDataModel : NSObject
@property (strong, nonatomic) NSString *missionEndDate;
@property (strong, nonatomic) NSString *missionImage;
@property (strong, nonatomic) NSString *missionId;
@property (strong, nonatomic) NSString *missionStatus;
@property (strong, nonatomic) NSString *missionStartDate;
@property (strong, nonatomic) NSString *timeStamp;
@property (strong, nonatomic) NSString *missionTitle;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *sortDate;

+ (instancetype)sharedUser;
//get all missions
- (void)getMissionListOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
@end
