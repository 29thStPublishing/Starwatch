//
//  SWCUIButton.h
//  StarWatch
//
//  Created by Natalie Podrazik on 1/17/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWCUIButton : UIButton {
    NSString * sw_name;
    NSString * metadata;
    NSString * global_id;
}

- (id)init:(NSString*)newName;
// frame:(CGRect)frame;

-(void)activate:(NSString*)newName;

-(void)setSWCName:(NSString*)newName;

-(void)buttonPressed:(id)sender;
-(void)setMetadata:(NSString*)newMetadata;
-(void)setGlobalId:(NSString*)newGlobalId;

@end
