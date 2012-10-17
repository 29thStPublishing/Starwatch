//
//  AppDelegate.h
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {

}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainVC *viewController;
@property (nonatomic, retain) UINavigationController *navController;

@end
