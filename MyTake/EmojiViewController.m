//
//  EmojiViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "EmojiViewController.h"
#import "EmojiCollectionViewCell.h"
#import "QuestionModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "RatingViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import "ImagePreviewViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"

#define kCellsPerRow 3  //Set number of cells in collection view

@interface EmojiViewController () <UICollectionViewDelegate>{
    QuestionModel *questionData;
    NSMutableDictionary *emojiPlistData;
    NSString *plistPath;
    NSMutableArray *selectedAnswer;
    GlobalImageVideoViewController *globalImageView;
}

@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (strong, nonatomic) IBOutlet UICollectionView *emojiCollectionView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation EmojiViewController
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
    selectedAnswer = [NSMutableArray new];
    //display question
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 29, [[UIScreen mainScreen] bounds].size.width-40, 60);
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    [self viewCustomization];
    [self fetchEmojiFromPlistAndAddAtatchmentView];
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
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    //setting collection view cell size according to iPhone screens
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.emojiCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow-1)-32;
    CGFloat cellWidth;
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        //set 3 collection view cell in iPad
        cellWidth = (availableWidthForCells / kCellsPerRow) - 130;
    }
    else {
        //set 3 collection view cell in iPhone
        cellWidth = (availableWidthForCells / kCellsPerRow) - 30;
    }
    flowLayout.itemSize = CGSizeMake(cellWidth, 65.0f);
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
}

- (void)fetchEmojiFromPlistAndAddAtatchmentView {
    //fetch emoji data from plist file
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    plistPath = [documentsPath stringByAppendingPathComponent:@"EmojisPList.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisPList" ofType:@"plist"];
    }
    emojiPlistData = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] mutableCopy];
    [self.emojiCollectionView reloadData];
    //load image video view
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    //set image video view frame according to iPhone and iPad
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
        if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
            self.emojiCollectionView.translatesAutoresizingMaskIntoConstraints = YES;
            self.emojiCollectionView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width/2) - 200, self.attachmentView.frame.origin.y+self.attachmentView.frame.size.height+100, 400, [[UIScreen mainScreen] bounds].size.height - 261);
        }
    }
    else {
        [self.attachmentView addSubview:globalImageView.view];
        //change framing for iPad devices
        if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
            self.emojiCollectionView.translatesAutoresizingMaskIntoConstraints = YES;
            self.emojiCollectionView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width/2) - 200, self.attachmentView.frame.origin.y+self.attachmentView.frame.size.height+30, 400, [[UIScreen mainScreen] bounds].size.height - 261);
        }
        //end
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    //when user click on next save answer in database
    if ([selectedAnswer count] == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.emojiResponse=[selectedAnswer componentsJoinedByString:@","];
        [AnswerDatabase insertDataInAnswerTable:answerData];
        //calculate length of answer
        NSData *data = [[NSString stringWithFormat:@"%@",answerData.emojiResponse] dataUsingEncoding:NSASCIIStringEncoding];
        NSUInteger myLength = data.length;
        [UserDefaultManager setAnswerFileSize:(double)myLength];
        
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    }
}

//open view more question text pop up
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;//return number of section
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] count];//return array count
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //display cell data
    static NSString *identifier = @"emojiCell";
    EmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell displayCellData:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row] isSelected:[[emojiPlistData objectForKey:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]] boolValue]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //select and deselt cell
    if (collectionView==self.emojiCollectionView) {
        if (![[emojiPlistData objectForKey:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]] boolValue]) {
            
            [emojiPlistData setObject:[NSNumber numberWithBool:YES] forKey:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]];
            [selectedAnswer addObject:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]];
        }
        else {
            [emojiPlistData setObject:[NSNumber numberWithBool:NO] forKey:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]];
            [selectedAnswer removeObject:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]];
        }
        
        EmojiCollectionViewCell *emojiCell =(EmojiCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [emojiCell displayCellData:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row] isSelected:[[emojiPlistData objectForKey:[[[emojiPlistData allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row]] boolValue]];
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
#pragma mark - end
@end
