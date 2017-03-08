//
//  PreviewView.m
//  CustomizeRecordNCaptureIamge
//
//  Created by Ranosys on 20/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "PreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}
@end
