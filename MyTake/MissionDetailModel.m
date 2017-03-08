//
//  MissionDetailModel.m
//  MyTake
//
//  Created by Hema on 01/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionDetailModel.h"
#import "ConnectionManager.h"
#import "MissionDetailDatabase.h"

@implementation MissionDetailModel
#pragma mark - Shared instance
+ (instancetype)sharedUser{
    static MissionDetailModel *missionDetailModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        missionDetailModel = [[[self class] alloc] init];
    });
    return missionDetailModel;
}
#pragma mark - end

#pragma mark - Missions list
- (void)getMissionDetailOnSuccess:(NSString *)timeStamp success:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    self.missionTimeStamp=timeStamp;
    [[ConnectionManager sharedManager] getMissionDetail:self onSuccess:^(id dataArray) {
        if (success) {
            //insert mission setail data in database
            [MissionDetailDatabase insertDataInMissionDetailTable:dataArray];
            dataArray=[NSMutableArray new];
            //fetch questions detail data from database
            dataArray = [MissionDetailDatabase getMissionDetailData];
            success (dataArray);
        }
    } onFailure:^(NSError *error) {
         failure(error);
    }] ;
}
#pragma mark - end

@end
