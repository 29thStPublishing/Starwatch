//
//  SWCViewController.m
//  StarWatch
//
//  Created by Natalie Podrazik on 1/13/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import "SWCViewController.h"

#import "SWCUtility.h"


@implementation SWCViewController

- (id)init:(NSString*)new_name
               new_global_id:(NSString*)new_global_id
    new_respond_to_callbacks:(BOOL) new_respond_to_callbacks {
    
    self = [super init];
    
    if (self) {
        [self initializeSWVC:new_name 
               new_global_id:new_global_id
    new_respond_to_callbacks:new_respond_to_callbacks];
    }
    
    return self;
}

-(void)initializeSWVC:(NSString*)new_name 
        new_global_id:(NSString*)new_global_id
new_respond_to_callbacks:(BOOL)new_respond_to_callbacks {

    
    [self setName:new_name];
    [self setGlobalId:new_global_id];
    [self setRespondToCallbacks:new_respond_to_callbacks];

    // This handles the case when the app enters the foreground
    // after going into the background for some time. We want
    // to track the view that's being opened, and its 
    // device orientation.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(viewDidAppear:)
                                             name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(NSString*)getName {
    return name;
}
-(void)setName:(NSString*)new_name {
    name = [NSString stringWithFormat:@"%@", new_name];
}

-(void)setGlobalId:(NSString*)new_global_id {
    global_id = [NSString stringWithFormat:@"%@", new_global_id];
}

-(void)setRespondToCallbacks:(BOOL)new_respond_to_callbacks {
    respond_to_callbacks = new_respond_to_callbacks;
}

- (void)didReceiveMemoryWarning {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name
                                                   global_id:global_id
                                                      action:SW_ACTION_MEMORY_WARNING
                                                    metadata:@""]];
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle


-(void)logViewAppearAction {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name 
                                                   global_id:global_id
                                                      action:SW_ACTION_VIEW_BEGIN
                                                    metadata:[SWCViewController getOrientation]]];

}

-(void)logViewDisappearAction {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name
                                                   global_id:global_id
                                                      action:SW_ACTION_VIEW_COMPLETE
                                                    metadata:[SWCViewController getOrientation]]];
}

-(void)viewDidAppear:(BOOL)animated {    
    if (respond_to_callbacks) {
        [self logViewAppearAction];
    }
}


-(void)viewDidDisappear:(BOOL)animated {    
    if (respond_to_callbacks) {
        [self logViewDisappearAction];
    }
    
}

- (void)tapGesture:(UIGestureRecognizer*)gesture {
    
    CGPoint location = [gesture locationInView:nil];
    
    // we should really recalibrate its location, since it's not
    // orientation-specific :(
    
    [self didTouch:location];   
}

-(void)logScrolledToBottom {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name 
                                                   global_id:global_id
                                                      action:SW_ACTION_SCROLLED_TO_BOTTOM
                                                    metadata:@""]];
}

-(void)logScrolledToTop {
    [SWCUtility logAction:name
                   action:SW_ACTION_SCROLLED_TO_TOP
                global_id:global_id
                 metadata:@""];
}

-(void)didTouch:(CGPoint)location {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name 
                                                   global_id:global_id
                                                      action:SW_ACTION_TAP
                                                    metadata:[NSString stringWithFormat:@"(%2.f, %2.f)", location.x, location.y]]];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {    
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name 
                                                   global_id:global_id
                                                      action:SW_ACTION_ROTATE
                                                    metadata:[SWCViewController getOrientation]]];
}


// Collect this for all devices, even when they don't support all orientations.
+(NSString*)getOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        return @"Portrait - Upside Down";
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft) {
        
        return @"Landscape - Left";
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        
        return @"Landscape - Right";
    }
    
    return @"Portrait - Standard";
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}



@end
