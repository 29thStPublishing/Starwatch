//
//  GalleryVC.m
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "GalleryVC.h"
#import "Utilities.h"
#import "SWCUtility.h"


@interface GalleryVC ()

@end

@implementation GalleryVC


@synthesize imageView;

-(id)init {
    NSString * nibname = [NSString stringWithFormat:@"GalleryVC_%@", [Utilities getNibSuffix]];
                          
    self = [super initWithNibName:nibname
                           bundle:nil];
    


    if (self) {
        active_gallery_index = 0;
        
        // SWC -- initialize this view and watch it through SW
        [self initializeSWVC:@"Gallery"
               new_global_id:[self filenameForIndex:active_gallery_index]
    new_respond_to_callbacks:NO];

    }
    
    
    return self;
}

-(NSString*)filenameForIndex:(int)index {
    return [[self photo_array] objectAtIndex:index];
}

-(NSArray*)photo_array {
    return [NSArray arrayWithObjects:
                @"1.JPG",
                @"2.JPG",
                @"3.JPG",
                @"4.JPG", nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateActivePhoto];
    [self addGestures];
    
}

-(void)addGestures {
    //next Page
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToNext)];
    [leftSwipe setNumberOfTouchesRequired:1];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:leftSwipe];
    
    // prev
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToPrev)];
    [rightSwipe setNumberOfTouchesRequired:1];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:rightSwipe];
    

}

-(void)goToNext {
    
    // SW -- track the swipe.
    [SWCUtility logAction:[self getName]
                   action:SW_ACTION_SWIPE_RIGHT
                global_id:[self filenameForIndex:active_gallery_index]
                 metadata:@""];
    
    if (active_gallery_index < ([[self photo_array] count] - 1)) {
        active_gallery_index++;
    }
    else {
        active_gallery_index = 0;
    }
    
    [self updateActivePhoto];
    
}

-(void)goToPrev {
    // SW -- track the swipe.
    [SWCUtility logAction:[self getName]
                   action:SW_ACTION_SWIPE_LEFT
                global_id:[self filenameForIndex:active_gallery_index]
                 metadata:@""];
    
    if (active_gallery_index > 0) {
        active_gallery_index--;
    }
    else {
        active_gallery_index = ([[self photo_array] count] - 1);
    }
    
    [self updateActivePhoto];
}

-(void)updateActivePhoto {
    imageView.image = [UIImage imageNamed:[self filenameForIndex:active_gallery_index]];
    
    
    // SWC -- Tell Starwatch that the active photo has changed within this view
    [self initializeSWVC:[self getName]
           new_global_id:[self filenameForIndex:active_gallery_index]
new_respond_to_callbacks:NO];
    
    // SWC -- ...and log that the view change itself.
    [self logViewAppearAction];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    
    // SWC -- The view is going away and we're not tracking it automatically,
    //      so mark that it's leaving.
    [self logViewDisappearAction];
}

-(void)viewDidUnload {
    

    
    [self setImageView:nil];
    
    [super viewDidUnload];
}

@end
