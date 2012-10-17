//
//  AppDelegate.m
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"

// Required for Starwatch
#import "SWCUtility.h"


@implementation AppDelegate

@synthesize navController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainVC * vc = [[MainVC alloc] init];
    
    /*** Starwatch BASIC ***/
    // This will make sure our DB's are in the correct place,
    // we've begun tracking actions against this unique device id,
    // and increments the number of times this user has opened the app.
    [SWCUtility begin];
    
    
    
    // Log the action of booting up.
    [SWCUtility logAppStart];
    
    // Log the "INFO" action.
    // This method takes in a dictionary of your custom key-value pairs
    // and, along with general information about this device and user,
    // prepares to send it to the remote db.
    [SWCUtility logInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                             [NSString stringWithFormat:@"%d", [SWCUtility getNumOpens]],
                                                             nil]
                                                    forKeys:[NSArray arrayWithObjects:
                                                             @"num_opens",
                                                             nil]
                         ]
     ];
    



    
    
    navController = [[UINavigationController alloc] initWithRootViewController:vc];

    [navController setNavigationBarHidden:NO];
    
    self.navController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    [[self window] setRootViewController:vc];
    [self.window addSubview:navController.view];
    

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    /*** Starwatch ***/
    // Log the action of leaving.
    [SWCUtility logAppEnd];
    
    // Send the collected data.
    [SWCUtility send_data];

    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

