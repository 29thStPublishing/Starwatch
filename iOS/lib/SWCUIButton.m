//
//  SWCUIButton.m
//  StarWatch
//
//  Created by Natalie Podrazik on 1/17/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import "SWCUIButton.h"
#import "SWCUtility.h"


@implementation SWCUIButton

- (id)init:(NSString*)newName {
// frame:(CGRect)frame{

    self = [super init];

    if (self) {
        [self activate:newName];
        [self setMetadata:@""];
        [self setGlobalId:@""];
    }
    
    return self;
}

-(void)activate:(NSString*)newName {
    [self setSWCName:newName];
    [self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)setMetadata:(NSString*)newMetadata {
    metadata = [NSString stringWithFormat:@"%@", newMetadata];
}

-(void)setGlobalId:(NSString*)newGlobalId {
    global_id = [NSString stringWithFormat:@"%@", newGlobalId];

}


-(void)setSWCName:(NSString*)newName {
    sw_name = [NSString stringWithFormat:@"%@", newName];
}


-(void)buttonPressed:(id)sender {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:sw_name
                                                   global_id:@""
                                                      action:SW_ACTION_PRESS_BUTTON
                                                    metadata:metadata]];
}


@end
