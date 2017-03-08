//
//  VideoUploadViewController.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoUploadViewController : MyTakeViewController
@property (strong, nonatomic) NSMutableArray *questionDetailArray;
@property(nonatomic,retain) NSString *videoFilePath;
@property(nonatomic,retain) UIImage *thumbnailImage;
@property(nonatomic,assign) BOOL isVideoExist,isVideoRecord;
@end
