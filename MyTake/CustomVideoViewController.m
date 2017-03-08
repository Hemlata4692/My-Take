//
//  CustomVideoViewController.m
//  MyTake
//
//  Created by Ranosys on 23/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "CustomVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PreviewView.h"
#import "UIView+Toast.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CustomVideoViewController ()<AVCaptureFileOutputRecordingDelegate>{
    unsigned long long imageSize;
    NSTimer *videoTimer;
    int second, minute, hour, continousSecond;
    UIButton *revertButton;
    NSString* tempFilePath;
    UIButton *closeButton;
}
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, weak) IBOutlet PreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) BOOL lockInterfaceRotation;
@end

@implementation CustomVideoViewController
@synthesize videoFilePath, maxSize, videoUploadViewObj;

#pragma mark - Camera authorization
- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}
#pragma mark - end

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [[self captureButton] setSelected:NO];
    //Set image at capture button with different states
    [self.captureButton setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
    [self.captureButton setImage:[UIImage imageNamed:@"recordplay"] forState:UIControlStateSelected];
    // Create the AVCaptureSession
    [self avCaptureSessionMethod];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].idleTimerDisabled = YES;  //Disable sleep mode
    [self viewCustomisation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //set timer invalidate when view disappears
    [UIApplication sharedApplication].idleTimerDisabled = NO;   //Enable sleep mode
    [videoTimer invalidate];
    videoTimer = nil;
    continousSecond = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        //emove video session observer when view disappears
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

- (void) viewCustomisation {
    //    switchCameraiPhone switchCameraiPad
    if (([[UIDevice currentDevice] userInterfaceIdiom]!=UIUserInterfaceIdiomPad)) {
        //Add revert camera action
        CGRect framing = CGRectMake(30, 30, 40, 40);
        revertButton = [[UIButton alloc] initWithFrame:framing];
        [revertButton setBackgroundImage:[UIImage imageNamed:@"switchCameraiPhone"] forState:UIControlStateNormal];
        [revertButton addTarget:self action:@selector(revertCameraMethod:) forControlEvents:UIControlEventTouchUpInside];
        [self.previewView addSubview:revertButton];
        
        //Add close button on preview view
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-70, 30, 40, 40)];
        [closeButton setContentMode:UIViewContentModeScaleAspectFill];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"closeiPhone"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeVideoRecordingMethod:) forControlEvents:UIControlEventTouchUpInside];
        [self.previewView addSubview:closeButton];
    }
    else {
        //Add revert camera action
        CGRect framing = CGRectMake(30, 30, 50, 50);
        revertButton = [[UIButton alloc] initWithFrame:framing];
        [revertButton setBackgroundImage:[UIImage imageNamed:@"switchCameraiPad"] forState:UIControlStateNormal];
        [revertButton addTarget:self action:@selector(revertCameraMethod:) forControlEvents:UIControlEventTouchUpInside];
        [self.previewView addSubview:revertButton];
        
        //Add close button on preview view
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-80, 30, 50, 50)];
        [closeButton setContentMode:UIViewContentModeScaleAspectFill];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"closeiPad"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeVideoRecordingMethod:) forControlEvents:UIControlEventTouchUpInside];
        [self.previewView addSubview:closeButton];
    }
    
    continousSecond = 0;
    _timeLabel.text = [NSString stringWithFormat:@"00:00:00"];  //Set initial timer
    tempFilePath=@"";
    //Set initail state of view buttons
    self.captureButton.selected = NO;
    closeButton.enabled=true;
    closeButton.alpha=1.0f;
    self.doneButton.enabled=false;
    self.doneButton.alpha=0.5f;
    revertButton.enabled=true;
    revertButton.alpha=1.0f;
    
    //Set temporary file to record video
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    tempFilePath = [documentsPath stringByAppendingPathComponent:@"myTakeMovie.mp4"];
    [self removeVideoFile:tempFilePath];
    //add observer for camera recording
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak CustomVideoViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CustomVideoViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
            });
        }]];
        [[self session] startRunning];
        
    });
}
#pragma mark - end

#pragma mark - Create the AVCaptureSession
- (void)avCaptureSessionMethod
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.prevLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-78);
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.prevLayer];
    [self checkDeviceAuthorizationStatus];
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        NSError *error = nil;
        AVCaptureDevice *videoDevice = [CustomVideoViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            });
        }
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        if ([session canAddInput:audioDeviceInput]) {
            [session addInput:audioDeviceInput];
        }
        //check file size
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        movieFileOutput.maxRecordedFileSize = 1024 *1024 * maxSize;
        movieFileOutput.movieFragmentInterval=kCMTimeInvalid;//The default is 10 seconds. Set to kCMTimeInvalid to disable movie fragment writing (not typically recommended).
        if ([session canAddOutput:movieFileOutput])  {
            [session setSessionPreset: AVCaptureSessionPresetMedium];//Change video quality
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8) {
                if ([connection isVideoStabilizationSupported])
                    [connection setEnablesVideoStabilizationWhenAvailable:YES];
            } else {
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            }
            
            [self setMovieFileOutput:movieFileOutput];
        }
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
}
#pragma mark - end

#pragma mark - Custom camera video delegate method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        if (isCapturingStillImage) {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext) {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording) {
                [revertButton setEnabled:NO];
                revertButton.alpha=0.5f;
                [[self captureButton] setEnabled:YES];
            }
            else
            {
                [revertButton setEnabled:YES];
                revertButton.alpha=1.0f;
                [[self captureButton] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext) {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning) {
                [revertButton setEnabled:YES];
                revertButton.alpha=1.0f;
                [[self captureButton] setEnabled:YES];
            }
            else {
                [revertButton setEnabled:NO];
                revertButton.alpha=0.5f;
                [[self captureButton] setEnabled:NO];
            }
        });
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)closeVideoRecordingMethod:(id)sender {
    //close video recording
    videoUploadViewObj.isVideoRecord=false;
    [self removeVideoFile:tempFilePath];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)revertCameraMethod:(id)sender {
    //change camera from rear to front and vice versa
    [revertButton setEnabled:NO];
    revertButton.alpha=0.5f;
    [[self captureButton] setEnabled:NO];
    [videoTimer invalidate];
    videoTimer = nil;
    continousSecond = 0;
    self.captureButton.selected = NO;
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [CustomVideoViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [CustomVideoViewController setFlashMode:AVCaptureFlashModeOff forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        dispatch_async(dispatch_get_main_queue(), ^{
            [revertButton setEnabled:YES];
            revertButton.alpha=1.0f;
            [[self captureButton] setEnabled:YES];
        });
    });
}

- (IBAction)captureMethod:(id)sender {
    [videoTimer invalidate];
    videoTimer = nil;
    //star recoding video
    if (self.captureButton.isSelected) {
        self.captureButton.selected = NO;
    }
    else{
        [revertButton setEnabled:NO];
        closeButton.enabled=false;
        closeButton.alpha=0.5f;
        self.doneButton.enabled=false;
        self.doneButton.alpha=0.5f;
        self.captureButton.selected = YES;
        continousSecond = 0;
        _timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
        videoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(startRecordTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            
            // Turning OFF flash for video recording
            [CustomVideoViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:tempFilePath] recordingDelegate:self];
        }
        else
        {
            [[self movieFileOutput] stopRecording];
        }
    });
}

- (IBAction)doneMethod:(UIButton *)sender {
    //save video in cache directory after recording
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [self removeVideoFile:videoFilePath];
    [fileManager copyItemAtPath:tempFilePath toPath:videoFilePath error:&error];
    [self removeVideoFile:tempFilePath];
    videoUploadViewObj.videoFilePath=videoFilePath;
    videoUploadViewObj.isVideoExist=true;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end

#pragma mark - Set timer
- (void)startRecordTimer {
    //start recoding video set timer
    continousSecond++;
    hour = (continousSecond / 3600)%24;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
}
#pragma mark - end

#pragma mark - FocusAndExposeTap gesture
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    //set focus on tap
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}
#pragma mark - end

#pragma mark - File output delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    //check file size of captured video file
    self.captureButton.selected = NO;
    [videoTimer invalidate];
    videoTimer = nil;
    int sizeExceed;
    sizeExceed = 0;
    if (error) {
        if ([error code] == AVErrorDiskFull) {
            sizeExceed = 1;
        }
        else if ([error code] == AVErrorMaximumFileSizeReached) {
            sizeExceed = YES;
            sizeExceed = 2;
        }
        else if ([error code] == AVErrorMaximumDurationReached) {
            NSLog(@"Caught max duration error");
        }
        else {
            NSLog(@"Caught other error");
        }
    }
    [self setLockInterfaceRotation:NO];
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    outputFileURL = [NSURL URLWithString:tempFilePath];
    if (backgroundRecordingID != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    closeButton.enabled=true;
    closeButton.alpha=1.0f;
    self.doneButton.enabled=true;
    self.doneButton.alpha=1.0f;
    revertButton.enabled=true;
    revertButton.alpha=1.0f;
    if (sizeExceed == 1) {
        [self.view makeToast:@"Your device storage is full."];
    }
    else if (sizeExceed == 2){
        [self.view makeToast:[NSString stringWithFormat:@"The video recording is too long and exceeds our max size %d MB. Please try recording a shorter video.",maxSize]];
    }
}
#pragma mark - end

#pragma mark - Device Configuration
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}
#pragma mark - end

#pragma mark - UI of video recording screen
- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus {
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                
                SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"Your app doesn't have permission to use Camera, please change privacy settings." closeButtonTitle:@"OK" duration:0.0f];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}
#pragma mark - end

#pragma mark - Remove video file
- (void)removeVideoFile:(NSString*)videoPath {
    //remove video file from cache directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
    if (fileExists) {
        [fileManager removeItemAtPath:videoPath error:nil];
    }
}
#pragma mark - end
@end
