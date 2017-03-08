//
//  ImagePreviewViewController.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageUploadViewController.h"

@interface ImagePreviewViewController : UIViewController
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSMutableArray *attachmentArray;
@property(nonatomic,assign)int selectedIndex;
@property (strong, nonatomic) NSString *screenName;
@property(nonatomic,retain)ImageUploadViewController* imageUploadObj;
@end
