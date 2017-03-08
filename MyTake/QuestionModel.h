//
//  QuestionDataModel.h
//  MyTake
//
//  Created by Hema on 03/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionModel : NSObject
@property (strong, nonatomic) NSMutableArray *answerOptions;
@property (strong, nonatomic) NSMutableArray *answerAttachments;
@property (strong, nonatomic) NSString *questionId;
@property (strong, nonatomic) NSString *questionType;
@property (strong, nonatomic) NSString *questionTitle;
@property (strong, nonatomic) NSString *allowNoRate;
@property (strong, nonatomic) NSString *isWhy;
@property (strong, nonatomic) NSString *scaleMaximum;
@property (strong, nonatomic) NSString *scaleMinimum;
@property (strong, nonatomic) NSDictionary *scaleLables;
@property (strong, nonatomic) NSString *maximumSize;
@property (strong, nonatomic) NSString *missionTimeStamp;
@end
