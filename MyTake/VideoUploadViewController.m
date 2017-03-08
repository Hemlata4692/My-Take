//
//  VideoUploadViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "VideoUploadViewController.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Toast.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "CustomVideoViewController.h"

@interface VideoUploadViewController ()<UICollectionViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    int maxSize;
}
@property (strong, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (strong, nonatomic) IBOutlet UIView *videoBackView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnailImage;
@property (strong, nonatomic) IBOutlet UIButton *videoPreviewButton;
@property (strong, nonatomic) IBOutlet UIButton *chooseFromLibraryButton;
@property (strong, nonatomic) IBOutlet UIButton *recordVideoButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation VideoUploadViewController
@synthesize questionDetailArray,videoFilePath, isVideoExist, thumbnailImage, isVideoRecord;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.viewMoreButton.hidden=YES;
    isVideoExist=false;  //check is video exist or not
    isVideoRecord=false; //this variable use for video is record or not by custom video recorder.
    videoFilePath=@"";
    [self.questionTextView flashScrollIndicators];
    //set vertical center text in UITextView
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(36, 29, [[UIScreen mainScreen] bounds].size.width-92, 60);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    //add border corner radius on objects
    [self viewCustomization];
    //check video is recoreded or not using camera
    if (isVideoRecord) {
        isVideoRecord=false;
        self.videoThumbnailImage.image=[self getThumbnailVideoImage];   //fetch thumbnail image from recorded video
    }
    [self viewObjectsResize];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.questionTextView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)viewCustomization {
   
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    maxSize=[questionData.maximumSize intValue];
    //add global image/video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    
    //set video path with step and mission id to unique name
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    videoFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyTake%d_%d.mp4",[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue],[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]]];
    
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    self.videoThumbnailImage.layer.cornerRadius=5.0f;
    self.videoThumbnailImage.layer.masksToBounds=YES;
    [self setTextViewAlignment:self.questionTextView];
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
    
    [self removeAutolayout];
}

- (UIImage*)getThumbnailVideoImage {
    //get thumbnail image from video
    NSURL *videoURl = [NSURL fileURLWithPath:videoFilePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    return [[UIImage alloc] initWithCGImage:imgRef];
}

- (void)removeAutolayout {
    self.videoBackView.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    self.videoThumbnailImage.translatesAutoresizingMaskIntoConstraints=YES;
    self.videoPreviewButton.translatesAutoresizingMaskIntoConstraints=YES;
    self.cancelVideoButton.translatesAutoresizingMaskIntoConstraints=YES;
    self.chooseFromLibraryButton.translatesAutoresizingMaskIntoConstraints=YES;
    self.recordVideoButton.translatesAutoresizingMaskIntoConstraints=YES;
}

- (void)viewObjectsResize {
    self.videoBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-265);//videoBackView height=[[UIScreen mainScreen] bounds].size.height-253(navigation height+top space of mainContainerView+top space of videoBackView+bottom space of mainContainerView)
    self.attachmentView.frame= CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 140);
    //show and global image view according to attachments is available or not
    if (0==questionData.answerAttachments.count) {
        //if no attachments available
        CGRect frame = self.attachmentView.frame;
        frame.size = CGSizeMake(0, 0);
        self.attachmentView.frame = frame;
    }
    else {
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
    }
    
    self.videoThumbnailImage.backgroundColor=[UIColor whiteColor];
    self.videoThumbnailImage.frame=CGRectMake(25, self.attachmentView.frame.origin.y+self.attachmentView.frame.size.height+15, [[UIScreen mainScreen] bounds].size.width-70, (((float)172/(float)250)*([[UIScreen mainScreen] bounds].size.width-70)));
    self.videoPreviewButton.frame=self.videoThumbnailImage.frame;
    self.cancelVideoButton.frame=CGRectMake(self.videoThumbnailImage.frame.origin.x+self.videoThumbnailImage.frame.size.width-19, self.videoThumbnailImage.frame.origin.y-15, 38, 38);
    if (isVideoExist) {
        self.videoThumbnailImage.hidden=NO;
        self.cancelVideoButton.hidden=NO;
        self.videoPreviewButton.hidden=NO;
        if (([[UIScreen mainScreen] bounds].size.height-265)<self.videoThumbnailImage.frame.origin.y+self.videoThumbnailImage.frame.size.height+25+88+10)//self.videoThumbnailImage.frame.origin.y+self.videoThumbnailImage.frame.size.height+35(space b/w videoThumbnailImage and chooseFromLibraryOutlet)+chooseFromLibraryOutlet height+chooseFromLibraryOutlet bottom space
        {
            self.videoBackView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, self.videoThumbnailImage.frame.origin.y+self.videoThumbnailImage.frame.size.height+25+88+20);
        }
    }
    else {
        self.videoThumbnailImage.hidden=YES;
        self.cancelVideoButton.hidden=YES;
        self.videoPreviewButton.hidden=YES;
    }
    self.chooseFromLibraryButton.frame=CGRectMake((self.videoBackView.frame.size.width/2)-135, self.videoBackView.frame.size.height-99, 130, 88);
    self.recordVideoButton.frame=CGRectMake((self.videoBackView.frame.size.width/2)+5, self.videoBackView.frame.size.height-99, 130, 88);
    
    self.scrollView.contentSize = CGSizeMake(0,self.videoBackView.frame.size.height);
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    //save answer if video exists
    if (isVideoExist) {
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.videoPath=videoFilePath;
        [AnswerDatabase insertDataInAnswerTable:answerData];
        
        //calculate length of answer
        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:videoFilePath error:nil].fileSize;
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

//open view more question pop up
- (IBAction)viewMoreButtonAction:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=self.questionTextView.text;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}

//open help popup view
- (IBAction)helpAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=@"Choose a video from your library or record a new one. When recording a video, click the red record button to begin. Click the pause button to stop recording. Click the ‘X’ to delete the recording. Once selected, you can preview your video from the main mission step page. You can only have 1 video response as an answer.";
    helpViewObj.isHelpScreen=YES;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}

- (IBAction)cancelVideo:(UIButton *)sender {
    //cancel recording
    isVideoExist=false;
    [self viewObjectsResize];
}

- (IBAction)chooseLibrary:(UIButton *)sender {
    //choose video from library
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    imagePicker.allowsEditing=NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)videoPreview:(UIButton *)sender {
    //play video
    NSURL *videoURL = [NSURL fileURLWithPath:videoFilePath];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [playerViewController.player play];//used to play on start
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (IBAction)recordVideo:(UIButton *)sender {
    //start recording video
    isVideoRecord=true;
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomVideoViewController *videoRecordView =[storyboard instantiateViewControllerWithIdentifier:@"CustomVideoViewController"];
    videoRecordView.maxSize=maxSize;
    videoRecordView.videoFilePath=videoFilePath;
    videoRecordView.videoUploadViewObj=self;
    [self.navigationController presentViewController:videoRecordView animated:YES completion:nil];
}
#pragma mark - end

#pragma mark - UIImagePickerController delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //get size of video
    NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
    //error Container
    NSError *attributesError;
    NSDictionary *fileAttributes=[[NSFileManager defaultManager] attributesOfItemAtPath:[videoUrl path] error:&attributesError];
    NSNumber *fileSizeNumber=[fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    if ((float)((float)(fileSize/1024)/1024)<=(float)maxSize) {
        //if size is less than or equal to max size then execute this code. And save this video in document folder
        isVideoExist=true;
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
            NSString *moviePath = [videoUrl path];
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                NSData *videoData=[NSData dataWithContentsOfURL:videoUrl];
                [videoData writeToFile:videoFilePath atomically:NO];
            }
        }
        //get thumbnail image from video
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *generate=[[AVAssetImageGenerator alloc] initWithAsset:asset];
        generate.appliesPreferredTrackTransform=TRUE;
        NSError *err=NULL;
        CMTime time=CMTimeMake(1, 30);
        CGImageRef imgRef=[generate copyCGImageAtTime:time actualTime:NULL error:&err];
        self.videoThumbnailImage.image=[[UIImage alloc] initWithCGImage:imgRef];
    }
    else {
        //if size greater from max size then shows toast.
        [self.view makeToast:[NSString stringWithFormat:@"The video recording is too long and exceeds our max size %d MB. Please try recording a shorter video.",maxSize]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self viewObjectsResize];
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
//preview image view using collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
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
        NSString* strUrl =attachments.attachmentURL;
        NSURL *fileURL = [NSURL URLWithString: strUrl];
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
        [self presentViewController:moviePlayer animated:YES completion:NULL];
    }
}
#pragma mark - end
@end
