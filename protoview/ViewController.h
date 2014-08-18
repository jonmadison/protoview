//
//  ViewController.h
//  protoview
//
//  Created by Madison, Jon on 8/13/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Site.h"

@interface ViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic,retain) Site* selectedSite;
@end
