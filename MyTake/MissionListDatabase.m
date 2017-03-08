//
//  MissionListDatabase.m
//  MyTake
//
//  Created by Hema on 02/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionListDatabase.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "MissionDataModel.h"

@implementation MissionListDatabase

#pragma mark - Insert data in database
+ (void)insertDataInMissionTable:(MissionDataModel *)missionListData
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    //insert data in mission table
    if (0==[self checkRecordExists:missionListData.missionId]) {
        [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO mission(user_id,mission_id,mission_status,mission_image,mission_title,mission_startdate,mission_enddate,timestamp,status,sort_date) values('%@','%@','%@','%@','%@','%@','%@','%@','%@', '%@')",[UserDefaultManager getValue:@"userId"],missionListData.missionId,missionListData.missionStatus,missionListData.missionImage,missionListData.missionTitle,missionListData.missionStartDate,missionListData.missionEndDate,missionListData.timeStamp,missionListData.status,missionListData.sortDate]];
    }
    //update mission table data if time stamp is changed
    else {
        [database executeUpdate:[NSString stringWithFormat:@"Update mission SET user_id = '%@',mission_id = '%@',mission_status = '%@',mission_image = '%@',mission_title = '%@',mission_startdate = '%@',mission_enddate = '%@',timestamp = '%@',status ='%@',sort_date ='%@' where user_id = '%@' AND timestamp != '%@' AND mission_id = '%@'",[UserDefaultManager getValue:@"userId"],missionListData.missionId,missionListData.missionStatus,missionListData.missionImage,missionListData.missionTitle,missionListData.missionStartDate,missionListData.missionEndDate,missionListData.timeStamp,missionListData.status,missionListData.sortDate,[UserDefaultManager getValue:@"userId"],missionListData.timeStamp,missionListData.missionId]];
    }
    [database close];
}

+ (void)updateDataIfStatusChanged:(MissionDataModel *)missionListData missionStatus:(NSString *)missionStatus {
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    //update mission table if mission status is changed
    [database executeUpdate:[NSString stringWithFormat:@"Update mission SET user_id = '%@',mission_id = '%@',mission_status = '%@',mission_image = '%@',mission_title = '%@',mission_startdate = '%@',mission_enddate = '%@',timestamp = '%@',status ='%@',sort_date ='%@' where user_id = '%@' AND mission_id = '%@'",[UserDefaultManager getValue:@"userId"],missionListData.missionId,missionStatus,missionListData.missionImage,missionListData.missionTitle,missionListData.missionStartDate,missionListData.missionEndDate,missionListData.timeStamp,missionListData.status,missionListData.sortDate,[UserDefaultManager getValue:@"userId"],missionListData.missionId]];
    [database close];
}
#pragma mark - end

#pragma mark - Update data in database
+ (void)updateDataInMissionTableAfterMissionStarted:(MissionDataModel *)missionList
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    //update mission status after starting mission
    [database executeUpdate:[NSString stringWithFormat:@"UPDATE mission SET mission_status = '%@' where user_id = '%@' AND mission_id = '%@'",missionList.missionStatus,[UserDefaultManager getValue:@"userId"],[UserDefaultManager getValue:@"missionId"]]];
    [database close];
}

#pragma mark - end

#pragma mark - Delete data from database
+ (void)deleteDataFromMissionList:(MissionDataModel *)missionList
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    //delete mission
    [database executeUpdate:[NSString stringWithFormat:@"DELETE FROM mission where user_id = '%@' AND mission_id = '%@'",[UserDefaultManager getValue:@"userId"],missionList.missionId]];
    [database close];
}

#pragma mark - end


#pragma mark - Fetch data from database
+ (NSMutableArray *) getMisionsList
{
    NSMutableArray *missionArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    //fetch mission list
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM mission where user_id = '%@' order  by datetime(sort_date) DESC",[UserDefaultManager getValue:@"userId"]]];
    while([results next])
    {
        MissionDataModel *missionList = [[MissionDataModel alloc] init];
        missionList.missionId = [results stringForColumn:@"mission_id"];
        missionList.missionStatus = [results stringForColumn:@"mission_status"];
        missionList.missionImage = [results stringForColumn:@"mission_image"];
        missionList.missionTitle = [results stringForColumn:@"mission_title"];
        missionList.missionStartDate = [results stringForColumn:@"mission_startdate"];
        missionList.missionEndDate = [results stringForColumn:@"mission_enddate"];
        missionList.timeStamp = [results stringForColumn:@"timestamp"];
        missionList.status = [results stringForColumn:@"status"];
        missionList.sortDate = [results stringForColumn:@"sort_date"];
        [missionArray addObject:missionList];
    }
    [db close];
    return missionArray;
}

//fetch misison list data for particular mission
+ (NSMutableArray *) getMisionsListFromMisionId
{
    NSMutableArray *missionArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    //fetch misison list data for particular mission
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM mission where user_id = '%@' AND mission_id = '%@'",[UserDefaultManager getValue:@"userId"],[UserDefaultManager getValue:@"missionId"]]];
    while([results next])
    {
        MissionDataModel *missionList = [[MissionDataModel alloc] init];
        missionList.missionId = [results stringForColumn:@"mission_id"];
        missionList.missionStatus = [results stringForColumn:@"mission_status"];
        missionList.missionImage = [results stringForColumn:@"mission_image"];
        missionList.missionTitle = [results stringForColumn:@"mission_title"];
        missionList.missionStartDate = [results stringForColumn:@"mission_startdate"];
        missionList.missionEndDate = [results stringForColumn:@"mission_enddate"];
        missionList.timeStamp = [results stringForColumn:@"timestamp"];
        missionList.status = [results stringForColumn:@"status"];
        missionList.sortDate = [results stringForColumn:@"sort_date"];
        [missionArray addObject:missionList];
    }
    [db close];
    return missionArray;
}

#pragma mark - end

#pragma mark - Check record exists in database
+ (int) checkRecordExists:(NSString *)missionId {
    int count = 0;
    sqlite3 *database = nil;
    if (sqlite3_open([[myDelegate getDBPath] UTF8String], &database) == SQLITE_OK)
    {
        //check if record exists for same user and same mission
        NSString *query=[NSString stringWithFormat:@"SELECT COUNT(*) FROM mission where user_id = '%@' AND mission_id = '%@'",[UserDefaultManager getValue:@"userId"],missionId];
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
