//
//  TextVC.m
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "TextVC.h"
#import "Utilities.h"

@implementation TextVC

@synthesize textView;



-(id)init {
    NSString * nibname = [NSString stringWithFormat:@"TextVC_%@",
                          [Utilities getNibSuffix]];
    
    self = [super initWithNibName:nibname
                           bundle:nil];
    
    
    
    if (self) {

    }
    
    
    return self;
}

-(void)viewDidUnload {
    
    [self setTextView:nil];
    
    [super viewDidUnload];
}

@end
