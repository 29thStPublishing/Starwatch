//
//  FeedbackVC.h
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCViewController.h"
#import "SWCUIButton.h"

@interface FeedbackVC : SWCViewController <UITextViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITextView * textView;
@property (weak, nonatomic) IBOutlet SWCUIButton * submitButton;

-(IBAction)sendFeedback:(id)sender;
@end
