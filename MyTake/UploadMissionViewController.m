//
//  UploadMissionViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "UploadMissionViewController.h"
#import "CustomProgressBar.h"
#import "UploadMissionModel.h"
#import "MissionDataModel.h"
#import "MissionListDatabase.h"
#import "MissionSubmittedViewController.h"
#import "AnswerDatabase.h"
#import "AnswerModel.h"
#import "UIViewController+AMSlideMenu.h"
#import "UIView+Toast.h"
#import "MainSideBarViewController.h"

@interface UploadMissionViewController () {
    CustomProgressBar *uploadProgressBarView;
    int currentStep,totalSteps, presentStep;
    NSMutableArray *answerDataArray;
}
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UILabel *questionCountUpdateLabel;
@end

@implementation UploadMissionViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    answerDataArray=[[NSMutableArray alloc]init];
    
    //fetch answer data from database
   answerDataArray=[AnswerDatabase getAnswerDetails];
    presentStep=0;
    currentStep=[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]-(int)answerDataArray.count;
    [self viewCustomization];
    //call upload mission webservice
    [self performSelector:@selector(uploadCompletedMission) withObject:nil afterDelay:.1];
}

- (void)viewWillAppear:(BOOL)animated{
    //disabling pan gesture for left menu
    [self disableSlidePanGestureForLeftMenu];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"dropdown"]];
}

- (void)addLeftBarButtonWithImage:(UIImage *)menuImage
{
    //Navigation bar buttons
    CGRect framing = CGRectMake(0, 0, 30, 30);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setImage:menuImage forState:UIControlStateNormal];
    [menu setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    UIBarButtonItem *barButton1 =[[UIBarButtonItem alloc] initWithCustomView:menu];
    [menu addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
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
    //if device is ipad change framing of main container view
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        self.mainContainerView.translatesAutoresizingMaskIntoConstraints=YES;
        self.mainContainerView.frame=CGRectMake(80, ([[UIScreen mainScreen] bounds].size.height-64)/2-self.mainContainerView.frame.size.height/2, [[UIScreen mainScreen] bounds].size.width-160, self.mainContainerView.frame.size.height);
        //add progress bar in ipad
        uploadProgressBarView = [[CustomProgressBar alloc] initWithFrame:CGRectMake(30, 215, [[UIScreen mainScreen] bounds].size.width-220, 25) backgroundColor:[UIColor whiteColor] innerViewColor:[UIColor colorWithRed:133.0/255.0 green:193.0/255.0 blue:46.0/255.0 alpha:1.0] progressValue:0.0 myView:self.mainContainerView padding:0.0];
    }
    else {
        //add progress bar iPhone
        uploadProgressBarView = [[CustomProgressBar alloc] initWithFrame:CGRectMake(30, 215, [[UIScreen mainScreen] bounds].size.width-80, 25) backgroundColor:[UIColor whiteColor] innerViewColor:[UIColor colorWithRed:133.0/255.0 green:193.0/255.0 blue:46.0/255.0 alpha:1.0] progressValue:0.0 myView:self.mainContainerView padding:0.0];
    }
    //change progress bar
     [uploadProgressBarView changeProgress:(float)currentStep/[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] floatValue]];
    //progress label
    self.questionCountUpdateLabel.text=[NSString stringWithFormat:@"Completed %d of %d",currentStep,[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
}
#pragma mark - end

#pragma mark - Webservice
- (void)uploadCompletedMission {
    //call upload completed mission webservice
    if (currentStep<[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]) {
        NSMutableDictionary *request=[[self setRequestDataForUploadMissionData] mutableCopy];
      //audio type question
        int mediaType=0;
        NSMutableArray *filePathData=[NSMutableArray new];
        if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"record"]) {
            //send filepath in webservice
            mediaType=2;
            [filePathData addObject:[[answerDataArray objectAtIndex:presentStep]audioPath]];
        }
        //image type question
        else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"image"]) {
            mediaType=1;
            //send filepath in webservice
            NSArray *tempArray=[[[answerDataArray objectAtIndex:presentStep]imageFolder] componentsSeparatedByString:@","];
            for (int i=0; i<tempArray.count; i++) {
                [filePathData addObject:[tempArray objectAtIndex:i]];
            }
        }
        //video type question
        else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"video"]) {
             mediaType=3;
            //send filepath in webservice
            [filePathData addObject:[[answerDataArray objectAtIndex:presentStep]videoPath]];
        }
        //call upload mission webservice after every answer is uploaded
        [self uploadCompletedMission:request filePath:filePathData mediaType:mediaType stepId:[[answerDataArray objectAtIndex:presentStep]stepId]];
    }
    else {
        //if question upload success mark mission as complete
        [self markMissionComplete];
    }
}

//upload mission question answers one by one
- (void)uploadCompletedMission:(NSMutableDictionary*)requestDict filePath:(NSMutableArray *)filePath mediaType:(int)mediaType stepId:(NSString *)stepId{
    UploadMissionModel *uploadMission = [UploadMissionModel new];
    //send request dictionary
    [uploadMission uploadMission:filePath mediaType:mediaType stepId:stepId requestDict:requestDict success:^(id responseObject) {
        //update question status in database once answer is uploaded
        [AnswerDatabase updateDataInAnswerTable:[answerDataArray objectAtIndex:presentStep]];
     
        currentStep++;
        presentStep++;
        [uploadProgressBarView changeProgress:(float)currentStep/[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] floatValue]];
       
        self.questionCountUpdateLabel.text=[NSString stringWithFormat:@"Completed %d of %d",currentStep,[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
       
        if (currentStep<[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]) {
            NSMutableDictionary *request=[[self setRequestDataForUploadMissionData] mutableCopy];
            int mediaType=0;
            NSMutableArray *filePathData=[NSMutableArray new];
            //audio type question
            if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"record"]) {
                mediaType=2;
                //send filepath in webservice
                [filePathData addObject:[[answerDataArray objectAtIndex:presentStep]audioPath]];
            }
            //image type question
            else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"image"]) {
                mediaType=1;
                NSArray *tempArray=[[[answerDataArray objectAtIndex:presentStep]imageFolder] componentsSeparatedByString:@","];
                for (int i=0; i<tempArray.count; i++) {
                    //send filepath in webservice
                    [filePathData addObject:[tempArray objectAtIndex:i]];
                }
            }
            //video type question
            else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"video"]) {
                mediaType=3;
                //send filepath in webservice
                [filePathData addObject:[[answerDataArray objectAtIndex:presentStep]videoPath]];
            }
            //call upload mission webservice after every answer is uploaded
            [self uploadCompletedMission:request filePath:filePathData mediaType:mediaType stepId:[[answerDataArray objectAtIndex:presentStep]stepId]];
        }
        else {
            //mark mission completed once all the answers of a mission are submitted
            [self markMissionComplete];
        }
    } onFailure:^(NSError *error) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Cancel" actionBlock:^(void) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MainSideBarViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"MainSideBarViewController"];
            [myDelegate.window setRootViewController:homeView];
            [myDelegate.window makeKeyAndVisible];
        }];
        [alert addButton:@"Retry" actionBlock:^(void) {
             [self performSelector:@selector(uploadCompletedMission) withObject:nil afterDelay:.1];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[NSString stringWithFormat:@"%@",error] closeButtonTitle:nil duration:0.0f];
    }] ;
}

//set request dictionary for each question
- (NSDictionary*)setRequestDataForUploadMissionData {
    
    NSDictionary *requestDict;
    //single type question
    if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"single"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[answerDataArray objectAtIndex:presentStep]singleAnswer],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:@""
                      };
    }
    //multi type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"multi"]) {
        
        NSMutableDictionary *tempDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"api_token":[UserDefaultManager getValue:@"apiKey"],
                                                                @"MissionID":[UserDefaultManager getValue:@"missionId"],
                                                                @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                                                                @"overwrite":@"yes"
                                                                }];
        NSString *stepString=@"";
        for (int i=0; i<[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] count]; i++) {
            if (i==0) {
                if ([[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] containsString:@",$#,"]) {
                    
                    stepString=[NSString stringWithFormat:@"%@",[[[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] componentsSeparatedByString:@",$#,"] objectAtIndex:0]];
                    [tempDict setObject:[NSString stringWithFormat:@"%@",[[[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] componentsSeparatedByString:@",$#,"] objectAtIndex:1]] forKey:[NSString stringWithFormat:@"other_%@_%@",[[answerDataArray objectAtIndex:presentStep]stepId],[[[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] componentsSeparatedByString:@",$#,"] objectAtIndex:0]]];
                }
                else {
                    stepString=[NSString stringWithFormat:@"%@",[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]]];
                }
            }
            else {
                if ([[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] containsString:@",$#,"]) {
                    
                    stepString=[NSString stringWithFormat:@"%@,%@",stepString,[[[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] componentsSeparatedByString:@",$#,"] objectAtIndex:0]];
                    [tempDict setObject:[NSString stringWithFormat:@"%@",[[[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] componentsSeparatedByString:@",$#,"] objectAtIndex:1]] forKey:[NSString stringWithFormat:@"other_%@_%@",[[answerDataArray objectAtIndex:presentStep]stepId],[[[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]] componentsSeparatedByString:@",$#,"] objectAtIndex:0]]];
                }
                else {
                    stepString=[NSString stringWithFormat:@"%@,%@",stepString,[[[answerDataArray objectAtIndex:presentStep]multiAnswerDict] objectForKey:[NSString stringWithFormat:@"%d",i]]];
                }
            }
        }
        [tempDict setObject:stepString forKey:[NSString stringWithFormat:@"value_%@[]",[[answerDataArray objectAtIndex:presentStep]stepId]]];
        
        requestDict=[tempDict copy];
    }
    //simple text display question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"textdisplay"]) {
        float low_bound = 1;
        float high_bound = 2;
        float rndValue = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[NSString stringWithFormat:@"%d", (int)(rndValue + 0.5)],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:@""
                      };
    }
    //rating type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"rate"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[answerDataArray objectAtIndex:presentStep]ratingResponse],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:@"",
                      [NSString stringWithFormat:@"why_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[answerDataArray objectAtIndex:presentStep]ratingWhyResponse]
                      };
    }
    //NPS rating type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"netpromote"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[answerDataArray objectAtIndex:presentStep]ratingResponse],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:@""
                      };
    }
    //Emoji type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"emoji"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[[answerDataArray objectAtIndex:presentStep]emojiResponse] componentsSeparatedByString:@","],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:@""
                      };
          }
    //chekin type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"checkin"]) {

        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[answerDataArray objectAtIndex:presentStep]placeName],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[NSString stringWithFormat:@"%@,%@",[[answerDataArray objectAtIndex:presentStep]latitude],[[answerDataArray objectAtIndex:presentStep]longitude]]
                      };
    }
    //long text type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"longtext"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes",
                      [NSString stringWithFormat:@"value_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:[[answerDataArray objectAtIndex:presentStep]longTextResponse],
                      [NSString stringWithFormat:@"location_%@",[[answerDataArray objectAtIndex:presentStep]stepId]]:@""
                      };
    }
    //record type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"record"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes"
                    };
    }
    //image type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"image"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes"
                      };
    }
    //video type question
    else if ([[[answerDataArray objectAtIndex:presentStep]stepType] isEqualToString:@"video"]) {
        requestDict=@{@"api_token":[UserDefaultManager getValue:@"apiKey"],
                      @"MissionID":[UserDefaultManager getValue:@"missionId"],
                      @"StepID":[[answerDataArray objectAtIndex:presentStep]stepId],
                      @"overwrite":@"yes"
                      };
    }
    return requestDict;
}

//mark mission complete
- (void)markMissionComplete {
    UploadMissionModel *markMissionComplete = [UploadMissionModel new];
    [markMissionComplete markMissionComplete:^(id response) {
        //enable gesture for menu button
        [self enableSlidePanGestureForLeftMenu];
        // change mission status to pending when user submit later
        NSMutableArray *dataArray=[NSMutableArray new];
        dataArray = [MissionListDatabase getMisionsListFromMisionId];
        MissionDataModel*data=[dataArray objectAtIndex:0];
        data.missionStatus=@"complete";
        //set updated mission staus in database
        [MissionListDatabase updateDataInMissionTableAfterMissionStarted:data];
        
        //land user to thank you screen
        [UserDefaultManager setScreenSubmission:@"3"];
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MissionSubmittedViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"MissionSubmittedViewController"];
        [self.navigationController pushViewController:pushView animated:YES];
        
    } onFailure:^(NSError *error) {
        //in case of faliure fetch data from database
    }];
}
#pragma mark - end

#pragma mark - IBAction
//menu button action
-(void)menuButtonAction :(id)sender {
    //disable menu button until all teh answers are being uploaded
    [self.view makeToast:@"Please wait while your mission is being uploaded."];
}
#pragma mark - end
@end
