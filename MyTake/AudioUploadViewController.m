//
//  AudioUploadViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "AudioUploadViewController.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "HelpViewController.h"

@interface AudioUploadViewController ()<UICollectionViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *recordingTimer;
    int second, minute, hour, continousSecond;
    int maxSize;
    bool isLatestRecording, isRecordingAvailable;
    NSString *audioFilePath;
}

@property (strong, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *audioBackView;
@property (strong, nonatomic) IBOutlet UILabel *audioRecordTimer;
@property (strong, nonatomic) IBOutlet UIButton *audioRecordingButton;
@property (strong, nonatomic) IBOutlet UIButton *audioRecordStopButton;
@property (strong, nonatomic) IBOutlet UIButton *audioRecordCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation AudioUploadViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    isRecordingAvailable=false;
    isLatestRecording=true;
    [self.questionTextView flashScrollIndicators];
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    maxSize=[questionData.maximumSize intValue];
    //add global image/video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    self.viewMoreButton.hidden=YES;
    //add border corner radius on objects
    [self viewCustomization];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //set up file for audio recording
    [self recordAudioFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.questionTextView flashScrollIndicators];
}
#pragma mark - end

#pragma mark - Intial setup of audio recording
- (void)recordAudioFile {
    second = 0;
    minute = 0;
    continousSecond = 0;
    self.audioRecordCancelButton.hidden=YES;
    self.audioRecordStopButton.hidden=YES;
    //set button images for selected and normal state
    [self.audioRecordingButton setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
    [self.audioRecordingButton setImage:[UIImage imageNamed:@"recordplay"] forState:UIControlStateSelected];
    [self.audioRecordStopButton setImage:[UIImage imageNamed:@"recordstop"] forState:UIControlStateNormal];
    [self.audioRecordStopButton setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateSelected];
    self.audioRecordingButton.selected=NO;
    self.audioRecordStopButton.selected=NO;
    //set initial timer to 00:00
    self.audioRecordTimer.text = [NSString stringWithFormat:@"00:00"];
    
    //set audio file path
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    audioFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyTake%d_%d.wav",[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue],[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]]];
    //start AVAudio session for audio recording
    NSURL *outputFileURL = [NSURL URLWithString:audioFilePath];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
}
#pragma mark - end 

#pragma mark - Custom accessors
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(36, 29, [[UIScreen mainScreen] bounds].size.width-92, 60);
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>40) {
        self.questionTextView.contentOffset=CGPointMake(0, 4);
    }
    else {
        self.questionTextView.contentOffset=CGPointMake(0, -4);
    }
    [self viewObjectsResize];
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
}

- (void)viewObjectsResize {
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    self.audioBackView.translatesAutoresizingMaskIntoConstraints=YES;
    self.audioBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-238);//self.audioBackView height=[[UIScreen mainScreen] bounds].size.height-238(navigation height+top space of mainContainerView+top space of audioBackView+bottom space of audioBackView)
    self.attachmentView.frame= CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 140);
    //Show and global image view according to attachments is available or not
    if (0==questionData.answerAttachments.count) {
        //if no attachments available
        CGRect frame = self.attachmentView.frame;
        frame.size = CGSizeMake(0, 0);
        self.attachmentView.frame = frame;
        self.scrollView.scrollEnabled=NO;
        self.audioBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, ([[UIScreen mainScreen] bounds].size.height-258)+self.attachmentView.frame.size.height);
    }
    else {
        self.scrollView.scrollEnabled=YES;
        if (([[UIDevice currentDevice] userInterfaceIdiom]!= UIUserInterfaceIdiomPad)) {
            //if current device is iPhone then set frame
            globalImageView.view.frame = CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width-20, 120.0f);
        }
        else {
            //if current device is iPad then set frame
            self.attachmentView.frame= CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 250);
            globalImageView.view.frame = CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width-40, 220.0f);
        }
        [self.attachmentView addSubview:globalImageView.view];
        globalImageView.imageVideoCollectionView.delegate=self; //add collection view delegate
        
        if([[UIScreen mainScreen] bounds].size.height<=568) {
            self.audioBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, ([[UIScreen mainScreen] bounds].size.height-258)+self.attachmentView.frame.size.height);
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom]!= UIUserInterfaceIdiomPad)) {
            self.audioBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, ([[UIScreen mainScreen] bounds].size.height-358)+self.attachmentView.frame.size.height);
        }
        else {
            self.scrollView.scrollEnabled=NO;
            self.audioBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, ([[UIScreen mainScreen] bounds].size.height-508)+self.attachmentView.frame.size.height);
        }
    }
    self.scrollView.contentSize = CGSizeMake(0,self.audioBackView.frame.size.height);
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    [recordingTimer invalidate];
    recordingTimer = nil;
    //stop recording if it is running and save answer
    [recorder stop];
    self.audioRecordingButton.selected=NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    self.audioRecordStopButton.selected=NO;
    //stop playing the recording
    if ([player play]) {
        [player stop];
    }
    if (isRecordingAvailable)    //check if file exists or not
    {
        //when user click on next save answer in database
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.audioPath=audioFilePath;
        [AnswerDatabase insertDataInAnswerTable:answerData];
        
        //calculate length of answer
        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:[recorder.url path] error:nil].fileSize;
        [UserDefaultManager setAnswerFileSize:(double)size];
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    }
    else {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
}

//view more question text button action
- (IBAction)viewMoreButtonAction:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=self.questionTextView.text;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}

- (IBAction)recording:(UIButton *)sender {
    //start recording
    if (!recorder.recording&&isLatestRecording) {
        [recordingTimer invalidate];
        recordingTimer = nil;
        self.audioRecordingButton.selected=YES;
        self.audioRecordStopButton.hidden=NO;
        self.audioRecordStopButton.selected=NO;
        self.audioRecordCancelButton.hidden=NO;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
        [recorder record];
        continousSecond = 0;
        isRecordingAvailable=true;
        self.audioRecordTimer.text = [NSString stringWithFormat:@"00:00"];
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(startRecordTimer)
                                                 userInfo:nil
                                                  repeats:YES];
        
    }
    else if (!recorder.recording&&!isLatestRecording) {
        //resume currently running recording
        [recordingTimer invalidate];
        recordingTimer = nil;
        [recorder record];
        self.audioRecordingButton.selected=YES;
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(startRecordTimer)
                                                 userInfo:nil
                                                  repeats:YES];
    }
    else {
        //pause currently running recording
        [recordingTimer invalidate];
        recordingTimer = nil;
        self.audioRecordingButton.selected=NO;
        self.audioRecordStopButton.hidden=NO;
        self.audioRecordStopButton.selected=NO;
        self.audioRecordCancelButton.hidden=NO;
        [recorder pause];
        isLatestRecording=false;
    }
}

- (IBAction)recordStop:(UIButton *)sender {
    [recordingTimer invalidate];
    recordingTimer = nil;
    //stop recording if it is recording
    [recorder stop];
    isLatestRecording=YES;
    self.audioRecordingButton.selected=NO;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:NO error:nil];
    
    if (!self.audioRecordStopButton.isSelected) {
        //if play audio file then stop
        continousSecond = 0;
        self.audioRecordStopButton.selected = YES;
        if ([player play]) {
            [player stop];
        }
    }
    else{
        //start playing recorded audio
        [recordingTimer invalidate];
        recordingTimer = nil;
        continousSecond = 0;
        self.audioRecordTimer.text = [NSString stringWithFormat:@"00:00"];
        self.audioRecordStopButton.selected = YES;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        [player setVolume:1.0];
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(startRecordTimer)
                                                 userInfo:nil
                                                  repeats:YES];
        self.audioRecordStopButton.selected = NO;
    }
}

- (IBAction)recordCancel:(UIButton *)sender {
    //cancel recorded audio and played audio
    isRecordingAvailable=false;
    [recordingTimer invalidate];
    recordingTimer = nil;
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:NO error:nil];
    self.audioRecordCancelButton.hidden=YES;
    self.audioRecordStopButton.hidden=YES;
    self.audioRecordStopButton.selected=NO;
    self.audioRecordingButton.selected=NO;
    isLatestRecording=YES;
    continousSecond = 0;
    self.audioRecordTimer.text = [NSString stringWithFormat:@"00:00"];
    //check if file already exists or not.
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:nil];
    }
}

//open help popup view
- (IBAction)helpAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=@"Click the red record button to start recording. Speak into your microphone. You may pause the recording by pressing the pause button, to resume recording press the record button again. When finished, click the stop button on the right. To play the recording back, click the play button. To cancel and start over, click the ‘x’.";
     helpViewObj.isHelpScreen=YES;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}
#pragma mark - end

#pragma mark - Set timer
//set recording timer in minutes and seconds
- (void)startRecordTimer {
    continousSecond++;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    self.audioRecordTimer.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    if (recorder.recording) {
        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:[recorder.url path] error:nil].fileSize;
        //check if recording exceeds the given file size
        if (size >= (1024*1024*maxSize)) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:self title:@"Alert" subTitle:[NSString stringWithFormat:@"The recording is too long and exceeds our max size %d MB. Please try recording a more concise response.",maxSize] closeButtonTitle:@"OK" duration:0.0f];
            [recordingTimer invalidate];
            recordingTimer = nil;
            [recorder stop];
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:NO error:nil];
            isLatestRecording=YES;
            self.audioRecordingButton.selected=NO;
        }
    }
}
#pragma mark - end

#pragma mark - AVAudioPlayer delegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //if recording finished set timer to 00:00 again
    self.audioRecordStopButton.selected = YES;
    self.audioRecordTimer.text = [NSString stringWithFormat:@"00:00"];
    [recordingTimer invalidate];
    recordingTimer = nil;
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
//preview image view using collection view delegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
    if ([attachments.attachmentType isEqualToString:@"image"]) {
        //open image in preview view
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.selectedIndex=(int)indexPath.row;
        imagePreviewView.attachmentArray=[globalImageView.attachmentsArray mutableCopy];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
    else {
        //play video in movie player
        AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
        // NSString* strurl =@"https://s3.amazonaws.com/adplayer/colgate.mp4";
        NSString* strUrl =attachments.attachmentURL;
        NSURL *fileURL = [NSURL URLWithString: strUrl];
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
        [self presentViewController:moviePlayer animated:YES completion:NULL];
    }
}
#pragma mark - end
@end
