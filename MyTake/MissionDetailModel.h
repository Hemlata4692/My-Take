//
//  MissionDetailModel.h
//  MyTake
//
//  Created by Hema on 01/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissionDetailModel : NSObject
@property (strong, nonatomic) NSString *welcomeMessage;
@property (strong, nonatomic) NSString *endMessage;
@property (strong, nonatomic) NSString *missionId;
@property (strong, nonatomic) NSString *missionTimeStamp;
@property (strong, nonatomic) NSMutableArray *questionsArray;
+ (instancetype)sharedUser;
//get all missions
- (void)getMissionDetailOnSuccess:(NSString *)timeStamp success:(void (^)(id))success onfailure:(void (^)(NSError *))failure;
@end
