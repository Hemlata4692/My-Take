//
//  NPSRatingViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "NetPromotRatingViewController.h"
#import "QuestionModel.h"
#import "RatingViewCell.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "SingleChoiceViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import "ImagePreviewViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"

#define kCellsPerRow 6  //Set number of cells in collection view

@interface NetPromotRatingViewController () <UICollectionViewDelegate> {
    QuestionModel *questionData;
    NSMutableDictionary *starRatingDict;
    NSDictionary *scaleLabelDict;
    GlobalImageVideoViewController *globalImageView;
}
@property (weak, nonatomic) IBOutlet UIView *starRatingView;
@property (weak, nonatomic) IBOutlet UIScrollView *npsRatingScrollView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIView *netPromoteRatingContentView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *starCollectionView;
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UILabel *displayRatingLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *innerScrollView;
@property (weak, nonatomic) IBOutlet UILabel *displayScaleLabelText;
@property (weak, nonatomic) IBOutlet UILabel *yourRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation NetPromotRatingViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.yourRatingLabel.hidden=YES;
    self.viewMoreButton.hidden=YES;
    [self.questionTextView flashScrollIndicators];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //set framing of star collection view for iPad devices
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        self.starCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
        self.starCollectionView.frame = CGRectMake((([[UIScreen mainScreen] bounds].size.width-20)/2) - 275, self.starCollectionView.frame.origin.y, 550, 150);
    }
    //set question text view frame
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 29, [[UIScreen mainScreen] bounds].size.width-40, 60);
    self.npsRatingScrollView.scrollEnabled=false;
    //display question using database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    //add shadow and corner radius to main view
    [self viewCustomization];
    //initally set star selection no
    starRatingDict=[[NSMutableDictionary alloc]init];
    for (int i=0; i<11; i++) {
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
- (void)viewCustomization {
    [self.netPromoteRatingContentView addShadowWithCornerRadius:self.netPromoteRatingContentView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    //settinng collection view cell size according to iPhone screens
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.starCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow-1)-5;
    CGFloat cellWidth;
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        //set 6 collection view cell in iPad
        cellWidth = (availableWidthForCells / kCellsPerRow)-40;
    }
    else {
        //set 6 collection view cell in iPhone
        cellWidth = (availableWidthForCells / kCellsPerRow)-10;
    }
    flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
    
}

- (void)loadAttachmentView {
    //load image video view
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    if (([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad)) {
        globalImageView.view.frame = CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width-40, 120);
    }
    else {
        globalImageView.view.frame = CGRectMake(10, 0, [[UIScreen mainScreen] bounds].size.width-40, 220);
        self.attachmentView.frame= CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 250);
    }
    //add collection view delegate
    globalImageView.imageVideoCollectionView.delegate=self;
    if (0==questionData.answerAttachments.count) {
        //if no attachments available
        CGRect frame = self.attachmentView.frame;
        frame.size = CGSizeMake(0, 0);
        self.attachmentView.frame = frame;
        self.innerScrollView.scrollEnabled=false;
        self.starRatingView.translatesAutoresizingMaskIntoConstraints=YES;
        //change star view framing according to screen size
        if([[UIScreen mainScreen] bounds].size.height<=568){
            self.starRatingView.frame= CGRectMake(0, (self.netPromoteRatingContentView.frame.size.height/2-self.starRatingView.frame.size.height/2)-55, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height);
        }
        else {
            self.starRatingView.frame= CGRectMake(0, (self.netPromoteRatingContentView.frame.size.height/2-self.starRatingView.frame.size.height/2)-20, [[UIScreen mainScreen] bounds].size.width-20, self.starRatingView.frame.size.height);
        }
    }
    else {
        self.innerScrollView.scrollEnabled=true;
        [self.attachmentView addSubview:globalImageView.view];
    }
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;//return number of section
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([questionData.allowNoRate isEqualToString:@"1"]) {
        return 12;
    }
    else {
        return 11;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //display cell data
    static NSString *identifier = @"ratingCell";
    RatingViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //if no rating is allowed show N/A button
    if (indexPath.row==11 && ![[starRatingDict objectForKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[questionData.scaleMaximum intValue]]] boolValue]) {
        cell.ratingImageView.hidden=YES;
        cell.displayRatingLabel.hidden=YES;
        cell.noAnswerLabel.hidden=NO;
        cell.noAnswerLabel.backgroundColor=[UIColor whiteColor];
        [cell.noAnswerLabel setCornerRadius:2.0f];
        [cell.noAnswerLabel setBorder:cell.noAnswerLabel color:[UIColor colorWithRed:23.0/255.0 green:183.0/255.0 blue:195.0/255.0 alpha:1.0]];
    }
    //if no rating is not allowed hide N/A button
    else {
        if (indexPath.row!=11) {
            cell.ratingImageView.hidden=NO;
            cell.displayRatingLabel.hidden=NO;
            cell.noAnswerLabel.hidden=YES;
            cell.displayRatingLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
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
        //if no rating is not allowed
        // if ([questionData.allowNoRate isEqualToString:@"0"]) {
        self.yourRatingLabel.hidden=NO;
        if (![[starRatingDict objectForKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]] boolValue]) {
            //set star selected for selected index
            for (int i=0; i<=indexPath.row; i++) {
                [starRatingDict setObject:[NSNumber numberWithBool:YES] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
            }
            if ([questionData.allowNoRate isEqualToString:@"1"]) {
                [starRatingDict setObject:[NSNumber numberWithBool:NO] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:11]];
            }
            //set display label and rating text
            self.displayRatingLabel.text=ratingCell.displayRatingLabel.text;
            if (scaleLabelDict[self.displayRatingLabel.text]) {
                if ([self isInteger:[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]]]) {
                    self.displayScaleLabelText.hidden=YES;
                }
                else {
                    self.displayScaleLabelText.hidden=NO;
                    self.displayScaleLabelText.text=[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]];
                }
            }
        }
        else {
            //set star deselected for selected index
            //if index is last index disable selection
            if (indexPath.row!=10) {
                for (int i=(int)indexPath.row; i<11; i++) {
                    if (i==0) {
                        [starRatingDict setObject:[NSNumber numberWithBool:YES] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
                    }
                    else {
                        [starRatingDict setObject:[NSNumber numberWithBool:NO] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
                    }
                }
                //set display label and rating text
                if (indexPath.row==0) {
                    self.displayRatingLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
                }
                else {
                    self.displayRatingLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row-1];
                }
                if (scaleLabelDict[self.displayRatingLabel.text]) {
                    if ([self isInteger:[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]]]) {
                        self.displayScaleLabelText.hidden=YES;
                    }
                    else {
                        self.displayScaleLabelText.hidden=NO;
                        self.displayScaleLabelText.text=[NSString stringWithFormat:@"%@",scaleLabelDict[self.displayRatingLabel.text]];
                    }
                }
            }
        }
        if ([questionData.allowNoRate isEqualToString:@"1"]) {
            //if no rating is allowed
            if (indexPath.row==12) {
                for (int i=0; i<indexPath.row; i++) {
                    [starRatingDict setObject:[NSNumber numberWithBool:NO] forKey:[[[starRatingDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
                }
                self.yourRatingLabel.hidden=YES;
                self.displayRatingLabel.hidden=YES;
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
            //open image in preiview view
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
    //When user click on next save data in database
    if ([self.displayRatingLabel.text isEqualToString:@""]) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        //save answer in database
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        if ([questionData.allowNoRate isEqualToString:@"0"]) {
            answerData.ratingResponse=self.displayRatingLabel.text;
        }
        else {
            answerData.ratingResponse=@"-1";
        }
        [AnswerDatabase insertDataInAnswerTable:answerData];
        
        //calculate length of answer
        NSData *data = [[NSString stringWithFormat:@"%@",answerData.ratingResponse] dataUsingEncoding:NSASCIIStringEncoding];
        NSUInteger myLength = data.length;
        [UserDefaultManager setAnswerFileSize:(double)myLength];
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
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
#pragma mark - end
@end
