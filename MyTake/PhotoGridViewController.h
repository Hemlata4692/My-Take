//
//  PhotoGridViewController.h
//  MyTake
//
//  Created by Hema on 24/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageUploadViewController.h"

@interface PhotoGridViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *assetsImagesArray;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic,retain)ImageUploadViewController* imageUploadObj;
@end
