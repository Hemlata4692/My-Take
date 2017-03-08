//
//  SelectPlacesViewCell.h
//  MyTake
//
//  Created by Hema on 23/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectPlacesViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UILabel *placeAddress;

- (void)displayCellData:(NSDictionary*)placesDict rectSize:(CGSize)rectSize;
- (void)displaySearchAutocompleteData:(NSDictionary*)placesDict rectSize:(CGSize)rectSize;
@end
