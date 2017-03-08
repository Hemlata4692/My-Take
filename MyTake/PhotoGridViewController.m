//
//  PhotoGridViewController.m
//  MyTake
//
//  Created by Hema on 24/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "PhotoGridViewController.h"
#import "ImageUploadViewController.h"
#import "UIView+Toast.h"

#define kCellsPerRow 3
@interface PhotoGridViewController () {
    NSMutableArray *selectedImagesArray, *selectedImagesPathArray;
    NSMutableDictionary *selectedImagePathDict;
    float fileSize;
}
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectionLabel;
@property(nonatomic,retain) NSString *imageFilePath;
@end

@implementation PhotoGridViewController
@synthesize assetsImagesArray;
@synthesize assetsGroup;
@synthesize imageUploadObj;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    fileSize=0;
    self.selectionLabel.hidden=YES;
    self.imageFilePath=@"";
    [self viewCustomization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //set title of screen according the album group name
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assetsImagesArray) {
        assetsImagesArray = [[NSMutableArray alloc] init];
    } else {
        [self.assetsImagesArray removeAllObjects];
    }
    //fetch images from asset groups
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.assetsImagesArray addObject:result];
        }
    };
    //filter only photos
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];//change filter for videos
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
    //get selected images and filesize from image upload screen
    selectedImagesPathArray=[imageUploadObj.getPathOfSelectedImagesArray mutableCopy];
    fileSize=fileSize+imageUploadObj.imageFileSize;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.photoCollectionView reloadData];
}
#pragma mark - end

#pragma mark - Custom accessors
- (void) viewCustomization {
    //selected images array
    selectedImagesArray=[[NSMutableArray alloc]init];
    //selected images path array
    selectedImagesPathArray=[[NSMutableArray alloc] init];
    selectedImagePathDict=[[NSMutableDictionary alloc]init];
    
    //set 3 cells per row in collection view
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.photoCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow-1);
    CGFloat cellWidth = (availableWidthForCells / kCellsPerRow);
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    // allows multiple selection in collection view
    [self.photoCollectionView setAllowsMultipleSelection:YES];
}
#pragma mark - end

#pragma mark - UICollectionView datasource and delegate methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //return image assests array count
    return assetsImagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"imageCell";
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //add border to cell
    cell.contentView.layer.borderColor =[UIColor colorWithRed:142.0/255.0 green:143.0/255.0 blue:145.0/255.0 alpha:1.0].CGColor;
    cell.contentView.layer.borderWidth = 0.5f;
    // load the asset for this cell
    UIImageView *savedImage = (UIImageView*)[cell viewWithTag:1];
    UIImageView *tickImage = (UIImageView*)[cell viewWithTag:2];
    if (cell.selected==YES) {
        tickImage.hidden=NO;
    }
    else {
        tickImage.hidden=YES;
    }
    ALAsset *asset = (ALAsset *)assetsImagesArray[indexPath.row];
    savedImage.image=[UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //allow at most 12 images to select and check file size should not excceed maximum sizes
    if (selectedImagesPathArray.count<12 && ((fileSize/1024.0)/1024.0)<(float)imageUploadObj.maximumSize) {
        // determine the selected items by using the indexPath
        UIImage *selectedImage = [assetsImagesArray objectAtIndex:indexPath.row];
        //get image asset url
        ALAsset *asset = (ALAsset *)assetsImagesArray[indexPath.row];
        if ([self imageForAsset:asset isSelected:@"1" index:(int)indexPath.row]){
            UICollectionViewCell *selectedCell =[collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *tickImage = (UIImageView*)[selectedCell viewWithTag:2];
            tickImage.hidden=NO;
            // add the selected item into the array
            [selectedImagesArray addObject:selectedImage];
            //set images count on label
            if (selectedImagesArray.count==1){
                self.selectionLabel.hidden=NO;
                self.selectionLabel.text=[NSString stringWithFormat:@"%d photo selected",(int)selectedImagesArray.count];
            }
            else {
                self.selectionLabel.hidden=NO;
                self.selectionLabel.text=[NSString stringWithFormat:@"%d photos selected",(int)selectedImagesArray.count];
            }
        }
    }
    else {
        //show alert if file size exceeds from maximum size
        [self.view makeToast:[NSString stringWithFormat:@"You can select up to 12 images and image size can not exceed %d MB.",imageUploadObj.maximumSize]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *selectedImage = [assetsImagesArray objectAtIndex:indexPath.row];
    //get image asset url
    ALAsset *asset = (ALAsset *)assetsImagesArray[indexPath.row];
    if ([selectedImagesArray containsObject:asset]) {
        if ([self imageForAsset:asset isSelected:@"0" index:(int)indexPath.row]) {
            UICollectionViewCell *selectedCell =[collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *tickImage = (UIImageView*)[selectedCell viewWithTag:2];
            tickImage.hidden=YES;
            // remove selected item from the array
            [selectedImagesArray removeObject:selectedImage];
            //set images count on label
            if (selectedImagesArray.count==0){
                self.selectionLabel.hidden=YES;
            }
            else if (selectedImagesArray.count==1){
                self.selectionLabel.hidden=NO;
                self.selectionLabel.text=[NSString stringWithFormat:@"%d photo selected",(int)selectedImagesArray.count];
            }
            else {
                self.selectionLabel.hidden=NO;
                self.selectionLabel.text=[NSString stringWithFormat:@"%d photos selected",(int)selectedImagesArray.count];
            }
            if (selectedImagesArray.count==0) {
                self.photoCollectionView.allowsSelection=YES;
            }
        }
    }
}
#pragma mark - end

#pragma mark - Check file size
//calculate image size and comapare to maximum size
- (BOOL)imageForAsset:(ALAsset*)aAsset isSelected:(NSString *)isSelected index:(int)index{
    ALAssetRepresentation *rep;
    rep = [aAsset defaultRepresentation];
    UIImage *fullResolutionImage= [UIImage imageWithCGImage:[rep fullScreenImage]];
    //resize image in aspect ratio if image width is greater then 800.0
    if (fullResolutionImage.size.width>800.0) {
        fullResolutionImage=[self imageWithImage:fullResolutionImage scaledToWidth:800.0];
    }
    NSData *imgData = UIImageJPEGRepresentation(fullResolutionImage, 1);//1 it represents the quality of the image.
    if ([isSelected isEqualToString:@"1"]) {
        fileSize=fileSize+[imgData length];
        //calculate image size and comapare to maximum size
        if (((fileSize/1024.0)/1024.0)>(float)imageUploadObj.maximumSize) {
            [self.view makeToast:[NSString stringWithFormat:@"You can select up to 12 images and image size can not exceed %d MB.",imageUploadObj.maximumSize]];
            fileSize=fileSize-[imgData length];
            return NO;
        }
        else {
            //set image path with time stamp, array count and stepid to unique name
            NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
            NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
            //set image path
            self.imageFilePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MyTakeImage%@_%lu_%d_%d.jpg",datestr,(unsigned long)selectedImagesArray.count,[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:0] intValue],[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[NSString stringWithFormat:@"%@,%@",[UserDefaultManager getValue:@"missionId"],[UserDefaultManager getValue:@"userId"]]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]]];
            //save images in cache directory
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager createFileAtPath:self.imageFilePath contents:imgData attributes:nil]) {
                [selectedImagesPathArray addObject:self.imageFilePath];
                for (int i=0; i<selectedImagesPathArray.count; i++) {
                    [selectedImagePathDict setObject:[selectedImagesPathArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",index]];
                }
            }
            return YES;
        }
    }
    else {
        //remove image from cache directory and from array if image is deselected also reduce the file size
        if ([[selectedImagePathDict allKeys] containsObject:[NSString stringWithFormat:@"%d",index]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[selectedImagePathDict objectForKey:[NSString stringWithFormat:@"%d",index]] error:nil];
            [selectedImagesPathArray removeObject:[selectedImagePathDict objectForKey:[NSString stringWithFormat:@"%d",index]]];
            fileSize=fileSize-[imgData length];
        }
        return YES;
    }
}

//resize image in aspect ratio if image width is greater then 800.0
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonAction:(id)sender {
    //take list of selected images and their file size to image upload screen
    imageUploadObj.getPathOfSelectedImagesArray=[selectedImagesPathArray mutableCopy];
    imageUploadObj.imageFileSize=fileSize;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ImageUploadViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}
#pragma mark - end
@end
