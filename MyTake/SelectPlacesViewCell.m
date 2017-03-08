//
//  SelectPlacesViewCell.m
//  MyTake
//
//  Created by Hema on 23/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SelectPlacesViewCell.h"

@implementation SelectPlacesViewCell

#pragma mark - Load nib
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#pragma mark - end

#pragma mark - Display cell data
//display data from near by places api
- (void)displayCellData:(NSDictionary*)placesDict rectSize:(CGSize)rectSize {
    CGSize size;
    CGRect textRect;
    self.placeName.translatesAutoresizingMaskIntoConstraints=YES;
    self.placeAddress.translatesAutoresizingMaskIntoConstraints=YES;
    self.placeName.frame =CGRectMake(38, 15, rectSize.width-50, self.placeName.frame.size.height);
    self.placeAddress.frame =CGRectMake(38, self.placeName.frame.origin.y+self.placeName.frame.size.height+4, rectSize.width-50, self.placeAddress.frame.size.height);
    //set dynamic height according to text
    size = CGSizeMake(rectSize.width-50,45);
    textRect = [self setDynamicHeight:size textString:placesDict[@"name"] fontSize:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:17.0]];
    self.placeName.numberOfLines = 0;
    self.placeName.frame = textRect;
    self.placeName.frame =CGRectMake(38, 15, rectSize.width-50, textRect.size.height+2);
    self.placeName.text=placesDict[@"name"];
    
    size = CGSizeMake(rectSize.width-50,45);
    textRect = [self setDynamicHeight:size textString:placesDict[@"vicinity"] fontSize:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:15.0]];
    self.placeAddress.numberOfLines = 0;
    self.placeAddress.frame = textRect;
    self.placeAddress.frame =CGRectMake(38, self.placeName.frame.origin.y+self.placeName.frame.size.height+4, rectSize.width-50, textRect.size.height+2);
    self.placeAddress.text=placesDict[@"vicinity"];
}

//display data from autocomplete api
- (void)displaySearchAutocompleteData:(NSDictionary*)autocompleteDict rectSize:(CGSize)rectSize {
    CGSize size;
    CGRect textRect;
    self.placeName.translatesAutoresizingMaskIntoConstraints=YES;
    self.placeAddress.translatesAutoresizingMaskIntoConstraints=YES;
    self.placeName.frame =CGRectMake(38, 15, rectSize.width-50, self.placeName.frame.size.height);
    self.placeAddress.frame =CGRectMake(38, self.placeName.frame.origin.y+self.placeName.frame.size.height+4, rectSize.width-50, self.placeAddress.frame.size.height);
    NSString *descriptionString =autocompleteDict[@"description"];
    NSArray *searchArray = [descriptionString componentsSeparatedByString:@","];
    
    //set dynamic height according to text
    size = CGSizeMake(rectSize.width-50,45);
    textRect = [self setDynamicHeight:size textString:[searchArray objectAtIndex:0] fontSize:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:17.0]];
    self.placeName.numberOfLines = 0;
    self.placeName.frame = textRect;
    self.placeName.frame =CGRectMake(38, 15, rectSize.width-50, textRect.size.height+2);
    self.placeName.text=[searchArray objectAtIndex:0];
    NSMutableString* resultString = [[NSMutableString alloc] init];
    NSString *addressString;
    //append address string if address count is grater then 1
    if ([searchArray count]>1) {
        for (int i=1; i <[searchArray count]; i++)  {
            [resultString appendString:[searchArray objectAtIndex:i]];
            [resultString appendString:@","];
            addressString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@","];
            addressString = [addressString stringByTrimmingCharactersInSet:charsToTrim];
        }
    }
    else {
        addressString =[searchArray objectAtIndex:0];
    }
    
    size = CGSizeMake(rectSize.width-50,45);
    textRect = [self setDynamicHeight:size textString:addressString fontSize:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:15.0]];
    self.placeAddress.numberOfLines = 0;
    self.placeAddress.frame = textRect;
    self.placeAddress.frame =CGRectMake(38, self.placeName.frame.origin.y+self.placeName.frame.size.height+4, rectSize.width-50, textRect.size.height+2);
    self.placeAddress.text=addressString;
}
#pragma mark - end

#pragma mark - Get dynamic height
//get dynamic height
- (CGRect)setDynamicHeight:(CGSize)rectSize textString:(NSString *)textString fontSize:(UIFont *)fontSize{
    CGRect textHeight = [textString
                         boundingRectWithSize:rectSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:fontSize}
                         context:nil];
    return textHeight;
}
#pragma mark - end
@end
