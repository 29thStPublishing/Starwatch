//
//  FeedbackVC.h
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackVC : UIViewController <UITextViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITextView * textView;
@property (weak, nonatomic) IBOutlet UIButton * submitButton;

-(IBAction)sendFeedback:(id)sender;
@end
