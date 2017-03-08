//
//  Webservice.h
//  MyTake
//
//  Created by Hema on 11/04/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface BaseService : NSObject
@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;

- (void)getCommunitycode:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)get:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure;
- (void)post:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id response))success onFailure:(void (^)(NSError *error))failure;
- (BOOL)isStatusOK:(id)responseObject;
@end
