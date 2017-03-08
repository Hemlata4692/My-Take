//
//  UploadMissionModel.h
//  MyTake
//
//  Created by Hema on 01/09/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadMissionModel : NSObject
//submit mission later
- (void)submitMissionLater:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
//mark mission complete
- (void)markMissionComplete:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//upload mission data
- (void)uploadMission:(NSMutableArray *)filePath mediaType:(int)mediaType stepId:(NSString *)stepId requestDict:(NSMutableDictionary *)requestDict success:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
@end
