//
//  MissionCompleteViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionCompleteViewController.h"
#import "UploadMissionViewController.h"
#import "MainSideBarViewController.h"
#import "UploadMissionModel.h"
#import "MissionDataModel.h"
#import "MissionListDatabase.h"
#import "MissionSubmittedViewController.h"
#import "AFNetworkReachabilityManager.h"

@interface MissionCompleteViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextView *missionCompleteTextview;
@property (weak, nonatomic) IBOutlet UIButton *submitNowButton;
@property (weak, nonatomic) IBOutlet UIButton *submitLaterButton;
@property (weak, nonatomic) IBOutlet UIImageView *rocketImage;

@end

@implementation MissionCompleteViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    [self viewCustomization];
    [self displayContentWithFileSize];
}

- (void)displayContentWithFileSize {
    //calculate data size of complete mission
    NSString *dataSize;
    double tempMissionDataSize=[[[UserDefaultManager getValue:@"fileSizeDict"] objectForKey:[NSString stringWithFormat:@"fileSize_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] doubleValue];
    //if data size is less then 1MB
    if (tempMissionDataSize<1024*1024) {
        dataSize=[NSString stringWithFormat:@"%.2f KB",([[[UserDefaultManager getValue:@"fileSizeDict"] objectForKey:[NSString stringWithFormat:@"fileSize_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] doubleValue]/1024.0)];
    }
    //if data size is greater then 1 MB
    else {
        dataSize=[NSString stringWithFormat:@"%.2f MB",([[[UserDefaultManager getValue:@"fileSizeDict"] objectForKey:[NSString stringWithFormat:@"fileSize_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] doubleValue]/1024.0)/1024.0];
    }
    
    if([[UIScreen mainScreen] bounds].size.height<=568){
        self.missionCompleteTextview.text=[NSString stringWithFormat:@"Click submit now to submit your mission immediately. Your mission response is %@. You may also click submit later to archive your response. \n \n You may submit your mission later when connected to wifi.",dataSize];
    }
    else {
        self.missionCompleteTextview.text=[NSString stringWithFormat:@"\n Click submit now to submit your mission immediately. Your mission response is %@. You may also click submit later to archive your response. \n \n You may submit your mission later when connected to wifi.",dataSize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
//add corner radius and border to objects
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    [self.submitLaterButton setCornerRadius:22.0];
    [self.submitLaterButton setBorder:self.submitLaterButton color:[UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0]];
    [self.submitNowButton setCornerRadius:22.0];
    
    //if device is ipad change framing of objects
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        self.missionCompleteTextview.translatesAutoresizingMaskIntoConstraints=YES;
        self.rocketImage.translatesAutoresizingMaskIntoConstraints=YES;
        self.rocketImage.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width/2-self.rocketImage.frame.size.width/2, 100, self.rocketImage.frame.size.width, self.rocketImage.frame.size.height);
        self.missionCompleteTextview.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width/2-240, [[UIScreen mainScreen] bounds].size.height/2-250, 480, 200);
        self.missionCompleteTextview.font=[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:20.0];
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)submitNowButtonAction:(UIButton *)sender {
    //when user click on submit now
    //check if internet is connected or not
    if ([self connected]) {
        //land user to upload mission screen if he click on submit now button
        [UserDefaultManager setScreenSubmission:@"2"];
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UploadMissionViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"UploadMissionViewController"];
        [self.navigationController pushViewController:pushView animated:YES];
    }
    else {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"Your internet connection appears to be offline. Please try again later." closeButtonTitle:@"Done" duration:0.0f];
    }
}

//check if internet is connected
- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (IBAction)submitLaterButtonAction:(UIButton *)sender {
    //when user click on submit later change status of mission to pending
    [myDelegate showIndicator];
    [self performSelector:@selector(submitMissionLater) withObject:nil afterDelay:.1];
}
#pragma mark - end

#pragma mark - Webservice
//submit mission later webservice called
- (void)submitMissionLater {
    UploadMissionModel *submitLater = [UploadMissionModel new];
    [submitLater submitMissionLater:^(id response) {
        // change mission status to pending when user submit later
        NSMutableArray *dataArray=[NSMutableArray new];
        dataArray = [MissionListDatabase getMisionsListFromMisionId];
        MissionDataModel*data=[dataArray objectAtIndex:0];
        data.missionStatus=@"pending";
        //set updated mission staus in database
        [MissionListDatabase updateDataInMissionTableAfterMissionStarted:data];
        
        //land user to mission listing after submit later
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainSideBarViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"MainSideBarViewController"];
        [myDelegate.window setRootViewController:homeView];
        [myDelegate.window makeKeyAndVisible];
        
    } onfailure:^(NSError *error) {
        //in case of faliure fetch data from database
    }];
}
#pragma mark - end

@end
