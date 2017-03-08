//
//  AnswerOptionsModel.h
//  MyTake
//
//  Created by Hema on 03/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnswerOptionsModel : NSObject
@property (strong, nonatomic) NSString *answerId;
@property (strong, nonatomic) NSString *answerText;
@property (strong, nonatomic) NSString *answerImage;
@property (strong, nonatomic) NSString *answerThumbnailImage;
@property (strong, nonatomic) NSString *isExclusive;
@property (strong, nonatomic) NSString *isOther;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) float dynamicCellHeight;
@end
