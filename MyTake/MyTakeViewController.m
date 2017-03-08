//
//  MyTakeViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MyTakeViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "MissionDetailModel.h"
#import "MissionDetailDatabase.h"
#import "MissionDataModel.h"
#import "MissionListDatabase.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "GlobalNavigationViewController.h"

@interface MyTakeViewController ()
{
    UIProgressView *setStepProgress;
    int viewCount;
}
@end

@implementation MyTakeViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UserDefaultManager getValue:@"screenSubmissionDict"] objectForKey:[NSString stringWithFormat:@"answeredMission_%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] isEqualToString:@"0"]) {
        //add right bar button item
        [self addRightBarButton];
        //add progress bar with text
        [self addProgresBar];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myDelegate.currentNavigationController=self.navigationController;
    //add left bar button item on all the subviews
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    if (mainVC.leftMenu)
    {
        // Adding left menu button to navigation bar
        [self addLeftMenuButton];
    }
}
#pragma mark - end

#pragma mark - Add progres bar
- (void) addProgresBar {
    setStepProgress=[[UIProgressView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-71, self.view.frame.size.width, 2)];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f,6.0f);
    setStepProgress.transform = transform;
    setStepProgress.trackTintColor = [UIColor colorWithRed:231.0/255.0 green:234.0/255.0 blue:239.0/255.0 alpha:1.0];
    //set progress count to incease progress according to questions
    CGFloat progressCountColor=(float)([[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1.0f)/(float)[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]; //No. of question
    [self changeSendProgProgress:progressCountColor];
    [self.view addSubview:setStepProgress];
    //add questions count label to show total questions and answered questions
    UILabel *progressLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-71-25, self.view.frame.size.width, 24)];
    progressLabel.font=[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:15.0];
    progressLabel.textAlignment=NSTextAlignmentCenter;
    progressLabel.backgroundColor=[UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:248.0/255.0 alpha:1.0];
    progressLabel.textColor=[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0];
   //set attributed text on label
    NSString * countString =[NSString stringWithFormat:@"%d",[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1];
    NSString * numberOfViewCount=[NSString stringWithFormat:@"%d",[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
    NSString *progressView = [NSString stringWithFormat:@"%@ of %@",countString,numberOfViewCount];
    NSRange boldedRange = [progressView rangeOfString:countString];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:progressView];
    [attrString beginEditing];
    [attrString setAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:161.0/255.0 green:214.0/255.0 blue:84.0/255.0 alpha:1.0],
                                        NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeueLTCom-Bd" size:20.0]} range:boldedRange];

    [attrString endEditing];
    progressLabel.attributedText=attrString;
    [self.view addSubview:progressLabel];
}

//change progress when view changed
- (void)changeSendProgProgress:(float)progress {
    [setStepProgress setProgressTintColor:[UIColor colorWithRed:161.0/255.0 green:214.0/255.0 blue:84.0/255.0 alpha:1.0]];
    [setStepProgress setProgress:progress];
}
#pragma mark - end

#pragma mark - Add rightbar button
//add next button on right navigation item on all the subviews
- (void)addRightBarButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:15.0]];
    [button setTitleColor:[UIColor colorWithRed:153.0/255.0 green:206.0/255.0 blue:82.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    UIBarButtonItem *barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    [button addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - end

#pragma mark - Set text view alignment
- (void)setTextViewAlignment:(UITextView *)textView {
    //set atextview alignment to vertical centre
    if ([textView sizeThatFits:textView.frame.size].height>60) {
        textView.contentOffset=CGPointMake(0, 4);
    }
    else {
        textView.contentOffset=CGPointMake(0, -(textView.frame.size.height/2-([textView sizeThatFits:textView.frame.size].height/2)));
    }

}
#pragma mark - end

#pragma mark - Bar button action
//next button action
- (IBAction)nextButtonAction:(UIButton *)sender {
    //When user click on next
}
#pragma mark - end

#pragma mark - Global navigation
//add screen naigation to move on particular screen according to question type
- (void)setScreenNavigation:(NSMutableArray *)tempDataArray step:(int)step {
    [GlobalNavigationViewController setScreenNavigation:tempDataArray step:step];
}
#pragma mark - end
@end
