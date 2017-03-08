//
//  GlobalImageVideoViewController.h
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalImageVideoViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *attachmentsArray;
@property (weak, nonatomic) IBOutlet UICollectionView *imageVideoCollectionView;
@end
