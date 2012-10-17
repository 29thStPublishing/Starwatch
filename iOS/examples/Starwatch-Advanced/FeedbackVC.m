//
//  FeedbackVC.m
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "FeedbackVC.h"
#import "Utilities.h"
#import "SWCUIButton.h"
#import "SWCUtility.h"

#define PLACEHOLDER_FEEDBACK @"I think that..."

#define SUBMIT_TITLE @"Send feedback?"
#define SUBMIT_MESSAGE @"All feedback is anonymous."
#define SUBMIT_AFFIRMATIVE @"Send"
#define SUBMIT_NEGATIVE @"Cancel"

@interface FeedbackVC ()

@end

@implementation FeedbackVC

@synthesize textView;
@synthesize submitButton;

-(id)init {
    NSString * nibname = [NSString stringWithFormat:@"FeedbackVC_%@",
                          [Utilities getNibSuffix]];
    
    self = [super initWithNibName:nibname
                           bundle:nil];
    
    
    
    if (self) {
        [self initializeSWVC:@"FeedbackVC"
               new_global_id:@""
    new_respond_to_callbacks:YES];
    }
    
    
    return self;
}

-(void)activateStarwatch {
    [submitButton activate:@"Feedback-Submit"];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // SW -- make the elements respond to actions
    [self activateStarwatch];
    
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;

    [textView setText:PLACEHOLDER_FEEDBACK];
    
    // this makes the keyboard drawer pop up immediately.
    [textView becomeFirstResponder];
    
    // this is needed to respond to the closing of the keyboard.
    textView.delegate = self;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];

}


-(void)showConfirmationForFeedbackSubmission {
    
    if (![textView.text isEqualToString:PLACEHOLDER_FEEDBACK]) {
        
        // update the responder for this article.
        
        /* ask them if they really want to tweet this. */
        UIAlertView *confirmSubmit = [[UIAlertView alloc] initWithTitle:SUBMIT_TITLE
                                                                message:SUBMIT_MESSAGE
                                                               delegate:self
                                                      cancelButtonTitle:SUBMIT_NEGATIVE
                                                      otherButtonTitles:SUBMIT_AFFIRMATIVE, nil];
        
        
        [confirmSubmit show];
        confirmSubmit = nil;
    }
    else {
        // do nothing.
    }
}


-(IBAction)sendFeedback:(id)sender {
    [self showConfirmationForFeedbackSubmission];
    /* ask them if they really want to tweet this. */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:SUBMIT_AFFIRMATIVE]) {

        // log their message into starwatch.
        // SW -- Log this message!
        [SWCUtility logAction:[self getName]
                       action:SW_ACTION_FEEDBACK
                    global_id:@""
                     metadata:textView.text];
    }
    else {
        // You could optionally log that they "cancelled" sharing feedback.
    }
}

-(void)keyboardWillHide:(id)sender {
    
    // get confirmation from the user that they want to leave this feedback &&
    // as long as the text isn't pure placeholder text, submit it!
}
    
    

-(void)shouldShowKeyboard:(id)sender {
    // do nothing
}

-(void)keyboardWillShow:(id)sender {
    // do nothing    
}

-(void)viewDidUnload {
    
    [self setTextView:nil];
    [self setSubmitButton:nil];
    
    [super viewDidUnload];
}


@end
