//
//  UIImage+deviceSpecificMedia.h
//  JobPortal
//
//  Created by Sumit on 24/12/14.
//  Copyright (c) 2014 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, thisDeviceClass) {
    
    thisDeviceClass_iPhone,
    thisDeviceClass_iPhoneRetina,
    thisDeviceClass_iPhone5,
    thisDeviceClass_iPhone6,
    thisDeviceClass_iPhone6plus,
    
    // we can add new devices when we become aware of them
    
    thisDeviceClass_iPad,
    thisDeviceClass_iPadRetina,
    
    
    thisDeviceClass_unknown
};

thisDeviceClass currentDeviceClass();
@interface UIImage (deviceSpecificMedia)
- (NSString * )imageForDeviceWithName:(NSString *)fileName;
- (NSString * )imageForDeviceWithNameForOtherImages:(NSString *)fileName;
@end
