//
//  ImageUploadViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "ImageUploadViewController.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import "ImageGalleryViewController.h"
#import "UIView+Toast.h"
#import "MyButton.h"
#import "ImagePreviewViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"

#define kCellsPerRow 3
@interface ImageUploadViewController ()<UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource> {
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    UIImage *resultImage;
    float cellSize;
}

@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UITextView *questionTextView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *chooseFromLibraryButton;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *takePictureButton;
@property(nonatomic,retain) NSString *imageFilePath;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation ImageUploadViewController
@synthesize questionDetailArray;
@synthesize imagePath;
@synthesize maximumSize;
@synthesize getPathOfSelectedImagesArray;
@synthesize imageFileSize;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    cellSize=0.0;
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    getPathOfSelectedImagesArray=[[NSMutableArray alloc]init];
    self.imageFilePath=@"";
    [self.questionTextView flashScrollIndicators];
    self.viewMoreButton.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 29, [[UIScreen mainScreen] bounds].size.width-40, 60);
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    maximumSize=[questionData.maximumSize intValue];
    //add global image/video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    
    //add border corner radius on objects
    [self viewCustomization];
    //resize view objects
    [self viewObjectsResize];
    [self.imageCollectionView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.questionTextView flashScrollIndicators];
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    //set vertical center text in UITextView
    [self setTextViewAlignment:self.questionTextView];
    //set 3 cells per row in collection view
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.imageCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow);
    CGFloat cellWidth = (availableWidthForCells / kCellsPerRow)-13;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    cellSize=cellWidth;
    //remove autolayouts of objects to set their frame
    [self removeAutolayout];
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
}

//remove autolayouts from objects before setting frame
- (void)removeAutolayout {
    self.imageContainerView.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    self.chooseFromLibraryButton.translatesAutoresizingMaskIntoConstraints=YES;
    self.takePictureButton.translatesAutoresizingMaskIntoConstraints=YES;
    self.imageCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
}

//reframe objects according to screen and attachment view
- (void)viewObjectsResize {
    self.imageContainerView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-265);//videoBackView height=[[UIScreen mainScreen] bounds].size.height-253(navigation height+top space of mainContainerView+top space of videoBackView+bottom space of mainContainerView)
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
    self.imageCollectionView.frame=CGRectMake(8, self.attachmentView.frame.origin.y+self.attachmentView.frame.size.height+15, [[UIScreen mainScreen] bounds].size.width-36, (((float)205/(float)284)*([[UIScreen mainScreen] bounds].size.width-36)));
    
    if (([[UIScreen mainScreen] bounds].size.height-265)<self.imageCollectionView.frame.origin.y+self.imageCollectionView.frame.size.height+123)//self.videoThumbnailImage.frame.origin.y+self.videoThumbnailImage.frame.size.height+35(space b/w videoThumbnailImage and chooseFromLibraryOutlet)+chooseFromLibraryOutlet height+chooseFromLibraryOutlet bottom space
    {
        self.imageContainerView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, self.imageCollectionView.frame.origin.y+self.imageCollectionView.frame.size.height+133);
    }
    
    self.chooseFromLibraryButton.frame=CGRectMake((self.imageContainerView.frame.size.width/2)-135, self.imageContainerView.frame.size.height-99, 130, 88);
    self.takePictureButton.frame=CGRectMake((self.imageContainerView.frame.size.width/2)+5, self.imageContainerView.frame.size.height-99, 130, 88);
    self.scrollView.contentSize = CGSizeMake(0,self.imageContainerView.frame.size.height);
}
#pragma mark - end

#pragma mark - UICollectionView datasource and delegate methods
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //return images array count
    return getPathOfSelectedImagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"photoCell";
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.contentView setCornerRadius:5.0];
    // load the asset for this cell
    UIImageView *savedImage = (UIImageView*)[cell viewWithTag:1];
    MyButton *crossButton = (MyButton*)[cell viewWithTag:2];
    crossButton.hidden=NO;
    [savedImage setCornerRadius:5.0];
    //fetch image from cache directory and display on collection view cell image
    if ([self getImageFromURL:[getPathOfSelectedImagesArray objectAtIndex:indexPath.row]]) {
        savedImage.image=resultImage;
    }
    crossButton.Tag=(int)indexPath.row;
    [crossButton addTarget:self action:@selector(deleteSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView==self.imageCollectionView) {
        //open images on preview screen
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.screenName=@"Image Upload";
        imagePreviewView.selectedIndex=(int)indexPath.row;
        imagePreviewView.imageUploadObj=self;
        imagePreviewView.attachmentArray=[getPathOfSelectedImagesArray mutableCopy];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
    else {
        AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
        if ([attachments.attachmentType isEqualToString:@"image"]) {
            //show image on preview view
            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
            imagePreviewView.selectedIndex=(int)indexPath.row;
            imagePreviewView.attachmentArray=[globalImageView.attachmentsArray mutableCopy];
            [self.navigationController pushViewController:imagePreviewView animated:YES];
        }
        else {
            //play video in media player
            AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
            NSString* strUrl =attachments.attachmentURL;
            NSURL *fileURL = [NSURL URLWithString: strUrl];
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
            [self presentViewController:moviePlayer animated:YES completion:NULL];
        }
    }
    
    
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (getPathOfSelectedImagesArray.count>0&&getPathOfSelectedImagesArray.count<3) {
        return UIEdgeInsetsMake(0, (self.imageCollectionView.frame.size.width/2.0)-((cellSize/2.0)*(float)getPathOfSelectedImagesArray.count), 0, -((self.imageCollectionView.frame.size.width/2.0)-((cellSize/2.0)*(float)getPathOfSelectedImagesArray.count)));
    }
    else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
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

#pragma mark - IBActions
- (IBAction)deleteSelectedImage:(MyButton *)sender {
    //delete selected image
    if ([self getImageFromURL:[getPathOfSelectedImagesArray objectAtIndex:[sender Tag]]]) {
        self.imageFilePath=[getPathOfSelectedImagesArray objectAtIndex:[sender Tag]];
        NSData *imgData = UIImageJPEGRepresentation(resultImage, 1);
        if ([self getSizeOfImage:imgData isSelected:@"0"]) {
            [self.imageCollectionView reloadData];
        }
    }
}

- (IBAction)nextButtonAction:(UIButton *)sender {
    
    if (getPathOfSelectedImagesArray.count==0) {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        //save answer in database and move to next question
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.imageFolder=[getPathOfSelectedImagesArray componentsJoinedByString:@","];;
        [AnswerDatabase insertDataInAnswerTable:answerData];
        
        //calculate length of answer
        [UserDefaultManager setAnswerFileSize:(double)imageFileSize];
        //navigate to next question
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    }
}

- (IBAction)choosePhototFromLibraryButtonAction:(id)sender {
    //choose photos from photo library
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageGalleryViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImageGalleryViewController"];
    imagePreviewView.imageUploadObj=self;
    [self.navigationController pushViewController:imagePreviewView animated:YES];
}

- (IBAction)takePictureButtonAction:(id)sender {
    //if camera is not available in device show alert else open default camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"Device has no camera." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)viewMoreButtonAction:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=self.questionTextView.text;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}
#pragma mark - end

#pragma mark - Image picker controller delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {
    //resize image in aspect ratio if image width is greater then 800.0
    if (image.size.width>800.0){
        image=[self imageWithImage:image scaledToWidth:800.0];
    }
    NSData *imgData = UIImageJPEGRepresentation(image,1);
    //calculate image size while picking image from camera and show toast if size exceeds
    if ([self getSizeOfImage:imgData isSelected:@"1"]) {
        [self.imageCollectionView reloadData];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Check file size
//calculate image size and comapare to maximum size
- (BOOL)getSizeOfImage:(NSData*)imageData isSelected:(NSString *)isSelected {
    if ([isSelected isEqualToString:@"1"]) {
        if (getPathOfSelectedImagesArray.count<12) {
        imageFileSize=imageFileSize+[imageData length];
        //calculate image size and comapare to maximum size
        if (((imageFileSize/1024.0)/1024.0)>(float)maximumSize) {
            [self.view makeToast:[NSString stringWithFormat:@"You can select up to 12 images and image size can not exceed %d MB.",maximumSize]];
            imageFileSize=imageFileSize-[imageData length];
            return NO;
        }
        else {
            //set image path with time stamp, array count and stepid to unique name
            NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
            NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
            self.imageFilePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MyTakeImage%@_%lu_%d_%d.jpg",datestr,(unsigned long)getPathOfSelectedImagesArray.count,[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue],[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]]];
            //save images in cache directory
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager createFileAtPath:self.imageFilePath contents:imageData attributes:nil]) {
                [getPathOfSelectedImagesArray addObject:self.imageFilePath];
            }
        }
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"You can select up to 12 images and image size can not exceed %d MB.",maximumSize]];
        }
         return YES;
    }
    else {
        //if user delete image then remove image from cache directory and array
        [getPathOfSelectedImagesArray removeObject:self.imageFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:self.imageFilePath error:nil];
        imageFileSize=imageFileSize-[imageData length];
        return YES;
    }
}

//resize image in aspect ratio if image width is greater then 800.0
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - end
@end
