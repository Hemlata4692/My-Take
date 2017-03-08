//
//  UserDefaultManager.h
//
//  Created by Sumit on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultManager : NSObject
+ (void)setValue : (id)value key :(NSString *)key;
+ (id)getValue : (NSString *)key;
+ (void)removeValue : (NSString *)key;
+ (void)setDictValue:(int)progressStep totalCount:(int)totalCount;
+ (void)setAnswerFileSize:(double )size;
+ (void)setScreenSubmission:(NSString *)isAnsweredAllQuestion;
@end
