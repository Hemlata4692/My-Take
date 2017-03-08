//
//  MissionListDatabase.h
//  MyTake
//
//  Created by Hema on 02/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MissionDataModel;
@interface MissionListDatabase : NSObject

+ (void)insertDataInMissionTable:(MissionDataModel *)missionListData;
+ (void)updateDataIfStatusChanged:(MissionDataModel *)missionListData missionStatus:(NSString *)missionStatus;
+ (void)updateDataInMissionTableAfterMissionStarted:(MissionDataModel *)missionList;
+ (NSMutableArray *)getMisionsList;
+ (NSMutableArray *) getMisionsListFromMisionId;
+ (void)deleteDataFromMissionList:(MissionDataModel *)missionList;
@end
