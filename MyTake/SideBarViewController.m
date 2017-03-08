//
//  SideBarViewController.m
//  MyTake
//
//  Created by Hema on 27/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SideBarViewController.h"
#import "LoginModel.h"
#import "UIView+RoundedCorner.h"
#import "InstructionPopUpViewController.h"

@interface SideBarViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation SideBarViewController
@synthesize myTableView;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && ![UIApplication sharedApplication].isStatusBarHidden)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self setFixedStatusBar];
    }
    else{
        self.tableView.scrollEnabled=NO;
    }

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.myTableView reloadData];
}
//set status bar color in iphone
- (void)setFixedStatusBar
{
    self.myTableView = self.tableView;
    self.view = [[UIView alloc] initWithFrame:self.view.frame];
    self.tableView.scrollEnabled=NO;
    [self.view addSubview:self.myTableView];
    if([[UIScreen mainScreen] bounds].size.height>568){
        self.myTableView.scrollEnabled=NO;
    }
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), 20)];
      statusBarView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:43.0/255.0 blue:57.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
}
#pragma mark - end

#pragma mark - Table view data source
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 ) {
        //disable cell selection
        return;
    }
    else if (indexPath.row==2) {
        NSURL *url = [NSURL URLWithString:[UserDefaultManager getValue:@"communityLink"]];
        if (![[UIApplication sharedApplication] openURL:url]) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:self title:@"Alert" subTitle:[NSString stringWithFormat:@"%@%@",@"Failed to open url:",[url description]] closeButtonTitle:@"Done" duration:0.0f];
        }
    }
    else if (indexPath.row==3) {
        [myDelegate showIndicator];
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        InstructionPopUpViewController *popView =[storyboard instantiateViewControllerWithIdentifier:@"InstructionPopUpViewController"];
        popView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
        [popView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:popView animated:NO completion:nil];
    }
    else if (indexPath.row==4) {
        //logout user
        [UserDefaultManager setValue:nil key:@"userId"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        myDelegate.navigationController = [storyboard instantiateViewControllerWithIdentifier:@"mainNavController"];
        myDelegate.window.rootViewController = myDelegate.navigationController;
    }
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
     if (indexPath.row==0) {
         //set user image and name in side bar
         UIImageView *userImage=(UIImageView *)[cell viewWithTag:1];
         UILabel *userName=(UILabel *)[cell viewWithTag:2];
         [userImage setCornerRadius:userImage.frame.size.width/2];
         [userImage setViewBorder:userImage color:[UIColor whiteColor]];
         userName.text=[UserDefaultManager getValue:@"userName"];
         NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[UserDefaultManager getValue:@"userImage"]]
                                                       cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                   timeoutInterval:60];
         __weak UIImageView *weakRef = userImage;
         [userImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"user_thumbnail.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             weakRef.contentMode = UIViewContentModeScaleAspectFill;
             weakRef.clipsToBounds = YES;
             weakRef.image = image;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         }];
     }
     return cell;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
            {
        return 250;
    }
    else if (indexPath.row==3) {
        if ([[UserDefaultManager getValue:@"missionStarted"] isEqualToString:@"In Progress"]) {
            return 100;
        }
        else {
            return 0;
        }
    }
    else {
        return 100;
    }
}
#pragma mark - end


@end
