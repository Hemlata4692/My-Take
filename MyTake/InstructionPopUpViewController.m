//
//  InstructionPopUpViewController.m
//  MyTake
//
//  Created by Hema on 08/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "InstructionPopUpViewController.h"
#import "UIView+RoundedCorner.h"

@interface InstructionPopUpViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextView *popUpTextView;
@end

@implementation InstructionPopUpViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.mainContainerView setCornerRadius:2.0f];
    self.popUpTextView.text=[UserDefaultManager getValue:@"InstructionPopUp"];
    //add gesture on view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePopUpView:)];
    tapGesture.delegate=self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [myDelegate stopIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Hide pop-up view
- (void) hidePopUpView:(UITapGestureRecognizer *)sender {
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark - end

@end
