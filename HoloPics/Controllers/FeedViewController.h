//
//  ExploreViewController.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/8/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Holopic.h"
#import "DisplayHolopicViewController.h"

@interface FeedViewController : UIViewController <UIScrollViewDelegate, DisplayHolopicVCDelegate>

@property (nonatomic) BOOL fullscreenModeInExplore;

@end
