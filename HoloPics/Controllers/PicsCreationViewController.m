//
//  PicsCreationViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "PicsCreationViewController.h"
#import "Constants.h"
#import "ImageUtilities.h"
#import "GeneralUtilities.h"
#import "BackgroundView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>
#import "ShapeView.h"
#import "SharingViewController.h"
#import "MBProgressHUD.h"
#import "Holopic.h"
#include "AppDelegate.h"
#include "ShapeInfo.h"
#include "ScrollableShapeView.h"
#import "PathUtility.h"
#import "AFHolopicsAPIClient.h"

#define ACTION_SHEET_OPTION_1 NSLocalizedStringFromTable (@"clean_screen", @"Strings", @"comment")
#define ACTION_SHEET_OPTION_2 NSLocalizedStringFromTable (@"return_to_feed", @"Strings", @"comment")
#define ACTION_SHEET_CANCEL NSLocalizedStringFromTable (@"cancel", @"Strings", @"comment")

@interface PicsCreationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIButton *shapeButton;

@property (weak, nonatomic) IBOutlet UIView *backgroundOptionsView;
@property (weak, nonatomic) IBOutlet UIScrollView *shapeOptionsScrollView;
@property (strong, nonatomic) IBOutlet UIView*whiteBackgroundOptionsView;
@property (weak, nonatomic) IBOutlet UIView *whiteShapeOptionsView;


@property (weak, nonatomic) IBOutlet BackgroundView *backgroundView;
@property (strong, nonatomic)  NSMutableArray *shapeViews;
@property (nonatomic) NSInteger subViewIndex;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSMutableArray *scrollableShapeViews;

@end

@implementation PicsCreationViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// ----------------------------------------------------------
// Life cycle
// ----------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Some init
    self.subViewIndex = 0;
    
    // Scroll view
    self.shapeOptionsScrollView.clipsToBounds = NO;
    self.shapeOptionsScrollView.showsHorizontalScrollIndicator = NO;
    self.shapeOptionsScrollView.showsVerticalScrollIndicator = NO;
    self.shapeOptionsScrollView.scrollsToTop = NO;
    self.shapeOptionsScrollView.delegate = self;
    [self.shapeOptionsScrollView setContentOffset:CGPointMake(0, 0)];

    // Some design
    [ImageUtilities outerGlow:self.shareButton];
    [ImageUtilities outerGlow:self.cancelButton];
    [ImageUtilities outerGlow:self.shapeButton];
    [ImageUtilities outerGlow:self.backgroundButton];
    NSUInteger buttonHeight = self.backgroundButton.bounds.size.height;
    self.backgroundButton.layer.cornerRadius = buttonHeight/2;
    buttonHeight = self.shapeButton.bounds.size.height;
    self.shapeButton.layer.cornerRadius = buttonHeight/2;
    
    self.backgroundView.backgroundViewDelegate = self;
    
    // If there is a forwarded image, we display it
    if(self.forwardedImage) {
        [self setBackgoundImage:self.forwardedImage];
        self.forwardedImage = nil;
    }
    
    // Load shapes
    [self loadShapesInfoInCoreData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;

    if ([segueName isEqualToString: @"Share From Create Push Segue"]) {
        ((SharingViewController *) [segue destinationViewController]).imageToShare = (UIImage *)sender;
    }
    
    if ([segueName isEqualToString: @"Import From Create Push Segue"]) {
        ((ImportPictureViewController *) [segue destinationViewController]).importPictureVCDelegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeAllShapeOverlay];
    // save context
    NSError *error;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        // todo deal with error
        // save here??
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}


// --------------------------------
// Buttons clicked
// --------------------------------

- (IBAction)saveButtonClicked:(id)sender {

    [AFHolopicsAPIClient sendAnalytics:@"shareButtonClicked" AndExecuteSuccess:nil failure:nil];
    // Remove button before saving
    [self.shareButton setHidden:YES];
    [self.cancelButton setHidden:YES];
    [self.backgroundButton setHidden:YES];
    [self.shapeButton setHidden:YES];
    [self.shapeOptionsScrollView setHidden:YES];
    [self.backgroundOptionsView setHidden:YES];
    [self.whiteBackgroundOptionsView setHidden:YES];
    [self.whiteShapeOptionsView setHidden:YES];
    
    [self removeAllShapeOverlay];
    
    // Create Image
    UIImage *imageToShare = [ImageUtilities imageFromView:self.view];
    
    [self.shareButton setHidden:NO];
    [self.cancelButton setHidden:NO];
    [self.backgroundButton setHidden:NO];
    [self.shapeButton setHidden:NO];
    
    // Perform segue
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"Share From Create Push Segue" sender:imageToShare];    
}

// Cancel path and pictures
- (IBAction)cancelButtonClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:ACTION_SHEET_CANCEL destructiveButtonTitle:nil otherButtonTitles:ACTION_SHEET_OPTION_1, ACTION_SHEET_OPTION_2, nil];
    
    [actionSheet showInView:self.backgroundView];
}

// Display or hide background options
- (IBAction)backgroundButtonClicked:(id)sender {
    [self hideOrDisplayBackgroundOptionsView];
}

// Display or hide shape options
- (IBAction)shapeButtonClicked:(id)sender {
    if (self.shapeOptionsScrollView.isHidden) {
        self.shapeOptionsScrollView.hidden = NO;
        self.whiteShapeOptionsView.hidden = NO;
        [self.shapeOptionsScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        self.shapeOptionsScrollView.hidden = YES;
        self.whiteShapeOptionsView.hidden = YES;
    }
}

- (IBAction)cameraButtonClicked:(id)sender {
    [self presentCameraViewControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)libraryButtonClicked:(id)sender {
    [self presentCameraViewControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)importPictureButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Import From Create Push Segue" sender:nil];
}


// --------------------------------
// CameraVCDelegate protocol
// --------------------------------

- (void)setBackgoundImage:(UIImage *)image {
    double targetRatio = kScreenWidth / self.view.frame.size.height;
    UIImageOrientation orientation =  image.size.width > image.size.height ? UIImageOrientationRight : image.imageOrientation;
    self.backgroundView.originalImage = [ImageUtilities cropImage:image toFitWidthOnHeightTargetRatio:targetRatio andOrientate:orientation];
    [self.backgroundView setImage:self.backgroundView.originalImage];
    [self.backgroundOptionsView setHidden:YES];
    [self.whiteBackgroundOptionsView setHidden:YES];
}


// --------------------------------
// Scrollable Shape View protocol
// --------------------------------

- (ShapeView *)insertNewShapeViewWithImage:(UIImage *)image andPath:(UIBezierPath *)path {

    if (!self.shapeViews){
        self.shapeViews = [NSMutableArray arrayWithCapacity:1];
    }
    [AFHolopicsAPIClient sendAnalytics:@"InsertShape" AndExecuteSuccess:nil failure:nil];

    // Return if we reached the limit of images
    if (self.subViewIndex >= kMaxNumberOfShapes) {
        [GeneralUtilities showMessage:@"You reached the maximum number of shapes!" withTitle:nil];
        return nil;
    }

    ShapeView *newShapeView = [[ShapeView alloc] initWithImage:image frame:self.view.frame andPath:path];
    
    CGFloat ratio = 0.6 / MAX(path.bounds.size.width / self.view.frame.size.width, path.bounds.size.height / self.view.frame.size.height);
    
    // Param
    newShapeView.frame = self.view.frame;
    newShapeView.shapeViewDelegate = self;
    [newShapeView applyTransform:CGAffineTransformScale(newShapeView.transform, ratio, ratio)];
    
    // Add it to the array
    [self removeAllShapeOverlay];
    [self.shapeViews addObject:newShapeView];
    
    // Show it
    self.subViewIndex ++;
    [self.view insertSubview:newShapeView atIndex:self.subViewIndex];
    
    return newShapeView;
}

- (void)removeShape:(ShapeView *)shapeView {
    [shapeView removeFromSuperview];
    [self.shapeViews removeObject:shapeView];
    self.subViewIndex --;
}

- (void)setShapeCenter:(ShapeView *)shapeView ToPoint:(CGPoint)point
{
    // Translate into superview coordinate system
    CGFloat x = point.x - self.shapeOptionsScrollView.contentOffset.x;
    CGFloat y = point.y + self.view.frame.size.height - kScrollableViewHeight;
    
    shapeView.center = CGPointMake(x, y);
}

- (void)deleteShapeFromScrollView:(ScrollableShapeView *)shapeInScrollView
{
    [self.scrollableShapeViews removeObject:shapeInScrollView];
    
    for (ScrollableShapeView* otherView in self.scrollableShapeViews) {
        if ([otherView.shapeInfo.index integerValue] > [shapeInScrollView.shapeInfo.index integerValue]) {
            [otherView incremenentIndexAndFrameOf:-1];
        }
    }
     self.shapeOptionsScrollView.contentSize = CGSizeMake(self.shapeOptionsScrollView.contentSize.width - kScrollableViewHeight, kScrollableViewHeight);
    
    [shapeInScrollView removeFromSuperview];
    [[self managedObjectContext] deleteObject:shapeInScrollView.shapeInfo];
}


// --------------------------------
// backgroundViewDelegate protocol
// --------------------------------

// Create flexible subview with the image inside the path
- (void)createShapeWithImage:(UIImage *)image andPath:(UIBezierPath *)path
{
    // todo check that we don't exceed a certain number
    if (self.shapeOptionsScrollView.contentSize.width >= kMaxNumberOfShapesInMemory * kScrollableViewHeight) {
        [GeneralUtilities showMessage:@"Delete shapes by sliding them toward the bottom of the screen" withTitle:@"You reached the maximum number of shapes in memory"];
        return;
    }
    [AFHolopicsAPIClient sendAnalytics:@"CreateShape" AndExecuteSuccess:nil failure:nil];
    
    // Image directory path
    NSString *relativeImagePath = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSinceReferenceDate]];
    
    // Cut and save image
    UIImage *croppedImage = [ImageUtilities drawFromImage:image insidePath:path];
    if (![ImageUtilities saveImage:croppedImage inAppDirectoryPath:relativeImagePath]) {
        [GeneralUtilities showMessage:NSLocalizedStringFromTable(@"shape_saving_fail_message",@"Strings",@"comment") withTitle:nil];
        return;
    }
    
    // Add new shape info object in context
    NSManagedObjectContext *context = [self managedObjectContext];
    ShapeInfo *shapeInfo = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ShapeInfo"
                            inManagedObjectContext:context];
    shapeInfo.index = 0;
    shapeInfo.relativeImagePath = relativeImagePath;
    shapeInfo.bezierPath = [UIBezierPath bezierPathWithCGPath:path.CGPath];

    // Create scrollable shape view
    self.shapeOptionsScrollView.contentSize = CGSizeMake(self.shapeOptionsScrollView.contentSize.width + kScrollableViewHeight, kScrollableViewHeight);
    ScrollableShapeView *scrollableShape = [[ScrollableShapeView alloc] initWithShapeInfo:shapeInfo];
    scrollableShape.scrollableShapeViewDelegate = self;
    
    // Increment Index and Frame
    [self.shapeOptionsScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    for (ScrollableShapeView* scrollableShapeViews in self.scrollableShapeViews) {
        [scrollableShapeViews incremenentIndexAndFrameOf:1];
    }
    
    // Set initial param before animation
    CGRect frame = [self.view convertRect:[PathUtility getSquareBoundsOfPath:path] toView:self.shapeOptionsScrollView];
    scrollableShape.frame = frame;
    scrollableShape.backgroundColor = [UIColor blackColor];

    
    // Add the new shape to the scrollable views
    [self.scrollableShapeViews addObject:scrollableShape];
    [self.shapeOptionsScrollView addSubview:scrollableShape];
    
    [UIView animateWithDuration:1.0 animations:^{
        scrollableShape.frame = CGRectMake(kScrollableViewHeight * [shapeInfo.index integerValue] + kScrollableViewInitialOffset, 0, kScrollableViewHeight, kScrollableViewHeight);
        scrollableShape.backgroundColor =[UIColor clearColor];
    }];
}

- (void)hideOrDisplayBackgroundOptionsView
{
    if (self.backgroundOptionsView.isHidden) {
        self.backgroundOptionsView.hidden = NO;
        self.whiteBackgroundOptionsView.hidden = NO;
    } else {
        self.backgroundOptionsView.hidden = YES;
        self.whiteBackgroundOptionsView.hidden = YES;
    }
}

- (BOOL)isShapeScrollableViewHidden
{
    return self.shapeOptionsScrollView.isHidden;
}

- (void)hideShapesDuringDrawing
{
    self.shapeOptionsScrollView.hidden = YES;
    self.whiteShapeOptionsView.hidden = YES;
    
    for(ShapeView *shapes in self.shapeViews) {
        [shapes setHidden:YES];
    }
}

- (void)displayShapesAfterDrawing
{
    self.shapeOptionsScrollView.hidden = NO;
    self.whiteShapeOptionsView.hidden = NO;
    
    for(ShapeView *shapes in self.shapeViews) {
        [shapes setHidden:NO];
    }
}

// --------------------------------
// ShapeViewDelegate protocol
// --------------------------------

- (void)sendToFrontView:(ShapeView *)view
{
    [self.view insertSubview:view atIndex:self.subViewIndex];
}

- (void)deleteView:(ShapeView *)view
{
    [view removeFromSuperview];
    [self.shapeViews removeObject:view];
    self.subViewIndex --;
}

- (void)removeAllShapeOverlay
{
    for (ShapeView *shape in self.shapeViews) {
        [shape hideOptionOverlayView];
    }
}

// --------------------------------------------
// Core Data related methods
// --------------------------------------------

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    return _managedObjectContext;
}

- (void)loadShapesInfoInCoreData
{
    NSArray *requestResults = [self getShapeInCoreData];
    
    // Create scrollable shapeView
    self.scrollableShapeViews = [NSMutableArray arrayWithCapacity:requestResults.count];
    CGFloat squareWidth = CGRectGetHeight(self.shapeOptionsScrollView.frame);
    self.shapeOptionsScrollView.contentSize = CGSizeMake(squareWidth * requestResults.count + kScrollableViewInitialOffset, squareWidth);
    for(ShapeInfo* shapeInfo in requestResults) {
        ScrollableShapeView *scrollableShape = [[ScrollableShapeView alloc] initWithShapeInfo:shapeInfo];
        scrollableShape.frame = CGRectMake(squareWidth * [shapeInfo.index integerValue] + kScrollableViewInitialOffset, 0, squareWidth, squareWidth);
        scrollableShape.scrollableShapeViewDelegate = self;
        [self.scrollableShapeViews addObject:scrollableShape];
        [self.shapeOptionsScrollView addSubview:scrollableShape];
    }
}

- (NSArray *)getShapeInCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ShapeInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *requestResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error){
        // todo error handling
    }
    return requestResults;
}


// --------------------------------
// Utilities
// --------------------------------

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:ACTION_SHEET_CANCEL]) {
        // do nothing
    } else if ([buttonTitle isEqualToString:ACTION_SHEET_OPTION_1]) {
        // Clean everything
        [self.backgroundView clearPathAndPictures];
        self.subViewIndex = 0;
        for(id subView in self.shapeViews) {
            [(ShapeView *)subView removeFromSuperview];
        }
        self.shapeViews = nil;
    } else if ([buttonTitle isEqualToString:ACTION_SHEET_OPTION_2]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)presentCameraViewControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    CameraViewController *cameraViewController = [[CameraViewController alloc] init];
    cameraViewController.cameraVCDelegate = self;
    cameraViewController.sourceType = sourceType;
    [self.navigationController pushViewController:cameraViewController animated:NO];
}


@end
