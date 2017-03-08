//
//  ImagePreviewViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "AttachmentsModel.h"
#import "UIViewController+AMSlideMenu.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ImagePreviewViewController ()<UIGestureRecognizerDelegate> {
    AttachmentsModel * attachments;
    UIImage *resultImage;
}
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *deleteImageButton;
@property(nonatomic,assign)float fileSize;

@end

@implementation ImagePreviewViewController
@synthesize imageURL;
@synthesize attachmentArray;
@synthesize selectedIndex;
@synthesize screenName;
@synthesize imageUploadObj;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    [self displayImagesAndAddGesture];
}

- (void)displayImagesAndAddGesture {
    self.previewImageView.userInteractionEnabled=YES;
    //check if screen is visited from image question screen or ther
    if ([screenName isEqualToString:@"Image Upload"]) {
        //if from image question screen show delete button else hide
        self.deleteImageButton.hidden=NO;
        self.deleteImageButton.frame=CGRectMake(self.deleteImageButton.frame.origin.x, self.deleteImageButton.frame.origin.y, self.deleteImageButton.frame.size.width, self.deleteImageButton.frame.size.height);
        self.playButton.hidden=YES;
    }
    else {
        self.deleteImageButton.hidden=YES;
        self.deleteImageButton.frame=CGRectMake(self.deleteImageButton.frame.origin.x, self.deleteImageButton.frame.origin.y, 0, 0);
    }
    //if image url is nil set swipe gesture on image view
    if ([imageURL isEqualToString:@""] || nil==imageURL) {
        self.imagePreview.hidden=YES;
        self.previewImageView.hidden=NO;
        self.playButton.hidden=NO;
        //add swipe gesture on iamge view
        UISwipeGestureRecognizer *swipeImageLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImagesLeft:)];
        swipeImageLeft.delegate=self;
        UISwipeGestureRecognizer *swipeImageRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImagesRight:)];
        swipeImageRight.delegate=self;
        [swipeImageLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeImageRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.previewImageView addGestureRecognizer:swipeImageLeft];
        [self.previewImageView addGestureRecognizer:swipeImageRight];
        swipeImageLeft.enabled = YES;
        swipeImageRight.enabled = YES;
        [self swipeImages];
    }
    else {
        self.imagePreview.hidden=NO;
        self.previewImageView.hidden=YES;
        self.playButton.hidden=YES;
        //display image using afnetworking
        [self downloadImages:self.imagePreview imageUrl:imageURL placeholderImage:@"placeholder.png" isVideo:@"0"];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //if this vc can be poped , then
    if (self.navigationController.viewControllers.count > 1) {
        //disabling pan gesture for left menu
        [self disableSlidePanGestureForLeftMenu];
    }
    self.fileSize=imageUploadObj.imageFileSize;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //if this vc can be poped , then
    if (self.navigationController.viewControllers.count > 1) {
        //enable pan gesture for left menu
        [self enableSlidePanGestureForLeftMenu];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)backButtonAction:(UIButton *)sender {
    //check if screen if image question
    if ([screenName isEqualToString:@"Image Upload"]) {
        imageUploadObj.getPathOfSelectedImagesArray=[attachmentArray mutableCopy];
        imageUploadObj.imageFileSize=self.fileSize;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[ImageUploadViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)playVideoButtonAction:(id)sender {
    //play video in movie player
    attachments=[attachmentArray objectAtIndex:selectedIndex];
    NSString* strUrl =attachments.attachmentURL;
    NSURL *fileURL = [NSURL URLWithString: strUrl];
    AVPlayer *player = [AVPlayer playerWithURL:fileURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [playerViewController.player play];//used to play on start
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (IBAction)deleteImageButtonAction:(id)sender {
    [self reloadAttachmentArray];
    //delete selected image
    if ([self getImageFromURL:[attachmentArray objectAtIndex:selectedIndex]]) {
        imageURL=[attachmentArray objectAtIndex:selectedIndex];
        NSData *imgData = UIImageJPEGRepresentation(resultImage, 1);
        if (selectedIndex<attachmentArray.count-1) {
            selectedIndex--;
        }
        [attachmentArray removeObject:imageURL];
        //remove image from array and cache directory
        [[NSFileManager defaultManager] removeItemAtPath:imageURL error:nil];
        self.fileSize=self.fileSize-[imgData length];
    }
    //if array count is 0 pop to image upload view
    if (attachmentArray.count==0) {
        imageUploadObj.getPathOfSelectedImagesArray=[attachmentArray mutableCopy];
        imageUploadObj.imageFileSize=self.fileSize;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[ImageUploadViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
    }
}
#pragma mark - end

#pragma mark - Fetch images from cache directory
//fetch images from cache directory
- (BOOL)getImageFromURL:(NSString *)fileURL {
    BOOL success =[[NSFileManager defaultManager] fileExistsAtPath:fileURL];
    if(success) {
        resultImage=[UIImage imageWithContentsOfFile:fileURL];
    }
    return success;
}
#pragma mark - end


#pragma mark - Swipe gesture methods
//reload images afetr deleing image
- (void)reloadAttachmentArray {
    if (selectedIndex<attachmentArray.count-1) {
        [self performSelector:@selector(swipeImagesLeft:) withObject:nil afterDelay:0.01];
    }
    else if (selectedIndex==attachmentArray.count-1) {
        [self performSelector:@selector(swipeImagesRight:) withObject:nil afterDelay:0.01];
    }
}

//display current index image on image view
- (void)swipeImages {
    //check if screen is navigated from image question or not
    if ([screenName isEqualToString:@"Image Upload"]) {
        if ([self getImageFromURL:[attachmentArray objectAtIndex:selectedIndex]]) {
            self.previewImageView.contentMode=UIViewContentModeScaleAspectFill;
            self.previewImageView.clipsToBounds = YES;
            self.previewImageView.image=resultImage;
            self.playButton.hidden=YES;
        }
    }
    else {
        attachments=[attachmentArray objectAtIndex:selectedIndex];
        if ([attachments.attachmentType isEqualToString:@"image"]) {
            self.playButton.hidden=YES;
            [self downloadImages:self.previewImageView imageUrl:attachments.attachmentURL placeholderImage:@"placeholder.png" isVideo:@"0"];
        }
        else {
            self.playButton.hidden=NO;
            [self downloadImages:self.previewImageView imageUrl:attachments.attachmentThumbnail placeholderImage:@"video_placeholder.png" isVideo:@"1"];
        }
    }
}

//adding left animation to images
- (void)addLeftAnimationPresentToView:(UIView *)viewTobeAnimatedLeft
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.40;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimatedLeft.layer addAnimation:transition forKey:nil];
    
}

//adding right animation to images
- (void)addRightAnimationPresentToView:(UIView *)viewTobeAnimatedRight
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.40;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimatedRight.layer addAnimation:transition forKey:nil];
}

//swipe images in left direction
- (void)swipeImagesLeft:(UISwipeGestureRecognizer *)sender {
    selectedIndex++;
    if (selectedIndex<attachmentArray.count)
    {
        //check if screen is navigated from image question or not
        if ([screenName isEqualToString:@"Image Upload"]) {
            if ([self getImageFromURL:[attachmentArray objectAtIndex:selectedIndex]]) {
                self.previewImageView.image=resultImage;
                self.playButton.hidden=YES;
                UIImageView *moveImageView = self.previewImageView;
                [self addLeftAnimationPresentToView:moveImageView];
            }
        }
        else {
            attachments=[attachmentArray objectAtIndex:selectedIndex];
            if ([attachments.attachmentType isEqualToString:@"image"]) {
                self.playButton.hidden=YES;
                [self downloadImages:self.previewImageView imageUrl:attachments.attachmentURL placeholderImage:@"placeholder.png" isVideo:@"0"];
            }
            //play video
            else {
                self.playButton.hidden=NO;
                //set image from afnetworking
                [self downloadImages:self.previewImageView imageUrl:attachments.attachmentThumbnail placeholderImage:@"video_placeholder.png" isVideo:@"1"];
            }
            UIImageView *moveImageView = self.previewImageView;
            [self addLeftAnimationPresentToView:moveImageView];
        }
    }
    else {
        selectedIndex--;
    }
}

//swipe images in right direction
- (void)swipeImagesRight:(UISwipeGestureRecognizer *)sender
{
    selectedIndex--;
    if (selectedIndex<attachmentArray.count) {
        //check if screen is navigated from image question or not
        if ([screenName isEqualToString:@"Image Upload"]) {
            if ([self getImageFromURL:[attachmentArray objectAtIndex:selectedIndex]]) {
                self.previewImageView.image=resultImage;
                self.playButton.hidden=YES;
                UIImageView *moveImageView = self.previewImageView;
                [self addRightAnimationPresentToView:moveImageView];
            }
        }
        else {
            attachments=[attachmentArray objectAtIndex:selectedIndex];
            if ([attachments.attachmentType isEqualToString:@"image"]) {
                self.playButton.hidden=YES;
                //set image from afnetworking
                [self downloadImages:self.previewImageView imageUrl:attachments.attachmentURL placeholderImage:@"placeholder.png" isVideo:@"0"];
            }
            //play video
            else {
                self.playButton.hidden=NO;
                //set image from afnetworking
                [self downloadImages:self.previewImageView imageUrl:attachments.attachmentThumbnail placeholderImage:@"video_placeholder.png" isVideo:@"1"];
            }
            UIImageView *moveImageView = self.previewImageView;
            [self addRightAnimationPresentToView:moveImageView];
        }
    }
    else {
        selectedIndex++;
    }
}
#pragma mark - end

#pragma mark - Download images using AFNetworking
- (void)downloadImages:(UIImageView *)imageView imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage isVideo:(NSString *)isVideo {
    __weak UIImageView *weakRef = imageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if ([isVideo isEqualToString:@"1"]) {
            weakRef.contentMode = UIViewContentModeScaleAspectFit;
        }
        else {
            weakRef.contentMode = UIViewContentModeScaleAspectFill;
        }
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end

@end
