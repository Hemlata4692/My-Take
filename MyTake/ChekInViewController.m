//
//  ChekInViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "ChekInViewController.h"
#import <MapKit/MapKit.h>
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HelpViewController.h"
#import "SelectPlaceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AFNetworkReachabilityManager.h"

@import GoogleMaps;
@import GooglePlacePicker;

@interface ChekInViewController ()<MKMapViewDelegate,UICollectionViewDelegate,CLLocationManagerDelegate,GMSMapViewDelegate> {
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentLocation;
    BOOL isLocationUpdate, isAnswered;
    //Google map variables
    GMSCameraPosition *camera;
    GMSMarker *marker;
    BOOL isEnterFirstTime;//First time set google map pin;
    GMSPlacePicker *placePicker;
}
@property (weak, nonatomic) IBOutlet UILabel *seperatorLabel;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (strong, nonatomic) IBOutlet GMSMapView *checkInMapView;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@end

@implementation ChekInViewController
@synthesize questionDetailArray;
@synthesize checkInLatitude;
@synthesize checkInLongitude;
@synthesize otherLocation;
@synthesize placeName;
@synthesize customLocation;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationMapView.hidden=YES;
    isEnterFirstTime=true;
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    currentLocation.latitude=0.0f;
    currentLocation.longitude=0.0f;
    isLocationUpdate=false;
    isAnswered=false;
    [self.questionTextView flashScrollIndicators];
    //set text view frame
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(36, 29, [[UIScreen mainScreen] bounds].size.width-92, 60);
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self fetchUserCurrentLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //add border corner radius on objects
    [self viewCustomization];
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
    [self.checkInButton addShadowWithCornerRadius:self.checkInButton color:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0] borderColor:[UIColor clearColor] radius:20.0f];
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    if ([self.questionTextView sizeThatFits:self.questionTextView.frame.size].height>80) {
        self.viewMoreButton.hidden=NO;
    }
}

- (void)fetchUserCurrentLocation {
    //get user current location
    locationManager = [[CLLocationManager alloc] init];
    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    [locationManager requestAlwaysAuthorization];
    //Set some paramater for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    
    self.checkInMapView.myLocationEnabled = NO;
    marker = [[GMSMarker alloc] init];
    self.checkInMapView.delegate = self;
    self.viewMoreButton.hidden=YES;
    
    //add shadow in between map view and question view
    self.seperatorLabel.backgroundColor=[UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0];
    [self.seperatorLabel addShadow:self.seperatorLabel color:[UIColor grayColor]];
    
}
#pragma mark - end

#pragma mark - Set pin on google map
- (void)setGoogleMapData:(NSString *)placeAddress{
    if (isEnterFirstTime) {
        isEnterFirstTime=false;
        camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude
                                             longitude:currentLocation.longitude
                                                  zoom:14.0];
        
    }
    else {
        isAnswered=true;
        camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude
                                             longitude:currentLocation.longitude
                                                  zoom:self.checkInMapView.camera.zoom];
    }
    self.checkInMapView.camera = camera;
    marker.position = currentLocation;
    marker.tappable = true;
    marker.map= self.checkInMapView;
    marker.draggable = true;
}

//drag and drop pin delegate method
- (void) mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)googlemarker
{
    currentLocation = googlemarker.position;;
    isLocationUpdate=true;
    [self fetchPlaceNameUsingLatLong:currentLocation];
}

//long press delegate method
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    currentLocation = coordinate;
    isLocationUpdate=true;
    [self fetchPlaceNameUsingLatLong:currentLocation];
}

//fetch address from lat long
- (void)fetchPlaceNameUsingLatLong:(CLLocationCoordinate2D)cordinates {
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude]; //insert your coordinates
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  if (placemark) {
                      //String to hold address
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      //Print the location to console
                      placeName=locatedAt;
                      //set pin om map
                      [self setGoogleMapData:placeName];
                  }
                  else {
                      SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
                      [alert showWarning:self title:@"Alert" subTitle:@"There was an error locating the address. Please try again." closeButtonTitle:@"Done" duration:0.0f];
                  }
              }
     ];
}
#pragma mark - end

#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = (CLLocation *)[locations lastObject];
    // if location update is true set pin on map
    if (!isLocationUpdate) {
        currentLocation = newLocation.coordinate;
        isLocationUpdate=true;
        [self fetchPlaceNameUsingLatLong:currentLocation];
    }
    [locationManager stopUpdatingLocation];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    if ((isAnswered) && currentLocation.latitude!=0 && currentLocation.longitude!=0 && (![placeName isEqualToString:@""])) {
        //insert data in database
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.latitude=[NSString stringWithFormat:@"%f",currentLocation.latitude];
        answerData.longitude=[NSString stringWithFormat:@"%f",currentLocation.longitude];
        answerData.placeName=placeName;
        [AnswerDatabase insertDataInAnswerTable:answerData];
        
        //calculate length of answer
        NSData *data = [[NSString stringWithFormat:@"%@ %@ %@",answerData.latitude,answerData.longitude,answerData.placeName] dataUsingEncoding:NSASCIIStringEncoding];
        NSUInteger myLength = data.length;
        [UserDefaultManager setAnswerFileSize:(double)myLength];
        //move to next question
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
        
    } else {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"This mission step is required, you must enter a response to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
}

- (IBAction)helpButtonAction:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=@"Tell us your location. Click the green 'check-in' button to display nearby locations. If you do not see your location listed, you can search for a location by clicking the search button at the top right.";
    helpViewObj.isHelpScreen=YES;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}

- (IBAction)checkInButtonAction:(id)sender {
    //open place picker
    CLLocationCoordinate2D center;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    if (currentLocation.latitude!=0 && currentLocation.longitude!=0){
        center = CLLocationCoordinate2DMake(currentLocation.latitude, currentLocation.longitude);
        northEast = CLLocationCoordinate2DMake(center.latitude + 0.010, center.longitude + 0.010);
        southWest = CLLocationCoordinate2DMake(center.latitude - 0.010, center.longitude - 0.010);
    }
    else {
        center = CLLocationCoordinate2DMake(37.0902, -95.7129);
        northEast = CLLocationCoordinate2DMake(center.latitude + 10, center.longitude + 10);
        southWest = CLLocationCoordinate2DMake(center.latitude - 10, center.longitude - 10);
    }
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    [placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:self title:@"Alert" subTitle:[error localizedDescription] closeButtonTitle:@"Done" duration:0.0f];
            return;
        }
        if (place != nil) {
            if (NULL!=place.formattedAddress) {
                //set pin om map
                if ([place.formattedAddress containsString:@","]&&[[[place.formattedAddress componentsSeparatedByString:@","] objectAtIndex:0] isEqualToString:place.name]) {
                    placeName=[NSString stringWithFormat:@"%@",place.formattedAddress];
                }
                else {
                    placeName=[NSString stringWithFormat:@"%@,%@",place.name,place.formattedAddress];
                }
                currentLocation=place.coordinate;
                [self setGoogleMapData:placeName];
            }
            else {
                placeName=@"";
                currentLocation = place.coordinate;
                [self fetchPlaceNameUsingLatLong:currentLocation];
            }
        }
    }];
}

//viem more text buton action
- (IBAction)viewMoreButtonAction:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewObj =[storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewObj.helpText=self.questionTextView.text;
    helpViewObj.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [helpViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:helpViewObj animated: YES completion:nil];
}
#pragma mark - end
@end
