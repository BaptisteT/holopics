//
//  DisplayHolopicViewController.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/8/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Holopic.h"

@protocol DisplayHolopicVCDelegate;

@interface DisplayHolopicViewController : UIViewController

@property (nonatomic) BOOL fullscreenMode;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) id <DisplayHolopicVCDelegate> displayHolopicVCDelegate;

- (id)initWithHolopic:(Holopic *)holopic;

@end

@protocol DisplayHolopicVCDelegate

@property (nonatomic) BOOL fullscreenModeInExplore;

@end
