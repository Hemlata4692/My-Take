//
//  MultiChoiceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MultiChoiceViewController.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "MultiChoiceCell.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"

@interface MultiChoiceViewController ()<UITextViewDelegate,UICollectionViewDelegate>{
    
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    NSMutableArray *multiChoiceListData;
    NSMutableArray *selectedIndex;
    int currentSelectedIndex;
    BOOL isExclusive;
    float attachmentViewHeight;
    float tableViewHeight;
}
@property (strong, nonatomic) IBOutlet UITableView *multiChoiceTableView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (strong, nonatomic) IBOutlet UIScrollView *multiChoiceScrollView;
@property (strong, nonatomic) IBOutlet UIView *multiChoiceView;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation MultiChoiceViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.questionTextView flashScrollIndicators];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.viewMoreButton.hidden=YES;
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 29, [[UIScreen mainScreen] bounds].size.width-40, 60);
    [self viewCustomization];
    // Do any additional setup after loading the view.
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
    //initially set values
    attachmentViewHeight=0.0f;
    selectedIndex=[NSMutableArray new];
    isExclusive=false;
    currentSelectedIndex=-1;
    tableViewHeight=0.0f;
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    multiChoiceListData=[NSMutableArray new];
    
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    
    //fetch singleChoice data from dataBase array and set in local initialize multiChoiceListData
    for (int i=0; i<questionData.answerOptions.count; i++)
    {
        NSDictionary * answerOptionsDict=[questionData.answerOptions objectAtIndex:i];
        AnswerOptionsModel * answerOptionsData=[[AnswerOptionsModel alloc]init];
        answerOptionsData.answerId=answerOptionsDict[@"AnswerID"];
        answerOptionsData.answerText=answerOptionsDict[@"AnswerText"];
        answerOptionsData.answerImage=answerOptionsDict[@"Image"];
        answerOptionsData.answerThumbnailImage=answerOptionsDict[@"ImageThumbnail "];
        answerOptionsData.isExclusive=answerOptionsDict[@"IsExclusive "];
        answerOptionsData.isOther=answerOptionsDict[@"IsOther"];
        answerOptionsData.isSelected=NO;    //Intially set unselected cells
        [multiChoiceListData addObject:answerOptionsData];
    }
    
    //Add global image/video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    
    //show view more button if text length is more then 3 lines
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
    [self removeAutolayouts];   //remove autolayout of resizing objects
    [self viewObjectsResize];   //change framing according to cases and list count
}

- (void)removeAutolayouts {
    self.multiChoiceView.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    self.multiChoiceTableView.translatesAutoresizingMaskIntoConstraints=YES;
}

- (void)viewObjectsResize {
    self.multiChoiceView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-163);
    self.attachmentView.frame= CGRectMake(0, 0, self.multiChoiceView.frame.size.width, 140);
    //show and global image view according to attachments is available or not
    if (0==questionData.answerAttachments.count) {
        attachmentViewHeight=0.0f;
        //if no attachments available
        CGRect frame = self.attachmentView.frame;
        frame.size = CGSizeMake(0, 0);
        self.attachmentView.frame = frame;
    }
    else {
        if (([[UIDevice currentDevice] userInterfaceIdiom]!= UIUserInterfaceIdiomPad)) {
            //if current device is iPhone then set frame
            attachmentViewHeight=120.0f;
            globalImageView.view.frame = CGRectMake(10, 0, self.multiChoiceView.frame.size.width-20, attachmentViewHeight);
        }
        else {
            //if current device is iPad then set frame
            attachmentViewHeight=220.0f;
            self.attachmentView.frame= CGRectMake(0, 0, self.multiChoiceView.frame.size.width, 250);
            globalImageView.view.frame = CGRectMake(10, 0, self.multiChoiceView.frame.size.width-20, attachmentViewHeight);
        }
        [self.attachmentView addSubview:globalImageView.view];
        globalImageView.imageVideoCollectionView.delegate=self; //add collection view delegate
    }
    //set single choice table view size according to choice is selected or not
    float height=0.0f;
    for (int i=0; i<[multiChoiceListData count]; i++) {
        if ([[multiChoiceListData objectAtIndex:i] isSelected]&&([[[multiChoiceListData objectAtIndex:i] isOther] intValue]==1)) {
            height+=138.0f;
        }
        else {
            height+=60.0f;
        }
    }
    self.multiChoiceTableView.frame= CGRectMake(0, self.attachmentView.frame.size.height, self.multiChoiceView.frame.size.width, height+5.0f);
    self.multiChoiceView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, self.multiChoiceTableView.frame.origin.y+self.multiChoiceTableView.frame.size.height);
    self.multiChoiceScrollView.contentSize = CGSizeMake(0,self.multiChoiceView.frame.size.height);
}

#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[multiChoiceListData objectAtIndex:indexPath.row] isSelected]&&([[[multiChoiceListData objectAtIndex:indexPath.row] isOther] intValue]==1)) {
        return 138.0f;//return 60(text view height) + 79.0f(60(above view height)+9(top space of textView)+10(bottom space of textView));
    }
    else {
        return 60.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return multiChoiceListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultiChoiceCell *cell;
    NSString *simpleTableIdentifier=@"MultiChoiceCell";
    cell=[self.multiChoiceTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [cell displayCellData:[multiChoiceListData objectAtIndex:indexPath.row] isCurrentSelectedIndex:((currentSelectedIndex==(int)indexPath.row) ? true : false) isExclusive:isExclusive];
    cell.pleaseSpecifyAnswerTextView.tag=(int)indexPath.row;
    cell.checkBoxButton.tag=(int)indexPath.row;
    [cell.checkBoxButton addTarget:self action:@selector(checkBoxButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //add toolbar on text view
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithKeyboard:)],
                         nil];
    
    [doneToolbar sizeToFit];
    
    cell.pleaseSpecifyAnswerTextView.inputAccessoryView = doneToolbar;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //select and deselect table view cell
    [self.view endEditing:YES];
    self.multiChoiceScrollView.scrollEnabled = true;
    AnswerOptionsModel *answerOptionsDataObject=[multiChoiceListData objectAtIndex:indexPath.row];
    if (![[multiChoiceListData objectAtIndex:indexPath.row] isSelected]) {
        currentSelectedIndex=(int)indexPath.row;
        if ([[[multiChoiceListData objectAtIndex:indexPath.row] isExclusive] intValue]==1) {
            tableViewHeight=0.0f;
            [selectedIndex removeAllObjects];
            isExclusive=true;
            for (int i=0; i<multiChoiceListData.count; i++) {
                if (i!=(int)indexPath.row) {
                    NSIndexPath *index=[NSIndexPath indexPathForRow:i inSection:0];
                    MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:index];
                    cell.pleaseSpecifyAnswerTextView.text=@"";
                    AnswerOptionsModel *answerOptionsData=[multiChoiceListData objectAtIndex:i];
                    answerOptionsData.isSelected=NO;
                    [multiChoiceListData replaceObjectAtIndex:i withObject:answerOptionsData];
                }
            }
        }
        else {
            isExclusive=false;
        }
        if ([[[multiChoiceListData objectAtIndex:indexPath.row] isOther] intValue]!=0) {
            tableViewHeight+=138;
        }
        answerOptionsDataObject.isSelected=YES;
        [selectedIndex addObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }
    else {
        isExclusive=false;
        currentSelectedIndex=-1;
        if ([[[multiChoiceListData objectAtIndex:indexPath.row] isOther] intValue]!=0) {
            tableViewHeight-=138;
        }
        MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:indexPath];
        answerOptionsDataObject.isSelected=NO;
        cell.pleaseSpecifyAnswerTextView.text=@"";
        [selectedIndex removeObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }
    [multiChoiceListData replaceObjectAtIndex:indexPath.row withObject:answerOptionsDataObject];
    [self.multiChoiceTableView reloadData];
    [self viewObjectsResize];
}
#pragma mark - end

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    float height=0.0f;
    for (int i=0; i<(int)textView.tag; i++) {
        if ([[multiChoiceListData objectAtIndex:i] isSelected]&&([[[multiChoiceListData objectAtIndex:i] isOther] intValue]==1)) {
            height+=138.0f;
        }
        else {
            height+=60.0f;
        }
    }
    if([[UIScreen mainScreen] bounds].size.height<=568) {
        [self.multiChoiceScrollView setContentOffset:CGPointMake(0, height+70+attachmentViewHeight) animated:YES];
    }
    else {
        [self.multiChoiceScrollView setContentOffset:CGPointMake(0, height+attachmentViewHeight) animated:YES];
    }
    self.multiChoiceScrollView.scrollEnabled=NO;
}

- (void) doneWithKeyboard: (UITextView *)textView {
    
    [self.view endEditing:YES];
    [self.multiChoiceScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.multiChoiceScrollView.scrollEnabled = true;
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)checkBoxButtonAction:(UIButton *)sender {
    //select and deselect table view cell
    [self.view endEditing:YES];
    self.multiChoiceScrollView.scrollEnabled = true;
    AnswerOptionsModel *answerOptionsDataObject=[multiChoiceListData objectAtIndex:[sender tag]];
    if (![[multiChoiceListData objectAtIndex:[sender tag]] isSelected]) {
        currentSelectedIndex=(int)[sender tag];
        if ([[[multiChoiceListData objectAtIndex:[sender tag]] isExclusive] intValue]==1) {
            tableViewHeight=0.0f;
            [selectedIndex removeAllObjects];
            isExclusive=true;
            for (int i=0; i<multiChoiceListData.count; i++) {
                if (i!=(int)[sender tag]) {
                    NSIndexPath *index=[NSIndexPath indexPathForRow:i inSection:0];
                    MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:index];
                    cell.pleaseSpecifyAnswerTextView.text=@"";
                    AnswerOptionsModel *answerOptionsData=[multiChoiceListData objectAtIndex:i];
                    answerOptionsData.isSelected=NO;
                    [multiChoiceListData replaceObjectAtIndex:i withObject:answerOptionsData];
                }
            }
        }
        else {
            isExclusive=false;
        }
        if ([[[multiChoiceListData objectAtIndex:[sender tag]] isOther] intValue]!=0) {
            tableViewHeight+=138;
        }
        answerOptionsDataObject.isSelected=YES;
        [selectedIndex addObject:[NSString stringWithFormat:@"%d",(int)[sender tag]]];
    }
    else {
        isExclusive=false;
        currentSelectedIndex=-1;
        if ([[[multiChoiceListData objectAtIndex:[sender tag]] isOther] intValue]!=0) {
            tableViewHeight-=138;
        }
        NSIndexPath *index=[NSIndexPath indexPathForRow:[sender tag] inSection:0];
        MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:index];
        answerOptionsDataObject.isSelected=NO;
        cell.pleaseSpecifyAnswerTextView.text=@"";
        [selectedIndex removeObject:[NSString stringWithFormat:@"%d",(int)[sender tag]]];
    }
    [multiChoiceListData replaceObjectAtIndex:[sender tag] withObject:answerOptionsDataObject];
    [self.multiChoiceTableView reloadData];
    [self viewObjectsResize];

     //if thumbnail image then nnavigate to iamge preview screen
    if ((nil!=[[multiChoiceListData objectAtIndex:(int)[sender tag]] answerThumbnailImage])&&![[[multiChoiceListData objectAtIndex:(int)[sender tag]] answerThumbnailImage] isEqualToString:@""]) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.imageURL=[[multiChoiceListData objectAtIndex:(int)[sender tag]] answerImage];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
}

- (IBAction)nextButtonAction:(UIButton *)sender {
    //When user click on next save answer in database
    [self.view endEditing:YES];
    [self.multiChoiceScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.multiChoiceScrollView.scrollEnabled = true;
    if ([self performValidation]) {
        NSMutableDictionary* setJsonAnswerDictObject=[NSMutableDictionary new];
        for (int i=0; i<selectedIndex.count; i++) {
            NSIndexPath *index=[NSIndexPath indexPathForRow:[[selectedIndex objectAtIndex:i] intValue] inSection:0];
            MultiChoiceCell *cell=(MultiChoiceCell *)[self.multiChoiceTableView cellForRowAtIndexPath:index];
            if ([[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] integerValue]] isOther] intValue]==1) {
                [setJsonAnswerDictObject setObject:[NSString stringWithFormat:@"%@,$#,%@",[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] integerValue]] answerId],cell.pleaseSpecifyAnswerTextView.text] forKey:[NSString stringWithFormat:@"%d",i]];
            }
            else {
                [setJsonAnswerDictObject setObject:[NSString stringWithFormat:@"%@",[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] integerValue]] answerId]] forKey:[NSString stringWithFormat:@"%d",i]];
            }
        }
        //When user click on next save answer in database
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.multiAnswerDict=[setJsonAnswerDictObject mutableCopy];;
        [AnswerDatabase insertDataInAnswerTable:answerData];
        //calculate length of answer
        NSData *data = [[NSString stringWithFormat:@"%@",answerData.multiAnswerDict] dataUsingEncoding:NSASCIIStringEncoding];
        NSUInteger myLength = data.length;
        [UserDefaultManager setAnswerFileSize:(double)myLength];
        
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
#pragma mark - end

#pragma mark - Perform validations
- (BOOL)performValidation {
    if (([selectedIndex count] == 0)) {
        return NO;
    }
    else {
        NSIndexPath *index;
        MultiChoiceCell *cell;
        int flag=0;
        for (int i=0; i<selectedIndex.count; i++) {
            index=[NSIndexPath indexPathForRow:[[selectedIndex objectAtIndex:i] intValue] inSection:0];
            cell=(MultiChoiceCell *)[self.multiChoiceTableView cellForRowAtIndexPath:index];
            if (([[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] intValue]] isOther] intValue]==1)&&([cell.pleaseSpecifyAnswerTextView.text isEqualToString:@""]||[cell.pleaseSpecifyAnswerTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length<1)) {
                flag=1;
                break;
            }
        }
        if (flag) {
            return NO;
        }
        else{
            return YES;
        }
    }
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
//Preview image view using collection view delegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
#pragma mark - end
@end
