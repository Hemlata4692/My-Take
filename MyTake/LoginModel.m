//
//  LoginModel.m
//  MyTake
//
//  Created by Hema on 19/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "LoginModel.h"
#import "ConnectionManager.h"

@implementation LoginModel

#pragma mark - Shared instance
+ (instancetype)sharedUser{
    static LoginModel *loginUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginUser = [[[self class] alloc] init];
    });
    
    return loginUser;
}
#pragma mark - end

#pragma mark - Community code
- (void)communityCodeOnSuccess:(void (^)(LoginModel *))success onfailure:(void (^)(NSError *))failure {
    [[ConnectionManager sharedManager] communityCode:self onSuccess:^(LoginModel *userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - Login user
- (void)loginUserOnSuccess:(void (^)(LoginModel *))success onfailure:(void (^)(NSError *))failure{
    [[ConnectionManager sharedManager] loginUser:self onSuccess:^(LoginModel *userData) {
        if (success) {
            //set user data in defaults
            
            [UserDefaultManager setValue:userData.userName key:@"userName"];
            [UserDefaultManager setValue:userData.userImage key:@"userImage"];
            [UserDefaultManager setValue:[NSString stringWithFormat:@"%@_%@",userData.code,userData.userId] key:@"userId"];
            [UserDefaultManager setValue:userData.password key:@"password"];
            [UserDefaultManager setValue:userData.code key:@"accessCode"];
            [UserDefaultManager setValue:userData.apiKey key:@"apiKey"];
            [UserDefaultManager setValue:userData.baseUrl key:@"communityLink"];
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end
#pragma mark - save device token
- (void)saveDeviceToken:(void (^)(LoginModel *))success onfailure:(void (^)(NSError *))failure{
    [[ConnectionManager sharedManager] sendDevcieToken:self onSuccess:^(LoginModel *userData) {
        if (success) {
            success (userData);
        }
    } onFailure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end
@end
