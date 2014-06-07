//
//  ExploreViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/8/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "FeedViewController.h"
#import "AFHolopicsAPIClient.h"
#import "ImageUtilities.h"
#import "DisplayHolopicViewController.h"
#import "PicsCreationViewController.h"
#import "GeneralUtilities.h"
#import "TutoImageView.h"

#define PER_PAGE 10

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *statusBarContainer;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL noMoreHolopicToPull;
@property (nonatomic) BOOL pullingMoreHolopics;
@property (nonatomic) NSUInteger lastPageScrolled;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *holopics;
@property (weak, nonatomic) IBOutlet UILabel *appName;

@end

@implementation FeedViewController

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.fullscreenModeInExplore;
}


// ------------------------------------------------
// Lifecycle
// ------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fullscreenModeInExplore = NO;
    NSUInteger buttonHeight = self.cameraButton.bounds.size.height;
    self.cameraButton.layer.cornerRadius = buttonHeight/2;
    buttonHeight = self.forwardButton.bounds.size.height;
    self.forwardButton.layer.cornerRadius = buttonHeight/2;
    [ImageUtilities outerGlow:self.cameraButton];
    [ImageUtilities outerGlow:self.forwardButton];
    [ImageUtilities outerGlow:self.appName];
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    // Tuto on first opening
//    if ([GeneralUtilities isFirstOpening]) {
//        [AFHolopicsAPIClient sendAnalytics:@"FirstOpening" AndExecuteSuccess:nil failure:nil];
//        TutoImageView *tutoView = [[TutoImageView alloc] initWithFrame:self.view.bounds];
//        tutoView.image = [UIImage imageNamed:@"tuto_feed.png"];
//        [self.view addSubview:tutoView];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.page = 1;
    self.noMoreHolopicToPull = NO;
    self.pullingMoreHolopics = NO;
    [self loadFirstPageHolopics];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}


// ------------------------------------------------
// Loading Holopics
// ------------------------------------------------

- (void)loadFirstPageHolopics
{
    [self loadingHolopicsUI];
    
    [AFHolopicsAPIClient getHolopicsAtPage:1 pageSize:PER_PAGE AndExecuteSuccess:^(NSArray *holopics, NSInteger page) {
        self.holopics = [holopics mutableCopy];
    } failure:^{
        [self noConnectionUI];
    }];
}

- (void)setHolopics:(NSMutableArray *)holopics
{
    _holopics = holopics;
    
    self.noMoreHolopicToPull = NO;
    self.pullingMoreHolopics = NO;
    
    if ([holopics count] < PER_PAGE * self.page) {
        self.noMoreHolopicToPull = YES;
    }
    
    if ([holopics count] == 0) {
        return;
    }
    
    //Remove existing controllers
    if (self.viewControllers) {
        NSUInteger count = [self.viewControllers count];
        
        for (NSUInteger i = 0; i < count; i++) {
            DisplayHolopicViewController *viewController = [self.viewControllers objectAtIndex:i];
            if ((NSNull *)viewController != [NSNull null]) {
                [viewController removeFromParentViewController];
                [viewController.view removeFromSuperview];
                viewController = (DisplayHolopicViewController *)[NSNull null];
            }
        }
    }
    
    NSUInteger numberPages = self.holopics.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < numberPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    
    self.viewControllers = controllers;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height * numberPages);
    
    [self displaySnapbiesUI];
    
    [self loadHolopics];
}

- (void)loadHolopics
{
    NSInteger page = [self getScrollViewPage];
    
    if (page > [self.holopics count] - 1) {
        return;
    }

    NSUInteger count = [self.viewControllers count];
    
    for (int i = 0; i < count; i = i + 1) {
        if (i >= MAX(page - 2, 0) && i <= page + 2) {
            [self loadScrollViewWithPage:i];
        } else {
            [self unloadScrollViewWithPage:i];
        }   
    }
}

// ------------------------------------------------
// Feed Buttons Clicked
// ------------------------------------------------
- (IBAction)cameraButtonClicked:(id)sender {
    [AFHolopicsAPIClient sendAnalytics:@"CameraButtonClicked" AndExecuteSuccess:nil failure:nil];
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)forwardButtonClicked:(id)sender {
    [AFHolopicsAPIClient sendAnalytics:@"ForwardButtonClicked" AndExecuteSuccess:nil failure:nil];
    DisplayHolopicViewController *controller = [self.viewControllers objectAtIndex:[self getScrollViewPage]];
    UIImage *forwardedImage = controller.imageView.image;
    [self.feedVCDelegate setBackgoundImage:forwardedImage];
    [self.navigationController popViewControllerAnimated:NO];
}


// ------------------------------------------------
// Scroll view delegate methods
// ------------------------------------------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger page = [self getScrollViewPage];
    
    if (scrollView.contentOffset.y < -50 && !self.pullingMoreHolopics) {
        self.page = 1;
        self.pullingMoreHolopics = YES;
        [self loadFirstPageHolopics];
        return;
    }
    
    //Skip if method already called for this page
    if (page == self.lastPageScrolled) {
        return;
    }
    [AFHolopicsAPIClient sendAnalytics:@"ScrollPage" AndExecuteSuccess:nil failure:nil];
    self.lastPageScrolled = page;
    
    if (page > [self.viewControllers count] - 1) {
        [self noMoreHolopicsUI];
        return;
    } else {
        [self endNoMoreHolopicsUI];
    }
    
    [self loadHolopics];
    
    //Pull more snapbies if it's the last snapby
    if (page >= self.holopics.count - 5 && !self.noMoreHolopicToPull && !self.pullingMoreHolopics) {
        
        self.pullingMoreHolopics = YES;
        
        [AFHolopicsAPIClient getHolopicsAtPage:self.page +1 pageSize:PER_PAGE AndExecuteSuccess:^(NSArray *holopics, NSInteger page) {
            self.pullingMoreHolopics = NO;
            if (page == self.page + 1) {
                self.page = self.page + 1;
                
                self.holopics = [[self.holopics arrayByAddingObjectsFromArray:holopics] mutableCopy];
                
                [self setHolopics:self.holopics];
            }
        } failure:^{
            self.pullingMoreHolopics = NO;
        }];
    }
}

// ------------------------------------------------
// Other scroll view methods
// ------------------------------------------------

- (NSUInteger)getScrollViewPage
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageHeight = self.scrollView.frame.size.height;
    return floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
}

- (IBAction)onScrollViewClicked:(id)sender {
    if (self.fullscreenModeInExplore) {
        [self endFullscreenMode];
    } else {
        [self fullscreenMode];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.holopics.count) {
        return;
    }
    
    // replace the placeholder if necessary
    DisplayHolopicViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[DisplayHolopicViewController alloc] initWithHolopic:[self.holopics objectAtIndex:page]];
        controller.displayHolopicVCDelegate = self;
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        controller.view.frame = CGRectMake(0, self.scrollView.frame.size.height * page, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)unloadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.holopics.count) {
        return;
    }
    
    // replace the placeholder if necessary
    DisplayHolopicViewController *controller = [self.viewControllers objectAtIndex:page];
    
    if ((NSNull *)controller != [NSNull null]) {
        [[self.viewControllers objectAtIndex:page] removeFromParentViewController];
        [((DisplayHolopicViewController *)[self.viewControllers objectAtIndex:page]).view removeFromSuperview];
        [self.viewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}


// ------------------------------------------------
// UI related methods
// ------------------------------------------------


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

- (void)loadingHolopicsUI
{
    [self showLoadingIndicator];
    self.refreshButton.hidden = YES;
    self.errorMessage.hidden = YES;
}

- (void)noMoreHolopicsUI
{
    [self hideLoadingIndicator];
    self.refreshButton.hidden = YES;
    self.errorMessage.text = @"That's all!";
    self.errorMessage.hidden = NO;
}

- (void)endNoMoreHolopicsUI
{
    [self hideLoadingIndicator];
    self.refreshButton.hidden = YES;
    self.errorMessage.hidden = YES;
}

- (void)noConnectionUI
{
    [self hideLoadingIndicator];
    self.refreshButton.hidden = NO;
    self.errorMessage.text = @"No connection. Please refresh.";
    self.errorMessage.hidden = NO;
}

- (void)displaySnapbiesUI
{
    [self hideLoadingIndicator];
    self.refreshButton.hidden = YES;
    self.errorMessage.hidden = YES;
}

- (void)fullscreenMode
{
    self.fullscreenModeInExplore = YES;
    self.cameraButton.hidden = YES;
    self.forwardButton.hidden = YES;
    self.appName.hidden = YES;
    self.statusBarContainer.hidden = YES;
    
    for (DisplayHolopicViewController *controller in self.viewControllers) {
        if ((NSNull *)controller != [NSNull null]) {
            controller.fullscreenMode = YES;
        }
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)endFullscreenMode
{
    self.fullscreenModeInExplore = NO;
    self.cameraButton.hidden = NO;
    self.forwardButton.hidden = NO;
    self.appName.hidden = NO;
    self.statusBarContainer.hidden = NO;
    
    for (DisplayHolopicViewController *controller in self.viewControllers) {
        if ((NSNull *)controller != [NSNull null]) {
            controller.fullscreenMode = NO;
        }
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)refreshButtonClicked:(id)sender {
    [self loadFirstPageHolopics];
}


@end
