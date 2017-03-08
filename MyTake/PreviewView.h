//
//  PreviewView.h
//  CustomizeRecordNCaptureIamge
//
//  Created by Ranosys on 20/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVCaptureSession;

@interface PreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
