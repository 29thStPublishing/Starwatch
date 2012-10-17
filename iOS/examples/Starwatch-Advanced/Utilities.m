//
//  Utilities.m
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(NSString*)getNibSuffix {
    if ([Utilities isIPhone]) {
        return @"iPhone";
    }
    return @"iPad";
}

+(BOOL)isIPhone {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}
+(BOOL)isIPad {
    return ![Utilities isIPhone];
}

+(BOOL)isLandscape {
    if ([Utilities isIPhone]) {
        return NO;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    // LANDSCAPE
    return ((orientation == UIDeviceOrientationLandscapeLeft) ||
            (orientation == UIDeviceOrientationLandscapeRight));
}




@end
