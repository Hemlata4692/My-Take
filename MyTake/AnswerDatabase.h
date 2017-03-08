//
//  AnswerDatabase.h
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnswerModel;
@interface AnswerDatabase : NSObject
+ (void)insertDataInAnswerTable:(AnswerModel *)answerData;
+ (void)updateDataInAnswerTable:(AnswerModel *)answerData;
+ (NSMutableArray *) getAnswerDetails;
+ (int) checkRecordExistsForPendingSubmission;
@end
