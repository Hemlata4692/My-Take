//
//  LongTextViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "LongTextViewController.h"
#import "BSKeyboardControls.h"
#import "QuestionModel.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import "ImagePreviewViewController.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"

@interface LongTextViewController ()<UITextViewDelegate,BSKeyboardControlsDelegate,UICollectionViewDelegate> {
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
}

@property (strong, nonatomic) IBOutlet UITextView *questionTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UITextView *detailedTextView;
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation LongTextViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    [self.questionTextView flashScrollIndicators];
    self.viewMoreButton.hidden=YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //set question textview frame
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 29, [[UIScreen mainScreen] bounds].size.width-40, 60);
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    //set keyboard control
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.detailedTextView]]];
    [self.keyboardControls setDelegate:self];
    //add corner radius and shadow
    [self viewCustomization];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.questionTextView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    [self.detailedTextView setTextViewBorder:self.detailedTextView color:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
    [self.detailedTextView setCornerRadius:5.0f];
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    
    self.scrollView.scrollEnabled = false;
    self.attachmentView.translatesAutoresizingMaskIntoConstraints = YES;
    //load image video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    //set image video view framing different in iPad and iPhone
    if (([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad)) {
        globalImageView.view.frame = CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width-40, 120);
    }
    else {
        globalImageView.view.frame = CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width-40, 220);
        self.attachmentView.frame= CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 250);
    }
    //add collection view delegate
    globalImageView.imageVideoCollectionView.delegate=self;
    //if no attachments available
    if (0==questionData.answerAttachments.count) {
        CGRect frame = self.attachmentView.frame;
        frame.size = CGSizeMake(0, 0);
        self.attachmentView.frame = frame;
    }
    else {
        [self.attachmentView addSubview:globalImageView.view];
    }
    //if question length is more then 3 lines show view more button
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction{
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls{
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.scrollView.scrollEnabled = false;
    [keyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.keyboardControls setActiveField:textView];
    self.scrollView.scrollEnabled = true;
    if (([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad) && (0!=questionData.answerAttachments.count)) {
        [self.scrollView setContentOffset:CGPointMake(0, 210) animated:YES];
    }
    else if (([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad)) {
        [self.scrollView setContentOffset:CGPointMake(0, 140) animated:YES];
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    [self.keyboardControls.activeField resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.scrollView.scrollEnabled = false;
    if ([self.detailedTextView.text isEqualToString:@""]) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        //When user click on next save data in database
        [myDelegate showIndicator];
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.longTextResponse=self.detailedTextView.text;
        [AnswerDatabase insertDataInAnswerTable:answerData];
        //calculate length of answer
        NSData *data = [[NSString stringWithFormat:@"%@",answerData.longTextResponse] dataUsingEncoding:NSASCIIStringEncoding];
        NSUInteger myLength = data.length;
        [UserDefaultManager setAnswerFileSize:(double)myLength];
        
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        [myDelegate stopIndicator];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
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

#pragma mark - Collection view delegate and datasource methods
//Preview image view using collection view delegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
    if ([attachments.attachmentType isEqualToString:@"image"]) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.selectedIndex=(int)indexPath.row;
        imagePreviewView.attachmentArray=[globalImageView.attachmentsArray mutableCopy];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
    else {
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
