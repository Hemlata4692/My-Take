//
//  UploadMissionModel.m
//  MyTake
//
//  Created by Hema on 01/09/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "UploadMissionModel.h"
#import "ConnectionManager.h"

@implementation UploadMissionModel

#pragma mark - Missions detail
- (void)submitMissionLater:(void (^)(id))success onfailure:(void (^)(NSError *))failure {
    [[ConnectionManager sharedManager] submitMissionLater:^(id response) {
        if (success) {
            success (response);
        }
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end

#pragma mark - Upload mission
- (void)uploadMission:(NSMutableArray *)filePath mediaType:(int)mediaType stepId:(NSString *)stepId requestDict:(NSMutableDictionary *)requestDict success:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    [[ConnectionManager sharedManager] uploadMission:filePath mediaType:mediaType stepId:stepId requestDict:requestDict success:^(id response) {
        if (success) {
            success (response);
        }
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end

#pragma mark - Mark mission complete
- (void)markMissionComplete:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    [[ConnectionManager sharedManager] markMissionComplete:^(id response) {
        if (success) {
            success (response);
        }
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end
@end
