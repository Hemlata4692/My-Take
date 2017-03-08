//
//  LoginService.m
//  MyTake
//
//  Created by Hema on 11/04/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "BaseService.h"
@class LoginModel;

@interface LoginService : BaseService
//login user
- (void)loginUser:(LoginModel *)userLogin onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//get community code
- (void)communityCode:(LoginModel *)communityCode onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
//save device token
- (void)saveDeviceToken:(LoginModel *)deviceToken onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
@end
