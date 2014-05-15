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
#import "TutoImageView.h"
#import "SharingViewController.h"
#import "MBProgressHUD.h"
#import "Holopic.h"
#include "AppDelegate.h"
#include "ShapeInfo.h"

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

@property (weak, nonatomic) IBOutlet BackgroundView *backgroundView;
@property (strong, nonatomic)  NSMutableArray *flexibleSubViews;
@property (nonatomic) NSInteger subViewIndex;

@property (nonatomic) BOOL firstOpening;
@property (strong, nonatomic) TutoImageView *tutoView;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


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
    self.firstOpening = [GeneralUtilities isFirstOpening];
    self.subViewIndex = 0;
    
    // Some design
    [ImageUtilities outerGlow:self.shareButton];
    [ImageUtilities outerGlow:self.cancelButton];
    
    // If there is a forwarded image, we display it
    if(self.forwardedImage) {
        self.backgroundView.originalImage = self.forwardedImage;
        [self.backgroundView setImage:self.forwardedImage];
    }
    
    // Get managed object context
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    // todo load shapes
    
    
    self.backgroundView.backgroundViewDelegate = self;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;

    if ([segueName isEqualToString: @"Share From Create Push Segue"]) {
        ((SharingViewController *) [segue destinationViewController]).imageToShare = (UIImage *)sender;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.fetchedResultsController = nil;
}

// --------------------------------
// Buttons clicked
// --------------------------------

- (IBAction)saveButtonClicked:(id)sender {

    // Remove button before saving
    [self.shareButton setHidden:YES];
    [self.cancelButton setHidden:YES];
    [self.backgroundButton setHidden:YES];
    [self.shapeButton setHidden:YES];
    [self.shapeOptionsScrollView setHidden:YES];
    [self.backgroundOptionsView setHidden:YES];
    
    // Remove border around shapes
    for (ShapeView *views in self.flexibleSubViews){
        [views setImage:views.attachedImage];
    }
    
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
    } else {
        self.shapeOptionsScrollView.hidden = YES;
    }
}

- (IBAction)cameraButtonClicked:(id)sender {
    [self presentCameraViewControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)libraryButtonClicked:(id)sender {
    [self presentCameraViewControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


// --------------------------------
// CameraVCDelegate protocol
// --------------------------------

- (void)setBackgoundImage:(UIImage *)image {
    self.backgroundView.originalImage = image;
    [self.backgroundView setImage:image];
}


// --------------------------------
// backgroundViewDelegate protocol
// --------------------------------

// Create flexible subview with the image inside the path
- (void)createShapeWithImage:(UIImage *)image andPath:(UIBezierPath *)path
{
    // Create shape
    // todo check that we don't exceed a certain number
    ShapeView *shape = [[ShapeView alloc] initWithImage:image andPath:path];
    shape.shapeViewDelegate = self;
    
    // Save image
    // todo
    
    // Save path and index in the core data
    // todo save it in the data
    NSManagedObjectContext *context = [self managedObjectContext];
    ShapeInfo *shapeInfo = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"ShapeInfo"
                                      inManagedObjectContext:context];
    shapeInfo.index = @"Test Bank";
    shapeInfo.relativeImagePath = @"Testville";
    shapeInfo.bezierPath = path;

    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    // todo add it to the scroll view (first position)
    
//    
//    if (!self.flexibleSubViews){
//        self.flexibleSubViews = [NSMutableArray arrayWithCapacity:1];
//    }
//    
//    // Return if we reached the limit of images
//    if (self.subViewIndex > kMaxNumberOfShapes) {
//        [GeneralUtilities showMessage:@"You reached the maximum number of pics!" withTitle:nil];
//        return;
//    }
//    
//    // Add it to
//    
//    [self.flexibleSubViews addObject:shape];
//    
//    // Add this subview to cameraOverlayView (before buttons)
//    self.subViewIndex ++;
//    [self.imagePickerController.cameraOverlayView insertSubview:shape atIndex:self.subViewIndex];
    
}

- (void)hideOrDisplayBackgroundOptionsView
{
    if (self.backgroundOptionsView.isHidden) {
        self.backgroundOptionsView.hidden = NO;
    } else {
        self.backgroundOptionsView.hidden = YES;
    }
}

// --------------------------------
// ShapeViewDelegate protocol
// --------------------------------

- (void)sendToFrontView:(ShapeView *)view
{
    [self.view insertSubview:view atIndex:self.subViewIndex];
}


// --------------------------------------------
// NSFetchedResultsControllerDelegate protocol
// ---------------------------------------------

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"FailedBankInfo" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"details.closeDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
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
        for(id subView in self.flexibleSubViews) {
            [(ShapeView *)subView removeFromSuperview];
        }
        self.flexibleSubViews = nil;
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
