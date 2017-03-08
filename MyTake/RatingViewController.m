//
//  RatingViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "RatingViewController.h"
#import "QuestionModel.h"
#import "RatingViewCell.h"
#import "NetPromotRatingViewController.h"
#import "BSKeyboardControls.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import "ImagePreviewViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"

#define kCellsPerRow 6  //Set number of cells in collection view

@interface RatingViewController ()<UITextViewDelegate,BSKeyboardControlsDelegate,UICollectionViewDelegate> {
    QuestionModel *questionData;
    NSMutableDictionary *starRatingDict;
    NSDictionary *scaleLabelDict;
    GlobalImageVideoViewController *globalImageView;
    BOOL isNoRate;
}
@property (weak, nonatomic) IBOutlet UIView *starRatingView;

@property (weak, nonatomic) IBOutlet UIScrollView *ratingScrollView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIView *ratingContentView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *starCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *displayRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *explainReasonTextView;
@property (weak, nonatomic) IBOutlet UILabel *explainReasonLabel;
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UIScrollView *innerScrollView;
@property (weak, nonatomic) IBOutlet UILabel *yourRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;

@end

@implementation RatingViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.viewMoreButton.hidden=YES;
    self.ratingScrollView.scrollEnabled = false;
    [self.questionTextView flashScrollIndicators];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //set question textview frame
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 29, [[UIScreen mainScreen] bounds].size.width-40, 60);
    //set keyboard control
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.explainReasonTextView]]];
    [self.keyboardControls setDelegate:self];
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    //add shadow and corner radius on objects
    [self viewCustomization];
    self.yourRatingLabel.hidden=YES;
    if ([questionData.isWhy isEqualToString:@"0"]) {
        self.explainReasonLabel.hidden=YES;
        self.explainReasonTextView.hidden=YES;
    }
    else {
        self.explainReasonLabel.hidden=NO;
        self.explainReasonTextView.hidden=NO;
    }
    starRatingDict=[[NSMutableDictionary alloc]init];
    for (int i=0; i<=[questionData.scaleMaximum intValue]; i++) {
        [starRatingDict setObject:@"NO" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    scaleLabelDict=[questionData.scaleLables copy];
    //load image video view
    [self loadAttachmentView];
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

#pragma mark - Custom accessors
//add border and set collection view flow layout
- (void)viewCustomization {
    [self.ratingContentView addShadowWithCornerRadius:self.ratingContentView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    [self.explainReasonTextView setTextViewBorder:self.explainReasonTextView color:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
    [self.explainReasonTextView setCornerRadius:5.0f];
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    //settinng collection view cell size according to iPhone screens
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.starCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow-1)-5;
    CGFloat cellWidth;
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        //Set 6 collection view cell in iPad
        cellWidth = (availableWidthForCells / kCellsPerRow)-40;
    }
    else {
        //Set 6 collection view cell in iPhone
        cellWidth = (availableWidthForCells / kCellsPerRow)-10;
    }
    flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
    //if no rating is not allowed set collection view insets
    if ([questionData.scaleMaximum intValue]<6 && [questionData.allowNoRate isEqualToString:@"0"]) {
        if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
            [self.starCollectionView setContentInset:UIEdgeInsetsMake(0, ((550)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*([questionData.scaleMaximum intValue]-1))-11, 0, ((550)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*([questionData.scaleMaximum intValue]-1))-11)];
        }
        else {
            [self.starCollectionView setContentInset:UIEdgeInsetsMake(0, (([[UIScreen mainScreen] bounds].size.width-36)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*([questionData.scaleMaximum intValue]-1))-11, 0, (([[UIScreen mainScreen] bounds].size.width-36)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*([questionData.scaleMaximum intValue]-1))-11)];
        }
    }
    //if no rating is allowed set collection view insets
    else if ([questionData.scaleMaximum intValue]<6 && [questionData.allowNoRate isEqualToString:@"1"]) {
        if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
            [self.starCollectionView setContentInset:UIEdgeInsetsMake(0, ((550)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*(([questionData.scaleMaximum intValue]+1)-1))-11, 0, ((550)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*(([questionData.scaleMaximum intValue]+1)-1))-11)];
        }
        else {
            [self.starCollectionView setContentInset:UIEdgeInsetsMake(0, (([[UIScreen mainScreen] bounds].size.width-36)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*(([questionData.scaleMaximum intValue]+1)-1))-11, 0, (([[UIScreen mainScreen] bounds].size.width-36)/2)-((int)cellWidth/2)-(((int)cellWidth/2)*(([questionData.scaleMaximum intValue]+1)-1))-11)];
        }
    }
    //display vie more button is question length is more than 3 lines
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
}

- (void) loadAttachmentView {
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
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
        self.innerScrollView.scrollEnabled=false;
    }
    else {
        self.innerScrollView.scrollEnabled=true;
        [self.attachmentView addSubview:globalImageView.view];
    }
    //change star view height when stars
    self.starRatingView.translatesAutoresizingMaskIntoConstraints=YES;
    
    //if attachment view is not present set star view frame
    if ([questionData.isWhy isEqualToString:@"0"] && 0==questionData.answerAttachments.count) {
        self.starCollectionView.translatesAutoresizingMaskIntoConstraints = YES;
        //if maximum stars greater than 5
        if ([questionData.scaleMaximum intValue]>6) {
            //change framing for iPad devices
            if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
                self.starCollectionView.frame = CGRectMake((([[UIScreen mainScreen] bounds].size.width-20)/2) - 275, self.starCollectionView.frame.origin.y, 550, 100);
            }
            //change framing for iPhone devices
            else {
                self.starCollectionView.frame=CGRectMake(8, self.starCollectionView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width-36, 100);
            }
            if([[UIScreen mainScreen] bounds].size.height<=568){
                self.starRatingView.frame= CGRectMake(0, (self.ratingContentView.frame.size.height/2-self.starRatingView.frame.size.height/2)-55, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height+60);
            }
            else {
                self.starRatingView.frame= CGRectMake(0, (self.ratingContentView.frame.size.height/2-self.starRatingView.frame.size.height/2)-55, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height+60);
            }
        }
        //maximum stars less then equals to 5
        else {
            //change framing for iPad devices
            if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
                self.starCollectionView.frame = CGRectMake((([[UIScreen mainScreen] bounds].size.width-20)/2) - 275, self.starCollectionView.frame.origin.y, 550, 50);
            }
            //change framing for iPhone devices
            else{
                self.starCollectionView.frame=CGRectMake(8, self.starCollectionView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width-36, self.starCollectionView.frame.size.height);
            }
            if([[UIScreen mainScreen] bounds].size.height<=568){
                self.starRatingView.frame= CGRectMake(0, (self.ratingContentView.frame.size.height/2-self.starRatingView.frame.size.height/2)-55, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height+60);
            }
            else {
                self.starRatingView.frame= CGRectMake(0, (self.ratingContentView.frame.size.height/2-self.starRatingView.frame.size.height/2)-20, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height+60);
            }
        }
    }
    //if attachment view is present set star view frame
    else {
        self.starCollectionView.translatesAutoresizingMaskIntoConstraints = YES;
        if ([questionData.scaleMaximum intValue]>6) {
            if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
                self.starCollectionView.frame = CGRectMake((([[UIScreen mainScreen] bounds].size.width-20)/2) - 275, self.starCollectionView.frame.origin.y, 550, 100);
            }
            else {
                self.starCollectionView.frame=CGRectMake(8, self.starCollectionView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width-36, 100);
            }
            self.starRatingView.frame= CGRectMake(0, self.attachmentView.frame.origin.y+self.attachmentView.frame.size.height+25, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height+60);
        }
    }
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction{
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls{
    [self.ratingScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.ratingScrollView.scrollEnabled = false;
    [keyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.keyboardControls setActiveField:textView];
    self.ratingScrollView.scrollEnabled = true;
    if (([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad)) {
        [self.ratingScrollView setContentOffset:CGPointMake(0, 210) animated:YES];
    }
    else {
        [self.ratingScrollView setContentOffset:CGPointMake(0, 410) animated:YES];
    }
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;//return number of section
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([questionData.allowNoRate isEqualToString:@"1"]) {
        return [questionData.scaleMaximum intValue]+1;
    }
    else {
        return [questionData.scaleMaximum intValue];//return maximum scale count
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //display cell data
    static NSString *identifier = @"ratingCell";
    RatingViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //if no rating is allowed show N/A button
    if (indexPath.row==[questionData.scaleMaximum intValue] && ![[starRatingDict objectForKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[questionData.scaleMaximum intValue]]] boolValue]) {
        cell.ratingImageView.hidden=YES;
        cell.displayRatingLabel.hidden=NO;
        cell.noAnswerLabel.hidden=NO;
        cell.noAnswerLabel.backgroundColor=[UIColor whiteColor];
        cell.noAnswerLabel.titleLabel.textColor=[UIColor colorWithRed:1.0/255.0 green:58.0/255.0 blue:78.0/255.0 alpha:1.0];
        [cell.noAnswerLabel setCornerRadius:2.0f];
        [cell.noAnswerLabel setBorder:cell.noAnswerLabel color:[UIColor colorWithRed:23.0/255.0 green:183.0/255.0 blue:195.0/255.0 alpha:1.0]];
    }
    //if no rating is allowed hide N/A button
    else {
        if (indexPath.row!=[questionData.scaleMaximum intValue]) {
            cell.ratingImageView.hidden=NO;
            cell.displayRatingLabel.hidden=NO;
            cell.noAnswerLabel.hidden=YES;
            cell.displayRatingLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            [cell displayCellData:[[starRatingDict objectForKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]] boolValue]];
        }
        else {
            cell.ratingImageView.hidden=YES;
            cell.displayRatingLabel.hidden=YES;
            cell.noAnswerLabel.hidden=NO;
            cell.noAnswerLabel.titleLabel.textColor=[UIColor whiteColor];
            cell.noAnswerLabel.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:185.0/255.0 blue:194.0/255.0 alpha:1.0];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView==self.starCollectionView) {
        RatingViewCell *ratingCell =(RatingViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        isNoRate=true;
        //if no rating is not allowed
        if (![[starRatingDict objectForKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]] boolValue]) {
            self.yourRatingLabel.hidden=NO;
            //set star selected for selected index
            for (int i=0; i<=indexPath.row; i++) {
                [starRatingDict setObject:[NSNumber numberWithBool:YES] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
                self.displayRatingLabel.text=ratingCell.displayRatingLabel.text;
            }
            [starRatingDict setObject:[NSNumber numberWithBool:NO] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[questionData.scaleMaximum intValue]]];
            //set display label and rating text
            if (scaleLabelDict[self.displayRatingLabel.text]) {
                if ([self isInteger:[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]]]) {
                    self.displayTextLabel.hidden=YES;
                }
                else {
                    self.displayTextLabel.hidden=NO;
                    self.displayTextLabel.text=[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]];
                }
            }
        }
        else {
            self.yourRatingLabel.hidden=NO;
            //set star deselected for selected index
            for (int i=(int)indexPath.row; i<[questionData.scaleMaximum intValue]-1; i++) {
                [starRatingDict setObject:[NSNumber numberWithBool:NO] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i+1]];
            }
            //set display label and rating text
            self.displayRatingLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            if (scaleLabelDict[self.displayRatingLabel.text]) {
                if ([self isInteger:[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]]]) {
                    self.displayTextLabel.hidden=YES;
                }
                else {
                    self.displayTextLabel.hidden=NO;
                    self.displayTextLabel.text=[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]];
                }
            }
        }
        if ([questionData.allowNoRate isEqualToString:@"1"]) {
            //if no rating is allowed
            if (indexPath.row==[questionData.scaleMaximum intValue]) {
                for (int i=0; i<indexPath.row; i++) {
                    [starRatingDict setObject:[NSNumber numberWithBool:NO] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
                }
                [starRatingDict setObject:[NSNumber numberWithBool:YES] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[questionData.scaleMaximum intValue]]];
                self.yourRatingLabel.hidden=YES;
                self.displayTextLabel.hidden=YES;
                self.displayRatingLabel.hidden=YES;
                ratingCell.noAnswerLabel.titleLabel.textColor=[UIColor whiteColor];
                ratingCell.noAnswerLabel.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:185.0/255.0 blue:194.0/255.0 alpha:1.0];
            }
            else {
                self.displayRatingLabel.hidden=NO;
            }
        }
        [self.starCollectionView reloadData];
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
            //play video in movie player
            AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
            NSString* strUrl =attachments.attachmentURL;
            NSURL *fileURL = [NSURL URLWithString: strUrl];
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
            [self presentViewController:moviePlayer animated:YES completion:NULL];
        }
    }
}

//check if string contains integer value or not
- (BOOL)isInteger:(NSString *)toCheck {
    NSScanner* scan = [NSScanner scannerWithString:toCheck];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    [self.keyboardControls.activeField resignFirstResponder];
    [self.ratingScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.ratingScrollView.scrollEnabled = false;
    if ([questionData.isWhy isEqualToString:@"1"]) {
        if (![questionData.allowNoRate isEqualToString:@"0"]) {
            if (([self.displayRatingLabel.text isEqualToString:@""])) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
            }
            else if ([self.explainReasonTextView.text isEqualToString:@""]) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"Please fill out the 'Please Explain Why'." closeButtonTitle:@"Done" duration:0.0f];
            }
            else {
                [self saveAnswerInDatabase];
            }
        }
        else {
            if (([self.displayRatingLabel.text isEqualToString:@""])) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
            }
            else if ([self.explainReasonTextView.text isEqualToString:@""]) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"Please fill out the 'Please Explain Why'." closeButtonTitle:@"Done" duration:0.0f];
            }
            else {
                 [self saveAnswerInDatabase];
            }
        }
    }
    else {
        if ([questionData.allowNoRate isEqualToString:@"0"]) {
            if ([self.displayRatingLabel.text isEqualToString:@""]) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
            }
            else {
                [self saveAnswerInDatabase];
            }
        }
        else {
            if (!isNoRate) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
            }
            else {
                [self saveAnswerInDatabase];
            }
        }
    }
}

- (void)saveAnswerInDatabase {
    //When user click on next save data in database
    AnswerModel *answerData=[AnswerModel new];
    answerData.stepId=questionData.questionId;
    if ([questionData.allowNoRate isEqualToString:@"0"]) {
        answerData.ratingResponse=self.displayRatingLabel.text;
    }
    else {
        answerData.ratingResponse=@"-1";
    }
    answerData.ratingWhyResponse=self.explainReasonTextView.text;
    [AnswerDatabase insertDataInAnswerTable:answerData];
    //calculate length of answer
    NSData *data = [[NSString stringWithFormat:@"%@ %@",answerData.ratingResponse,answerData.ratingWhyResponse] dataUsingEncoding:NSASCIIStringEncoding];
    NSUInteger myLength = data.length;
    [UserDefaultManager setAnswerFileSize:(double)myLength];
    [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
    //navigate to screen according to the question
    [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
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
#pragma mark - end

@end
