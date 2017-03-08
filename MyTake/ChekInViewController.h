//
//  ChekInViewController.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChekInViewController : MyTakeViewController
@property (strong, nonatomic) NSMutableArray *questionDetailArray;
@property (strong, nonatomic) NSString *checkInLatitude;
@property (strong, nonatomic) NSString *checkInLongitude;
@property (strong, nonatomic) NSString *otherLocation;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *customLocation;
@end
