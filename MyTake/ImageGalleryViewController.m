//
//  ImageGalleryViewController.m
//  MyTake
//
//  Created by Hema on 24/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "ImageGalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoGridViewController.h"

@interface ImageGalleryViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (weak, nonatomic) IBOutlet UITableView *galleryListTableView;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation ImageGalleryViewController
@synthesize imageUploadObj;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Photos";
    
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:errorMessage closeButtonTitle:@"Done" duration:0.0f];
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0) {
            [self.groups addObject:group];
        }
        else {
            [self.galleryListTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    //enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos |ALAssetsGroupAll | ALAssetsGroupPhotoStream;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - UITableView datasource and delegate methods
// determine the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

// determine the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"listCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ALAssetsGroup *groupForCell = self.groups[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    
    UIImageView *thumbImage = (UIImageView *)[cell viewWithTag:1];
    UILabel *albumNameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *photosCountLabel = (UILabel *)[cell viewWithTag:3];
    //display tumbnail image
    thumbImage.image = posterImage;
    albumNameLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    photosCountLabel.text = [@(groupForCell.numberOfAssets) stringValue];
    return cell;
}
#pragma mark - end

#pragma mark - Segue support
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *selectedIndexPath = [self.galleryListTableView indexPathForSelectedRow];
        if (self.groups.count > (NSUInteger)selectedIndexPath.row) {
            // hand off the asset group (i.e. album) to the next view controller
            PhotoGridViewController *photoGrid = [segue destinationViewController];
            photoGrid.assetsGroup = self.groups[selectedIndexPath.row];
            photoGrid.imageUploadObj=imageUploadObj;
        }
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

@end
