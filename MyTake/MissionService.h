//
//  MissionService.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"
@class MissionDataModel;
@class MissionDetailModel;
@class UploadMissionModel;

@interface MissionService : BaseService

//Mission list
- (void)getMissionList:(MissionDataModel *)missionData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Mission detail
- (void)getMissionDetail:(MissionDetailModel *)missionData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Submit later
- (void)submitMissionLater:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Mission completed
- (void)markMissionComplete:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//Upload mission data
- (void)uploadMission:(NSMutableArray *)filePath mediaType:(int)mediaType stepId:(NSString *)stepId requestDict:(NSMutableDictionary *)requestDict success:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
@end
