//
//  SelectPlaceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SelectPlaceViewController.h"
#import "SelectPlacesViewCell.h"
#import "AFNetworkReachabilityManager.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

static NSString *googleAPIKey=@"AIzaSyBpHFyF5OC60Zsdj6sSGWMklx0RdL3M2tw";

@import GoogleMaps;

@interface SelectPlaceViewController () {
    NSArray *nearByPlacesArray;
    NSArray *searchResultArray;
    NSArray *locationArray;
    BOOL isSearch;
    BOOL isAlertShown;
}
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextField *enterLocationTextField;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@end

@implementation SelectPlaceViewController
@synthesize latitude;
@synthesize longitude;
@synthesize checkinObj;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Select Place";
    nearByPlacesArray=[[NSArray alloc]init];
    locationArray=[[NSArray alloc]init];
    searchResultArray=[[NSArray alloc]init];
    isAlertShown=false;
    //add shadow to main view
    [self viewCustomization];
    if ([self connected]) {
        //fetch near by places using goole near by api
        [myDelegate showIndicator];
        [self performSelector:@selector(googleNearByAPI:) withObject:@"" afterDelay:.1];
    }
    else {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"Your internet connection appears to be offline. Please try again later." closeButtonTitle:@"Done" duration:0.0f];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
}
//check if internet is connected
- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - end

#pragma mark - Google nearby API
- (void) googleNearByAPI: (NSString *) googleType {
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&key=%@&sensor=true", [latitude floatValue],[longitude floatValue],[NSString stringWithFormat:@"%i",500],googleType,googleAPIKey];
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(parseNearByData:) withObject:data waitUntilDone:YES];
    });
}

//fetch data from nearby api
- (void)parseNearByData:(NSData *)responseData {
    //parse out the json data
    [myDelegate stopIndicator];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData options:kNilOptions
                          error:&error];
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    nearByPlacesArray = [json objectForKey:@"results"];
    [self.locationTableView reloadData];
}
#pragma mark - end

#pragma mark - Google autocomplete API
- (void) fetchAutocompleteResult: (NSString *) searchKey {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&radius=%@&key=%@", [NSString stringWithFormat:@"%@",searchKey], [NSString stringWithFormat:@"%i",500],googleAPIKey];
    NSString* urlTextEscaped = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:urlTextEscaped];
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(parseAutocompleteData:) withObject:data waitUntilDone:YES];
    });
}

//fetch data from autocomplete api
- (void)parseAutocompleteData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData options:kNilOptions
                          error:&error];
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    searchResultArray = [json objectForKey:@"predictions"];
    [self.locationTableView reloadData];
    
}
#pragma mark - end

#pragma mark - Google address API to fetch latitude longitude
- (void)fetchLatitudeLongitudeFromAddress:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData options:kNilOptions
                          error:&error];
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    locationArray = [json objectForKey:@"results"];
    if (locationArray.count==0) {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"Please enter valid location." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        [self parseLatLongFromArray:[locationArray objectAtIndex:0]];
    }
}

//parse latitude and longitude from address
- (void)parseLatLongFromArray:(NSDictionary *)locationDict {
    NSDictionary *tempDict=locationDict[@"geometry"];
    NSDictionary * latLongDict =tempDict[@"location"];
    checkinObj.checkInLatitude=latLongDict[@"lat"];
    checkinObj.checkInLongitude=latLongDict[@"lng"];
    checkinObj.otherLocation=@"1";
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[ChekInViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            
            break;
        }
    }
    
}
#pragma mark - end

#pragma mark - Textfield delegate method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //fetch result from entred location
    NSString *searchKey;
    if([string isEqualToString:@"\n"]) {
        searchKey = textField.text;
    }
    else if(string.length) {
        isSearch = YES;
        searchKey = [textField.text stringByAppendingString:string];
        if ([self connected]) {
            //fetch places using google autocomplete api
            [self fetchAutocompleteResult:searchKey];
        }
        else {
            if (!isAlertShown) {
                isAlertShown=true;
                [self.enterLocationTextField resignFirstResponder];
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"Done" actionBlock:^(void) {
                    isAlertShown=false;
                }];
                [alert showWarning:nil title:@"Alert" subTitle:@"Your internet connection appears to be offline. Please try again later." closeButtonTitle:nil duration:0.0f];
            }
            
        }
    }
    else if((textField.text.length-1)!=0) {
        searchKey = [textField.text substringWithRange:NSMakeRange(0, textField.text.length-1)];
        if ([self connected]) {
            //fetch places using google autocomplete api
            [self fetchAutocompleteResult:searchKey];
        }
        else {
            if (!isAlertShown) {
                isAlertShown=true;
                [self.enterLocationTextField resignFirstResponder];
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"Done" actionBlock:^(void) {
                    isAlertShown=false;
                }];
                [alert showWarning:nil title:@"Alert" subTitle:@"Your internet connection appears to be offline. Please try again later." closeButtonTitle:nil duration:0.0f];
            }
        }
    }
    else {
        searchKey = @"";
        isSearch = NO;
        [self.locationTableView reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (searchResultArray.count==0 && (![self.enterLocationTextField.text isEqualToString:@""])) {
        if ([self connected]) {
            NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", [NSString stringWithFormat:@"%@",self.enterLocationTextField.text]];
            NSString* urlTextEscaped = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //Formulate the string as URL object.
            NSURL *googleRequestURL=[NSURL URLWithString:urlTextEscaped];
            
            // Retrieve the results of the URL.
            dispatch_async(kBgQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
                [self performSelectorOnMainThread:@selector(fetchLatitudeLongitudeFromAddress:) withObject:data waitUntilDone:YES];
            });
            checkinObj.customLocation=@"1";
        }
        else {
            SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:self title:@"Alert" subTitle:@"Your internet connection appears to be offline. Please try again later." closeButtonTitle:@"Done" duration:0.0f];
        }
    }
    return YES;
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)backButtonAction:(id)sender {
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

#pragma mark - Table view delegate and datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearch) {
        //data fetched from autocomplete search
        return searchResultArray.count;
    }
    else {
        return nearByPlacesArray.count;//arary count
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"placesCell"];
    SelectPlacesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (isSearch) {
        //display data fetched from autocomplete search
        [cell displaySearchAutocompleteData:[searchResultArray objectAtIndex:indexPath.row] rectSize:self.locationTableView.frame.size];
    }
    else {
        //display data fetched from nearby api
        [cell displayCellData:[nearByPlacesArray objectAtIndex:indexPath.row] rectSize:self.locationTableView.frame.size];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSearch) {
        if ([self connected]) {
            //fetch lat,long from selected address
            NSDictionary *autocompleteDict=[searchResultArray objectAtIndex:indexPath.row];
            NSString *descriptionString =autocompleteDict[@"description"];
            NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [NSString stringWithFormat:@"%@",descriptionString]];
            NSString* urlTextEscaped = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //Formulate the string as URL object.
            NSURL *googleRequestURL=[NSURL URLWithString:urlTextEscaped];
            
            // Retrieve the results of the URL.
            dispatch_async(kBgQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
                [self performSelectorOnMainThread:@selector(fetchLatitudeLongitudeFromAddress:) withObject:data waitUntilDone:YES];
            });
            checkinObj.placeName=autocompleteDict[@"description"];
        }
        else {
            SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:self title:@"Alert" subTitle:@"Your internet connection appears to be offline. Please try again later." closeButtonTitle:@"Done" duration:0.0f];
        }
    }
    else {
        //get lat long from nearby selected address
        NSDictionary *placesDict=[nearByPlacesArray objectAtIndex:indexPath.row];
        NSDictionary *tempDict=placesDict[@"geometry"];
        NSDictionary * locationDict =tempDict[@"location"];
        checkinObj.checkInLatitude=locationDict[@"lat"];
        checkinObj.checkInLongitude=locationDict[@"lng"];
        checkinObj.otherLocation=@"1";
        checkinObj.placeName=placesDict[@"name"];
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[ChekInViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                
                break;
            }
        }
        
    }
}

//hide keyboard when user scroll table
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.enterLocationTextField resignFirstResponder];
}
#pragma mark - end
@end
