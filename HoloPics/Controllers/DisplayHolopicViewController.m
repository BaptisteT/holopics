//
//  DisplayHolopicViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/8/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "DisplayHolopicViewController.h"
#import "ImageUtilities.h"
#import "TimeUtilities.h"
#import "UIImageView+AFNetworking.h"

@interface DisplayHolopicViewController ()

@property (nonatomic, strong) Holopic *holopic;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@end

@implementation DisplayHolopicViewController


// ----------------------
// Life cycle
// ----------------------

- (id)initWithHolopic:(Holopic *)holopic
{
    if (self = [super initWithNibName:@"DisplayHolopic" bundle:nil])
    {
        self.holopic = holopic;
    }
    return self;
}

- (void)viewDidLoad
{
    self.fullscreenMode = self.displayHolopicVCDelegate.fullscreenModeInExplore;

    self.timeStamp.text = @"";
    
    [ImageUtilities outerGlow:self.timeStamp];
    
    self.imageView.clipsToBounds = YES;
    
    [self loadImage];
    
    NSString *holopicCreated = [TimeUtilities ageToString:[TimeUtilities getHolopicAge:self.holopic.created]];
    self.timeStamp.text = [holopicCreated isEqualToString:@"Now"] ? holopicCreated : [NSString stringWithFormat:@"%@ ago", holopicCreated];
}

// ----------------------
// Utilities
// ----------------------

- (void)loadImage
{
    self.errorMessage.hidden = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[self.holopic getHolopicImageURL]];
    
    [self showLoadingIndicator];
    
    [self.imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.imageView.image = image;
        [self hideLoadingIndicator];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        self.errorMessage.text = @"Couldn't load image. Please refresh.";
        self.errorMessage.hidden = NO;
        [self hideLoadingIndicator];
    }];
}

- (void)showLoadingIndicator
{
    if (!self.activityView) {
        self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.center=self.view.center;
    }
    
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];
}

- (void)hideLoadingIndicator
{
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
}

- (void)setFullscreenMode:(BOOL)fullscreenMode
{
    if (fullscreenMode) {
        _fullscreenMode = YES;
        self.timeStamp.hidden = YES;
    } else {
        _fullscreenMode = NO;
        self.timeStamp.hidden = NO;
    }
}

@end
