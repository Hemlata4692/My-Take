//
//  MissionDataModel.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionDataModel.h"
#import "ConnectionManager.h"
#import "MissionListDatabase.h"

@implementation MissionDataModel

#pragma mark - Shared instance
+ (instancetype)sharedUser{
    __block MissionDataModel *missionModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        missionModel = [[[self class] alloc] init];
    });
    return missionModel;
}
#pragma mark - end

#pragma mark - Missions list
- (void)getMissionListOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure{
    [[ConnectionManager sharedManager] getMissionList:self onSuccess:^(id dataArray) {
        if (success) {
            NSMutableArray * alreadyStoredArray;
            NSMutableDictionary *alreadyStoredDataDictionary;
            @try {
                //fetch already stored data from database
                alreadyStoredArray = [MissionListDatabase getMisionsList];
                alreadyStoredDataDictionary=[NSMutableDictionary new];
                for (int i=0; i<alreadyStoredArray.count; i++) {
                    [alreadyStoredDataDictionary setObject:@"NO" forKey:[[alreadyStoredArray objectAtIndex:i]missionId]];
                }
            } @catch (NSException *exception) {
            }
            if (alreadyStoredArray.count==0) {
                for (int i=0; i<[dataArray count]; i++) {
                    //insert mission list data in database
                    [MissionListDatabase insertDataInMissionTable:[dataArray objectAtIndex:i]];
                }
            }
            else {
                for (int i=0; i<[dataArray count]; i++) {
                    for (int j=0; j<[alreadyStoredArray count]; j++) {
                       //if already stored array and server data array has same mission id
                        if([[[dataArray objectAtIndex:i]missionId] intValue]==[[[alreadyStoredArray objectAtIndex:j]missionId]intValue]) {
                            [alreadyStoredDataDictionary setObject:@"YES" forKey:[[alreadyStoredArray objectAtIndex:j]missionId]];
                            
                            if (([[[dataArray objectAtIndex:i]missionId] intValue] ==[[[alreadyStoredArray objectAtIndex:j]missionId] intValue]) && (![[[dataArray objectAtIndex:i]missionStatus] isEqualToString:@"none"])) {
                                [MissionListDatabase updateDataIfStatusChanged:[dataArray objectAtIndex:i] missionStatus:[[dataArray objectAtIndex:i]missionStatus]];
                            }
                            else if ([[[dataArray objectAtIndex:i]missionId] intValue] ==[[[alreadyStoredArray objectAtIndex:j]missionId] intValue] && ([[[alreadyStoredArray objectAtIndex:j]missionStatus] isEqualToString:@"In Progress"])) {
                                [MissionListDatabase updateDataIfStatusChanged:[dataArray objectAtIndex:i] missionStatus:@"In Progress"];
                            }
                            else if([[[dataArray objectAtIndex:i]missionId] intValue]==[[[alreadyStoredArray objectAtIndex:j]missionId]intValue]){
                                [MissionListDatabase updateDataIfStatusChanged:[dataArray objectAtIndex:i] missionStatus:[[dataArray objectAtIndex:i]missionStatus]];
                            }
                        }
                        //if mission id does not exists insert in database
                        else {
                            //insert mission list data in database
                            [MissionListDatabase insertDataInMissionTable:[dataArray objectAtIndex:i]];
                        }
                    }
                }
                //delete record from database if mission id does not exists in server records
                for (int i=0; i<alreadyStoredArray.count; i++) {
                    if ([[alreadyStoredDataDictionary valueForKey:[[alreadyStoredArray objectAtIndex:i]missionId]] isEqualToString:@"NO"]) {
                        [MissionListDatabase deleteDataFromMissionList:[alreadyStoredArray objectAtIndex:i]];
                    }
                }
            }
            [dataArray removeAllObjects];
            //fetch mission list from database
            dataArray = [MissionListDatabase getMisionsList];
            success (dataArray);
        }
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end
@end
