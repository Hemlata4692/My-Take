//
//  GlobalBackViewController.m
//  FinderApp
//
//  Created by Hema on 30/12/15.
//  Copyright © 2015 Ranosys. All rights reserved.
//

#import "GlobalNavigationViewController.h"
#import "MissionDetailModel.h"
#import "TextDisplayViewController.h"
#import "DashboardViewController.h"
#import "MissionDetailDatabase.h"
#import "MissionDataModel.h"
#import "MissionListDatabase.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "LongTextViewController.h"
#import "RatingViewController.h"
#import "SingleChoiceViewController.h"
#import "MultiChoiceViewController.h"
#import "NetPromotRatingViewController.h"
#import "EmojiViewController.h"
#import "AudioUploadViewController.h"
#import "ImageUploadViewController.h"
#import "ChekInViewController.h"
#import "VideoUploadViewController.h"
#import "MissionCompleteViewController.h"
#import "UploadMissionViewController.h"
#import "MissionSubmittedViewController.h"
#import "QuestionModel.h"

@interface GlobalNavigationViewController ()

@end

@implementation GlobalNavigationViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Global navigation method
//add screen naigation to move on particular screen according to question type and last answered question
+ (void)setScreenNavigation:(NSMutableArray *)tempDataArray step:(int)step {
   //when last question is answered
    if (step>=tempDataArray.count) {
        [self setNavigationIfAllQuestionAnswered];
    }
    else {
    QuestionModel * questionData=[tempDataArray objectAtIndex:step];
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //single type question
    if ([[questionData.questionType lowercaseString] isEqualToString:@"single"]) {
        SingleChoiceViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"SingleChoiceViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //multi type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"multi"]) {
        MultiChoiceViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"MultiChoiceViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //simple text display question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"textdisplay"]) {
        TextDisplayViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"TextDisplayViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //rating type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"rate"]) {
        RatingViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"RatingViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //NPS rating type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"netpromote"]) {
        NetPromotRatingViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"NetPromotRatingViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //Emoji type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"emoji"]) {
        EmojiViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"EmojiViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //chekin type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"checkin"]) {
        ChekInViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"ChekInViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //long text type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"longtext"]) {
        LongTextViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"LongTextViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //record type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"record"]) {
        AudioUploadViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"AudioUploadViewController"];
        pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //image type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"image"]) {
        ImageUploadViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"ImageUploadViewController"];
         pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
        //video type question
    else if ([[questionData.questionType lowercaseString] isEqualToString:@"video"]) {
        VideoUploadViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"VideoUploadViewController"];
         pushView.questionDetailArray=[tempDataArray mutableCopy];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
    }
}

+ (void) setNavigationIfAllQuestionAnswered {
    if ([[[UserDefaultManager getValue:@"screenSubmissionDict"] objectForKey:[NSString stringWithFormat:@"answeredMission_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] isEqualToString:@"0"] || [[[UserDefaultManager getValue:@"screenSubmissionDict"] objectForKey:[NSString stringWithFormat:@"answeredMission_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] isEqualToString:@"1"]) {
        [UserDefaultManager setScreenSubmission:@"1"];
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MissionCompleteViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"MissionCompleteViewController"];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
    else if ([[[UserDefaultManager getValue:@"screenSubmissionDict"] objectForKey:[NSString stringWithFormat:@"answeredMission_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] isEqualToString:@"2"]){
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UploadMissionViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"UploadMissionViewController"];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
    else {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MissionSubmittedViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"MissionSubmittedViewController"];
        [myDelegate.currentNavigationController pushViewController:pushView animated:YES];
    }
}
#pragma mark - end

@end
