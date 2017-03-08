//
//  LoginModel.h
//  MyTake
//
//  Created by Hema on 19/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginModel : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *apiToken;
@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userImage;
@property (strong, nonatomic) NSString *userThumbnailImage;

+ (instancetype)sharedUser;
//login user
- (void)loginUserOnSuccess:(void (^)(LoginModel *))success onfailure:(void (^)(NSError *))failure;
//get community code
- (void)communityCodeOnSuccess:(void (^)(LoginModel *))success onfailure:(void (^)(NSError *))failure;
//save devcie token
- (void)saveDeviceToken:(void (^)(LoginModel *))success onfailure:(void (^)(NSError *))failure;
@end
