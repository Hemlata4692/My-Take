//
//  CustomVideoViewController.h
//  MyTake
//
//  Created by Ranosys on 23/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoUploadViewController.h"

@interface CustomVideoViewController : UIViewController
@property(nonatomic,retain)NSString* videoFilePath;
@property(nonatomic,assign)int maxSize;
@property(nonatomic,retain)VideoUploadViewController* videoUploadViewObj;
@end
