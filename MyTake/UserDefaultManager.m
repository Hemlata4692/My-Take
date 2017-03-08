//
//  UserDefaultManager.m
//
//  Created by Sumit on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "UserDefaultManager.h"

@implementation UserDefaultManager

+ (void)setValue:(id)value key:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (id)getValue:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

+ (void)removeValue:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
}

//set progress dict for every question
+ (void)setDictValue:(int)progressStep totalCount:(int)totalCount {
    NSMutableDictionary * progressDict;
    if (nil==[UserDefaultManager getValue:@"progressDict"])
        {
        progressDict=[[NSMutableDictionary alloc]init];
        }
        else{
        progressDict=[[UserDefaultManager getValue:@"progressDict"] mutableCopy];
        }
    
    [progressDict setObject:[NSString stringWithFormat:@"%d,%d",progressStep,totalCount] forKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    [UserDefaultManager setValue:progressDict key:@"progressDict"];

}

//set instruction value in popup
+ (void)setInstruction:(id)value key:(NSString *)key {
    NSMutableDictionary * instructionDict;
    if (nil==[UserDefaultManager getValue:@"InstructionPopUp"])
    {
        instructionDict=[[NSMutableDictionary alloc]init];
    }
    else{
        instructionDict=[[UserDefaultManager getValue:@"InstructionPopUp"] mutableCopy];
    }
    
    [instructionDict setObject:value forKey:key];
    [UserDefaultManager setValue:instructionDict key:@"InstructionPopUp"];
}

//save file size for every answer
+ (void)setAnswerFileSize:(double )size {
    NSMutableDictionary * fileSizeDict;
    if (nil==[UserDefaultManager getValue:@"fileSizeDict"]) {
        fileSizeDict=[[NSMutableDictionary alloc]init];
    }
    else {
        fileSizeDict=[[UserDefaultManager getValue:@"fileSizeDict"] mutableCopy];
        size+=[[fileSizeDict objectForKey:[NSString stringWithFormat:@"fileSize_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] doubleValue];
    }
    [fileSizeDict setObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:size]] forKey:[NSString stringWithFormat:@"fileSize_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    [UserDefaultManager setValue:fileSizeDict key:@"fileSizeDict"];
}

//save screen for mission
+ (void)setScreenSubmission:(NSString *)isAnsweredAllQuestion {
    NSMutableDictionary * screenSubmissionDict;
    if (nil==[UserDefaultManager getValue:@"screenSubmissionDict"]) {
        screenSubmissionDict=[[NSMutableDictionary alloc]init];
    }
    else {
        screenSubmissionDict=[[UserDefaultManager getValue:@"screenSubmissionDict"] mutableCopy];
       
    }
    [screenSubmissionDict setObject:[NSString stringWithFormat:@"%@",isAnsweredAllQuestion] forKey:[NSString stringWithFormat:@"answeredMission_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    [UserDefaultManager setValue:screenSubmissionDict key:@"screenSubmissionDict"];
}

@end
