//
//  LoginService.m
//  MyTake
//
//  Created by Hema on 11/04/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

static NSString *apiToken=@"h5eOg19Ch86G4Zb3V7iiBL0Yl01xQ581";
static NSString *kCommunityCode=@"getCommunityFromCode";
static NSString *kUserLogin=@"/api/mobile/getLogin";
static NSString *kDeviceToken=@"/api/mobile/saveDeviceToken";

#import "LoginService.h"
#import "LoginModel.h"

@implementation LoginService

#pragma mark - Get communit code
- (void)communityCode:(LoginModel *)communityCode onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"code" : communityCode.code,
                                 @"api_token" : apiToken};
    [super getCommunitycode:kCommunityCode parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark - end
#pragma mark - Save device token
- (void)saveDeviceToken:(LoginModel *)deviceToken onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters;
    @try {
        parameters = @{@"api_token" : deviceToken.apiKey,
                                     @"dt" : [UserDefaultManager getValue:@"deviceToken"]};
    } @catch (NSException *exception) {
    }
    super.baseUrl=deviceToken.baseUrl;
    [super post:kDeviceToken parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark - end

#pragma mark - Login user
- (void)loginUser:(LoginModel *)userLogin onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"username" : userLogin.userName,
                                 @"password" : userLogin.password};
    super.baseUrl=userLogin.baseUrl;
    [super post:kUserLogin parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark - end

@end
