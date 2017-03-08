//
//  MissionDetailDatabase.m
//  MyTake
//
//  Created by Hema on 04/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionDetailDatabase.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "MissionDetailModel.h"
#import "QuestionModel.h"

@implementation MissionDetailDatabase

#pragma mark - Insert data in database
+ (void)insertDataInMissionDetailTable:(MissionDetailModel *)missionDetailData
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    NSMutableArray *tempArray=[NSMutableArray new];
    tempArray=[missionDetailData.questionsArray mutableCopy];
    [database open];
    if (0==[self checkRecordExists:missionDetailData.missionId]) {
        for (int i=0; i<tempArray.count; i++) {
            QuestionModel *questionDetail=[tempArray objectAtIndex:i];
            NSError *error;
            NSString *attachments;
            NSString *answerOptions;
            NSString *scaleLabels;
            //added try catch block to handle null exception
            @try {
                NSData *attachmentJsonData = [NSJSONSerialization dataWithJSONObject:questionDetail.answerAttachments
                                                                             options:NSJSONWritingPrettyPrinted
                                                                               error:&error];
                attachments = [[NSString alloc] initWithData:attachmentJsonData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, [attachments length]);
                attachments=[attachments stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
                
            } @catch (NSException *exception) {
            }
            @try {
                NSData *answerOptionsData = [NSJSONSerialization dataWithJSONObject:questionDetail.answerOptions
                                                                            options:NSJSONWritingPrettyPrinted
                                                                              error:&error];
                answerOptions = [[NSString alloc] initWithData:answerOptionsData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, [answerOptions length]);
                answerOptions=[answerOptions stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
                
            } @catch (NSException *exception) {
            }
            @try {
                
                NSData *scaleLabelsData = [NSJSONSerialization dataWithJSONObject:questionDetail.scaleLables
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:&error];
                scaleLabels = [[NSString alloc] initWithData:scaleLabelsData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, [scaleLabels length]);
                scaleLabels=[scaleLabels stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
                
            } @catch (NSException *exception) {
            }
            //insert mission details data in database
            [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO mission_question(mission_id,step_id,type,question,attachments,is_why,scale_min,scale_max,allow_no_rate,max_size,scale_labels,answer_options,timestamp,user_id) values('%@','%@','%@',\"%@\",'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",missionDetailData.missionId,questionDetail.questionId,questionDetail.questionType,questionDetail.questionTitle,attachments,questionDetail.isWhy,questionDetail.scaleMinimum,questionDetail.scaleMaximum,questionDetail.allowNoRate,questionDetail.maximumSize,scaleLabels,answerOptions,missionDetailData.missionTimeStamp,[UserDefaultManager getValue:@"userId"]]];
        }
        //update mission table with welcom message and end message
        [database executeUpdate:[NSString stringWithFormat:@"Update mission SET welcome_message = \"%@\",end_message = \"%@\" where mission_id = '%@' AND user_id = '%@'",missionDetailData.welcomeMessage,missionDetailData.endMessage,missionDetailData.missionId,[UserDefaultManager getValue:@"userId"]]];
        [database close];
    }
    else {
        for (int i=0; i<tempArray.count; i++) {
            QuestionModel *questionDetail=[tempArray objectAtIndex:i];
            NSError *error;
            NSString *attachments;
            NSString *answerOptions;
            NSString *scaleLabels;
            //added try catch block to handle null exception
            @try {
                NSData *attachmentJsonData = [NSJSONSerialization dataWithJSONObject:questionDetail.answerAttachments
                                                                             options:NSJSONWritingPrettyPrinted
                                                                               error:&error];
                attachments = [[NSString alloc] initWithData:attachmentJsonData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, [attachments length]);
                attachments=[attachments stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
                
            } @catch (NSException *exception) {
            }
            @try {
                NSData *answerOptionsData = [NSJSONSerialization dataWithJSONObject:questionDetail.answerOptions
                                                                            options:NSJSONWritingPrettyPrinted
                                                                              error:&error];
                answerOptions = [[NSString alloc] initWithData:answerOptionsData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, [answerOptions length]);
                answerOptions=[answerOptions stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
                
            } @catch (NSException *exception) {
            }
            @try {
                
                NSData *scaleLabelsData = [NSJSONSerialization dataWithJSONObject:questionDetail.scaleLables
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:&error];
                scaleLabels = [[NSString alloc] initWithData:scaleLabelsData encoding:NSUTF8StringEncoding];
                NSRange range = NSMakeRange(0, [scaleLabels length]);
                scaleLabels=[scaleLabels stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
                
            } @catch (NSException *exception) {
            }
            //update time stamp of mission in mission detail table if changed
            [database executeUpdate:[NSString stringWithFormat:@"Update mission_question SET timestamp='%@' where user_id = '%@' AND mission_id = '%@'",missionDetailData.missionTimeStamp,[UserDefaultManager getValue:@"userId"],missionDetailData.missionId]];
        }
    }
}
#pragma mark - end

#pragma mark - Fetch data from database
+ (NSMutableArray *) getMissionDetailData
{
    NSMutableArray *missionMessageDataArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    //fetch welcom message and end message
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM mission where mission_id = '%@' AND user_id = '%@'",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    while([results next])
    {
        MissionDetailModel *missionDetail = [[MissionDetailModel alloc] init];
        missionDetail.welcomeMessage = [results stringForColumn:@"welcome_message"];
        missionDetail.endMessage = [results stringForColumn:@"end_message"];
        [missionMessageDataArray addObject:missionDetail];
    }
    [db close];
    return missionMessageDataArray;
}

+ (NSMutableArray *) getQuestionDetail {
    NSMutableArray *questionDetailsArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    //fetch questions of mission
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM mission_question where mission_id = '%@' AND user_id ='%@'",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    while([results next])
    {
        QuestionModel *questionDetail = [[QuestionModel alloc] init];
        questionDetail.questionId = [results stringForColumn:@"step_id"];
        questionDetail.questionTitle = [results stringForColumn:@"question"];
        questionDetail.questionType = [results stringForColumn:@"type"];
        questionDetail.isWhy = [results stringForColumn:@"is_why"];
        questionDetail.scaleMaximum = [results stringForColumn:@"scale_max"];
        questionDetail.scaleMinimum = [results stringForColumn:@"scale_min"];
        questionDetail.allowNoRate = [results stringForColumn:@"allow_no_rate"];
        questionDetail.maximumSize = [results stringForColumn:@"max_size"];
        questionDetail.missionTimeStamp = [results stringForColumn:@"timestamp"];
        NSError *error = nil;
        //added try catch block to handle null exception
        @try {
            NSData * data = [[results stringForColumn:@"attachments"] dataUsingEncoding:NSUTF8StringEncoding];
            questionDetail.answerAttachments = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
        }
        @try {
            NSData * data = [[results stringForColumn:@"answer_options"] dataUsingEncoding:NSUTF8StringEncoding];
            questionDetail.answerOptions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
        }
        @try {
            NSData * data = [[results stringForColumn:@"scale_labels"] dataUsingEncoding:NSUTF8StringEncoding];
            questionDetail.scaleLables = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
        }
        [questionDetailsArray addObject:questionDetail];
    }
    [db close];
    return questionDetailsArray;
}
#pragma mark - end

#pragma mark - Check record exists in database
//check if record exists for same user and same mission
+ (int) checkRecordExists:(NSString *)missionId {
    int count = 0;
    sqlite3 *database = nil;
    if (sqlite3_open([[myDelegate getDBPath] UTF8String], &database) == SQLITE_OK)
    {
        NSString *query=[NSString stringWithFormat:@"SELECT COUNT(*) FROM mission_question where mission_id='%@' AND user_id = '%@'",missionId,[UserDefaultManager getValue:@"userId"]];
        const char* sqlStatement = [query UTF8String];
        sqlite3_stmt *statement;
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return count;
}
#pragma mark - end
@end
