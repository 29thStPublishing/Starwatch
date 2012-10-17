//
//  GalleryVC.h
//  Starwatch-Plain
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCViewController.h"

@interface GalleryVC : SWCViewController {
    int active_gallery_index;
}


@property (weak, nonatomic) IBOutlet UIImageView * imageView;

@end
