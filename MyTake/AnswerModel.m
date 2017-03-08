//
//  AnswerModel.m
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "AnswerModel.h"

@implementation AnswerModel

#pragma mark - Shared instance
+ (instancetype)sharedUser {
    static AnswerModel *answerData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        answerData = [[[self class] alloc] init];
    });
   
    return answerData;
}
#pragma mark - end
@end
