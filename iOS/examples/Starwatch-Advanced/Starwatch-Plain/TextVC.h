//
//  TextVC.h
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCViewController.h"


@interface TextVC : SWCViewController <UIScrollViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIWebView * textView;


@end
