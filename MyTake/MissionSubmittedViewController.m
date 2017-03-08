//
//  MissionSubmittedViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionSubmittedViewController.h"
#import "MainSideBarViewController.h"
#import "MissionDetailDatabase.h"
#import "MissionDetailModel.h"

@interface MissionSubmittedViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextView *missionEndMessage;
@property (weak, nonatomic) IBOutlet UITextView *missionThankYouMessage;
@end

@implementation MissionSubmittedViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    
    [self.missionEndMessage flashScrollIndicators];
    NSMutableArray *dataArray=[NSMutableArray new];
    dataArray = [MissionDetailDatabase getMissionDetailData];
    MissionDetailModel *missionDetailData = [dataArray objectAtIndex:0];
    self.missionEndMessage.text=missionDetailData.endMessage;
    [self viewCustomization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.missionEndMessage flashScrollIndicators];
}
#pragma mark - end

#pragma mark - Custom accessors
//add corner radius and border to objects
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    //if device is ipad change framing of main container view
    if (([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        self.mainContainerView.translatesAutoresizingMaskIntoConstraints=YES;
        self.missionEndMessage.translatesAutoresizingMaskIntoConstraints=YES;
        self.mainContainerView.frame=CGRectMake(80, ([[UIScreen mainScreen] bounds].size.height-64)/2-self.mainContainerView.frame.size.height/2, [[UIScreen mainScreen] bounds].size.width-160, self.mainContainerView.frame.size.height);
         self.missionEndMessage.frame=CGRectMake(30, 129, self.mainContainerView.frame.size.width-60, 84);
        self.missionThankYouMessage.font=[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:16.0];
    }
    else {
        self.missionEndMessage.translatesAutoresizingMaskIntoConstraints=YES;
        self.missionEndMessage.frame=CGRectMake(20, 129, [[UIScreen mainScreen] bounds].size.width-60, 84);
    }
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.missionEndMessage];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)backToMissionsButtonAction:(UIButton *)sender {
    //land user to mission listing after mission is completed
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainSideBarViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"MainSideBarViewController"];
    [myDelegate.window setRootViewController:homeView];
    [myDelegate.window makeKeyAndVisible];
}
#pragma mark - end

@end
