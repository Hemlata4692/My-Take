//
//  DashboardViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "DashboardViewController.h"
#import "DashboardViewCell.h"
#import "MissionDataModel.h"
#import "InstructionViewController.h"
#import "MissionListDatabase.h"
#import "TextDisplayViewController.h"
#import "MissionDetailDatabase.h"
#import "GlobalNavigationViewController.h"
#import "QuestionModel.h"
#import "MissionSubmittedViewController.h"
#import "AnswerDatabase.h"
#import "MissionDetailModel.h"

@interface DashboardViewController () {
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *missionTableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultFoundLabel;
@property (strong,nonatomic) NSMutableArray *missionListDataArray;
@end

@implementation DashboardViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Missions";
    self.missionListDataArray=[[NSMutableArray alloc]init];
    // Pull To Refresh
    refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 10, 10)];
    [self.missionTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.missionTableView.alwaysBounceVertical = YES;
    [UserDefaultManager setValue:nil key:@"missionStarted"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //call misison list data
    [myDelegate showIndicator];
    [self performSelector:@selector(getAllMissions) withObject:nil afterDelay:.1];
    //set current navigation
    myDelegate.currentNavigationController=self.navigationController;
}
#pragma mark - end

#pragma mark - Refresh table
//Pull to refresh implementation on my submission data
- (void)refreshTable {
    [UserDefaultManager setValue:nil key:@"missionStarted"];
    [self performSelector:@selector(getAllMissions) withObject:nil afterDelay:.1];
    [refreshControl endRefreshing];
}
#pragma mark - end

#pragma mark - Webservice
//Get mission liost data from webservice
- (void)getAllMissions {
    MissionDataModel *missionModel = [MissionDataModel new];
    [missionModel getMissionListOnSuccess:^(id dataArray) {
        self.missionListDataArray=[dataArray mutableCopy];
        //if no result found
        if (0==self.missionListDataArray.count || nil==self.missionListDataArray) {
            self.noResultFoundLabel.hidden=NO;
            self.missionTableView.hidden=YES;
            self.noResultFoundLabel.text=@"No mission assigned to you yet.";
        }
        [self.missionTableView reloadData];
        
    } onfailure:^(NSError *error) {
        //webservice faliure fetch data from database
        NSMutableArray *dataArray=[NSMutableArray new];
        dataArray = [MissionListDatabase getMisionsList];
        self.missionListDataArray=[dataArray mutableCopy];
        //if no result found
        if (0==self.missionListDataArray.count || nil==self.missionListDataArray) {
            self.noResultFoundLabel.hidden=NO;
            self.missionTableView.hidden=YES;
            self.noResultFoundLabel.text=@"No mission assigned to you yet.";
        }
        [self.missionTableView reloadData];
    }];
    
}
#pragma mark - end

#pragma mark - Table view delegate and datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.missionListDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *simpleTableIdentifier = @"missionCell";
    DashboardViewCell *missionCell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (missionCell == nil) {
        missionCell = [[DashboardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    //hide separator if result is only 1 mission
    if (self.missionListDataArray.count==1) {
        missionCell.topSeparator.hidden=YES;
        missionCell.bottomSeparator.hidden=YES;
    }
    if (indexPath.row==0) {
        missionCell.topSeparator.hidden=YES;
    }
    else {
        missionCell.topSeparator.hidden=NO;
    }
    //display data on cells
    MissionDataModel *data=[self.missionListDataArray objectAtIndex:indexPath.row];
    [missionCell displayMissionListData:data indexPath:(int)indexPath.row];
    [myDelegate stopIndicator];
    return missionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [myDelegate showIndicator];
    MissionDataModel *data=[self.missionListDataArray objectAtIndex:indexPath.row];
    [UserDefaultManager setValue:data.missionId key:@"missionId"];
    [UserDefaultManager setValue:data.missionTitle key:@"missionTitle"];
    
    //fetch questions detail
    NSMutableArray *questionDetailDataArray=[MissionDetailDatabase getQuestionDetail];
    QuestionModel *questionDetails;
    if (questionDetailDataArray.count>0) {
        questionDetails=[questionDetailDataArray objectAtIndex:0];
    }
    
    //fetch welcome message and end message
    NSMutableArray *dataArray=[MissionDetailDatabase getMissionDetailData];
    MissionDetailModel *missionDetailData = [dataArray objectAtIndex:0];
    [myDelegate stopIndicator];
    
    //if mission end date is paased show alert to user
    //if ([data.status isEqualToString:@"Expired"] && ![data.missionStatus isEqualToString:@"complete"])
    if ([data.status isEqualToString:@"Expired"]) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:nil title:@"Alert" subTitle:@"This mission has expired and is no longer available." closeButtonTitle:@"Done" duration:0.0f];
    }
    //if time stamp is changed for any mission show alert to user if mission is in progress and pending
   else if ((![data.timeStamp isEqualToString:questionDetails.missionTimeStamp]) && nil!=questionDetails.missionTimeStamp && (![data.missionStatus isEqualToString:@"none"] && (![data.missionStatus isEqualToString:@"complete"]))) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Ok" actionBlock:^(void) {
            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            InstructionViewController *instructionView =[storyboard instantiateViewControllerWithIdentifier:@"InstructionViewController"];
            instructionView.missionTimeStamp=data.timeStamp;
            [self.navigationController pushViewController:instructionView animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"This mission has been modified by the my-take team. You must restart the mission, we apologize for any inconvenience." closeButtonTitle:nil duration:0.0f];
    }
    //if mission is complete do not allow user to navigate
    else if ([data.missionStatus isEqualToString:@"complete"]) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:nil title:@"Alert" subTitle:@"You have already completed this mission. Thank you for your feedback!" closeButtonTitle:@"Done" duration:0.0f];
    }
    //if mission is pending and no answer in saved in data base show alert to user
    else if (([data.missionStatus isEqualToString:@"pending"] || [data.missionStatus isEqualToString:@"Pending Submission"]) && [AnswerDatabase checkRecordExistsForPendingSubmission]==0) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Ok" actionBlock:^(void) {
            [self setScreenNavigation:data missionDetailData:missionDetailData questionDetailDataArray:questionDetailDataArray];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"You have already begun this mission from another device. You must restart the mission on this device, or continue the mission from your other device." closeButtonTitle:nil duration:0.0f];
    }
    //if user has started mission then land him to the last answered screen else on instruction screen
    else {
        [self setScreenNavigation:data missionDetailData:missionDetailData questionDetailDataArray:questionDetailDataArray];
    }
}

//set screen navigation according to last answered question
- (void)setScreenNavigation:(MissionDataModel *)data missionDetailData:(MissionDetailModel*)missionDetailData questionDetailDataArray:(NSMutableArray*)questionDetailDataArray{
    //move to last answered question
    if (nil!=[UserDefaultManager getValue:@"progressDict"] && [[[UserDefaultManager getValue:@"progressDict"] allKeys] containsObject:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]]) {
        [UserDefaultManager setValue:missionDetailData.welcomeMessage key:@"InstructionPopUp"];
        [UserDefaultManager setValue:@"In Progress" key:@"missionStarted"];
        [GlobalNavigationViewController setScreenNavigation:questionDetailDataArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    }
    // move to instruction screen
    else {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        InstructionViewController *instructionView =[storyboard instantiateViewControllerWithIdentifier:@"InstructionViewController"];
        instructionView.missionTimeStamp=data.timeStamp;
        [self.navigationController pushViewController:instructionView animated:YES];
    }
}

//set dynamic height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //set dynamic height according to screen size
    CGSize dynamicHeight;
    dynamicHeight =  CGSizeMake(self.view.frame.size.width, (((float)155/(float)320)*self.view.frame.size.width));
    return dynamicHeight.height;
}
#pragma mark - end

@end
