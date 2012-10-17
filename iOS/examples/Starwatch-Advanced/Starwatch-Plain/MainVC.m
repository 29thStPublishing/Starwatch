//
//  MainVC.m
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "MainVC.h"
#import "Utilities.h"
#import "GalleryVC.h"
#import "TextVC.h"
#import "FeedbackVC.h"
#import "SWCUtility.h"


@interface MainVC ()

@end

@implementation MainVC

@synthesize galleryButton, textButton, feedbackButton;

-(id)init {
    self = [super initWithNibName:[NSString stringWithFormat:@"MainVC_%@", [Utilities getNibSuffix]]
                           bundle:nil];
    

    if (self) {
        [self initializeSWVC:@"MainVC"
               new_global_id:@""
    new_respond_to_callbacks:YES];
    }
    
    
    return self;
}

-(void)activateStarwatch {
    // SW -- By "activating" a SWCUIButton,
    // we give its name a string
    // and watch whenever it's tapped.
    // NOTE their custom class in the xibs -- they aren't uibuttons anymore.
    [galleryButton activate:@"MainVC-Gallery-Button"];
    [textButton activate:@"MainVC-Text-Button"];
    [feedbackButton activate:@"MainVC-Feedback-Button"];
}
- (void)viewDidLoad {
    [self activateStarwatch];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goToGallery:(id)sender {
    
    GalleryVC * vc = [[GalleryVC alloc] init];

    [[self navigationController] pushViewController:vc animated:YES];

    vc = nil;
    
}
-(IBAction)goToText:(id)sender {
    TextVC * vc = [[TextVC alloc] init];
    
    [[self navigationController] pushViewController:vc animated:YES];
    
    vc = nil;
}
-(IBAction)goToFeedback:(id)sender {
    FeedbackVC * vc = [[FeedbackVC alloc] init];
    
    [[self navigationController] pushViewController:vc animated:YES];
    
    vc = nil;}

-(void)viewDidUnload {
    
    [self setFeedbackButton:nil];
    [self setGalleryButton:nil];
    [self setTextButton:nil];
    
    [super viewDidUnload];
}

 
@end
