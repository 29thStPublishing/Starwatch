//
//  MainVC
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCViewController.h"
#import "SWCUIButton.h"

@interface MainVC : SWCViewController {

}

-(id)init;

-(IBAction)goToGallery:(id)sender;
-(IBAction)goToText:(id)sender;
-(IBAction)goToFeedback:(id)sender;



@property (weak, nonatomic) IBOutlet SWCUIButton * galleryButton;
@property (weak, nonatomic) IBOutlet SWCUIButton * textButton;
@property (weak, nonatomic) IBOutlet SWCUIButton * feedbackButton;


@end
