//
//  ImageUploadViewController.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageUploadViewController : MyTakeViewController
@property (strong, nonatomic) NSMutableArray *questionDetailArray;
@property(nonatomic,retain) NSString *imagePath;
@property(nonatomic,assign)int maximumSize;
@property(nonatomic,assign)float imageFileSize;
@property(strong, nonatomic) NSMutableArray *getPathOfSelectedImagesArray;
@end
