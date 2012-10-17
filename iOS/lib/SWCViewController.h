//
//  SWCViewController.h
//  StarWatch
//
//  Created by Natalie Podrazik on 1/13/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWCViewController : UIViewController <UIGestureRecognizerDelegate>{
    NSString * name;
    NSString * global_id;
    
    BOOL respond_to_callbacks;
}


- (id)init:(NSString*)new_name new_global_id:(NSString*)new_global_id
    new_respond_to_callbacks:(BOOL)new_respond_to_callbacks;

-(void)initializeSWVC:(NSString*)new_name 
        new_global_id:(NSString*)new_global_id
new_respond_to_callbacks:(BOOL)new_respond_to_callbacks;

-(NSString*)getName;
-(void)setName:(NSString*)new_name;
-(void)setGlobalId:(NSString*)new_global_id;
-(void)setRespondToCallbacks:(BOOL)new_respond_to_callbacks;
-(void)logScrolledToBottom;
-(void)logScrolledToTop;


// use https://github.com/mongodb/mongo-c-driver for the senders.



-(void)logViewAppearAction;
-(void)logViewDisappearAction;


-(void)didTouch:(CGPoint)location;
+(NSString*)getOrientation;


@end
