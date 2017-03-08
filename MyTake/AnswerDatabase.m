//
//  AnswerDatabase.m
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "AnswerDatabase.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "AnswerModel.h"

@implementation AnswerDatabase
#pragma mark - Insert data in database
+ (void)insertDataInAnswerTable:(AnswerModel *)answerData
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    NSError *error;
    NSString *multiAnswer;
    //added try catch block to handle null exception
    @try {
        
        NSData *multiAnswerData = [NSJSONSerialization dataWithJSONObject:answerData.multiAnswerDict
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:&error];
        multiAnswer = [[NSString alloc] initWithData:multiAnswerData encoding:NSUTF8StringEncoding];
        
        NSRange range = NSMakeRange(0, [multiAnswer length]);
        multiAnswer=[multiAnswer stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
        
    } @catch (NSException *exception) {
    }
    //insert answer in answer table
    answerData.isAnswerUploaded=@"No";
    if (0==[self checkRecordExists:answerData.stepId]){
        [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO mission_answer(mission_id,step_id,emoji,longtext_response,rating,rating_why_response,single_answer,multi_answer,place_name,latitude,longitude,text_display,audio_path,video_path,image_folder,isAnswerUploaded,user_id) values('%@','%@','%@',\"%@\",'%@',\"%@\",'%@','%@',\"%@\",'%f','%f','%@','%@','%@','%@','%@','%@')",[UserDefaultManager getValue:@"missionId"],answerData.stepId,answerData.emojiResponse,answerData.longTextResponse,answerData.ratingResponse,answerData.ratingWhyResponse,answerData.singleAnswer,multiAnswer,answerData.placeName,[answerData.latitude doubleValue],[answerData.longitude doubleValue],answerData.textDisplay,answerData.audioPath,answerData.videoPath,answerData.imageFolder,answerData.isAnswerUploaded,[UserDefaultManager getValue:@"userId"]]];
    }
    //update answer if already exists
    else {
        [database executeUpdate:[NSString stringWithFormat:@"Update mission_answer SET mission_id= '%@',step_id= '%@',emoji= '%@',longtext_response= \"%@\",rating= '%@',rating_why_response= \"%@\",single_answer= \"%@\",multi_answer= \"%@\",place_name= \"%@\",latitude= '%f',longitude= '%f',text_display= '%@',audio_path= '%@',video_path= '%@',image_folder= '%@',isAnswerUploaded= '%@',user_id= '%@' where step_id = '%@' AND mission_id = '%@' AND user_id = '%@'",[UserDefaultManager getValue:@"missionId"],answerData.stepId,answerData.emojiResponse,answerData.longTextResponse,answerData.ratingResponse,answerData.ratingWhyResponse,answerData.singleAnswer,multiAnswer,answerData.placeName,[answerData.latitude doubleValue],[answerData.longitude doubleValue],answerData.textDisplay,answerData.audioPath,answerData.videoPath,answerData.imageFolder,answerData.isAnswerUploaded,[UserDefaultManager getValue:@"userId"],answerData.stepId,[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    }
    [database close];
    
}
#pragma mark - end

#pragma mark - Check record exists in database
+ (int) checkRecordExists:(NSString *)stepId
{
    int count = 0;
    sqlite3 *database = nil;
    if (sqlite3_open([[myDelegate getDBPath] UTF8String], &database) == SQLITE_OK)
    {
        //check if record exists for same user and same mission
        NSString *query=[NSString stringWithFormat:@"SELECT COUNT(*) FROM mission_answer where mission_id='%@' AND user_id = '%@' AND step_id = '%@'",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"],stepId];
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

//check if record exists for same user and same mission
+ (int) checkRecordExistsForPendingSubmission
{
    int count = 0;
    sqlite3 *database = nil;
    if (sqlite3_open([[myDelegate getDBPath] UTF8String], &database) == SQLITE_OK)
    {
        NSString *query=[NSString stringWithFormat:@"SELECT COUNT(*) FROM mission_answer where mission_id='%@' AND user_id = '%@'",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]];
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

#pragma mark - Update data in database
+ (void)updateDataInAnswerTable:(AnswerModel *)answerData
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    NSError *error;
    NSString *multiAnswer;
    //added try catch block to handle null exception
    @try {
        
        NSData *multiAnswerData = [NSJSONSerialization dataWithJSONObject:answerData.multiAnswerDict
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:&error];
        multiAnswer = [[NSString alloc] initWithData:multiAnswerData encoding:NSUTF8StringEncoding];
        
    } @catch (NSException *exception) {
    }
    answerData.isAnswerUploaded=@"Yes";
    //update answer status in answer table
    [database executeUpdate:[NSString stringWithFormat:@"Update mission_answer SET isAnswerUploaded = '%@' where step_id = '%@' AND mission_id = '%@' AND user_id = '%@'",answerData.isAnswerUploaded,answerData.stepId,[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]];
    [database close];
}
#pragma mark - end

#pragma mark - Fetch answer from database
+ (NSMutableArray *) getAnswerDetails {
    //get answer deatial with question type from question table
    NSMutableArray *answerArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT mission_answer.*,mission_question.type  FROM mission_answer LEFT OUTER JOIN mission_question ON mission_question.mission_id=mission_answer.mission_id AND mission_question.step_id=mission_answer.step_id  WHERE mission_answer.step_id !=-1000 AND mission_answer.isAnswerUploaded='No' AND mission_answer.mission_id=%@ AND mission_answer.user_id='%@' AND mission_question.user_id='%@'",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"],[UserDefaultManager getValue:@"userId"]]];
    while([results next])
    {
        AnswerModel *answerData = [[AnswerModel alloc] init];
        answerData.stepId = [results stringForColumn:@"step_id"];
        answerData.longTextResponse = [results stringForColumn:@"longtext_response"];
        answerData.ratingResponse = [results stringForColumn:@"rating"];
        answerData.ratingWhyResponse = [results stringForColumn:@"rating_why_response"];
        answerData.singleAnswer = [results stringForColumn:@"single_answer"];
        answerData.emojiResponse = [results stringForColumn:@"emoji"];
        answerData.placeName = [results stringForColumn:@"place_name"];
        answerData.latitude = [results stringForColumn:@"latitude"];
        answerData.longitude = [results stringForColumn:@"longitude"];
        answerData.audioPath = [results stringForColumn:@"audio_path"];
        answerData.videoPath = [results stringForColumn:@"video_path"];
        answerData.imageFolder = [results stringForColumn:@"image_folder"];
        answerData.stepType=[results stringForColumn:@"type"];
        NSError *error = nil;
        //added try catch block to handle null exception
        @try {
            NSData * data = [[results stringForColumn:@"multi_answer"] dataUsingEncoding:NSUTF8StringEncoding];
            answerData.multiAnswerDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
        }
        [answerArray addObject:answerData];
    }
    [db close];
    return answerArray;
}
#pragma mark - end

@end
