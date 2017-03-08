//
//  AnswerModel.h
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnswerModel : NSObject
@property (strong, nonatomic) NSString *stepId;
@property (strong, nonatomic) NSString *missionId;
@property (strong, nonatomic) NSString *longTextResponse;
@property (strong, nonatomic) NSString *emojiResponse;
@property (strong, nonatomic) NSString *ratingResponse;
@property (strong, nonatomic) NSString *ratingWhyResponse;
@property (strong, nonatomic) NSString *singleAnswer;
@property (strong, nonatomic) NSMutableDictionary *multiAnswerDict;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *textDisplay;
@property (strong, nonatomic) NSString *audioPath;
@property (strong, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSString *imageFolder;
@property (strong, nonatomic) NSString *stepType;
@property (strong, nonatomic) NSString *isAnswerUploaded;
+ (instancetype)sharedUser;
@end
