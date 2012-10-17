//
//  MainVC
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController {

}

-(id)init;

-(IBAction)goToGallery:(id)sender;
-(IBAction)goToText:(id)sender;
-(IBAction)goToFeedback:(id)sender;



@property (weak, nonatomic) IBOutlet UIButton * galleryButton;
@property (weak, nonatomic) IBOutlet UIButton * textButton;
@property (weak, nonatomic) IBOutlet UIButton * feedbackButton;


@end
