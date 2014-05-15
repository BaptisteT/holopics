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

#define ACTION_SHEET_OPTION_1 NSLocalizedStringFromTable (@"photo_bank", @"Strings", @"comment")
#define ACTION_SHEET_OPTION_2 NSLocalizedStringFromTable (@"photo_library", @"Strings", @"comment")
#define ACTION_SHEET_OPTION_3 NSLocalizedStringFromTable (@"clean_screen", @"Strings", @"comment")
#define ACTION_SHEET_OPTION_4 NSLocalizedStringFromTable (@"return_to_feed", @"Strings", @"comment")
#define ACTION_SHEET_CANCEL NSLocalizedStringFromTable (@"cancel", @"Strings", @"comment")

@interface PicsCreationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *binButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlipButton;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (weak, nonatomic) IBOutlet BackgroundView *backgroundView;
@property (strong, nonatomic)  NSMutableArray *flexibleSubViews;
@property (nonatomic) NSInteger subViewIndex;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@property (strong, nonatomic) UIImage *savedImage;
@property (nonatomic) CGAffineTransform referenceTransform;
@property (nonatomic) BOOL firstOpening;
@property (strong, nonatomic) TutoImageView *tutoView;


@end

@implementation PicsCreationViewController {
    BOOL continueToSharing;
}

// ----------------------------------------------------------
// Life cycle
// ----------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstOpening = [GeneralUtilities isFirstOpening];
    continueToSharing = NO;

    // Alloc and init full screen camera
    [self allocAndInitFullScreenCamera];
    

    // Design stuff
    [self.saveButton setHidden:YES];
    [self.binButton setHidden:YES];
    self.subViewIndex = 0;
    [ImageUtilities outerGlow:self.saveButton];
    [ImageUtilities outerGlow:self.binButton];
    [ImageUtilities outerGlow:self.cancelButton];
    [ImageUtilities outerGlow:self.cameraFlipButton];
    
    // If there is a forwarded image, we display it
    if(self.forwardedImage) {
        [self unhideSaveandHideFlipButton];
        self.backgroundView.fullImage = self.forwardedImage;
        [self.backgroundView setImage:self.forwardedImage];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!continueToSharing) {
        // Present the camera
        [self presentViewController:self.imagePickerController animated:NO completion:NULL];

        // Make this controller the delegate of backgroundView
        self.backgroundView.backgroundViewDelegate = self;

        // On first opening of the app
        if (self.firstOpening)
        {
            self.tutoView = [[TutoImageView alloc] initWithFrame:self.view.bounds];
            self.tutoView.image = [UIImage imageNamed:@"tuto1.png"];
            [self.imagePickerController.cameraOverlayView addSubview:self.tutoView];
        }
        //
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSArray *imagePathArray = [prefs objectForKey:SAVED_SHAPED_PREF];
//        if(imagePathArray.lastObject) {
//            [self.imagePickerController.cameraOverlayView addSubview:[[UIImageView alloc] initWithImage:[ImageUtilities getImageSavedLocally:[imagePathArray.lastObject integerValue]]]];
//        }
        
    } else {
        continueToSharing = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;

    if ([segueName isEqualToString: @"Share From Create Push Segue"]) {
        ((SharingViewController *) [segue destinationViewController]).imageToShare = (UIImage *)sender;
    }
}

// ----------------------------------------------------------
// Full screen Camera
// ----------------------------------------------------------

// Alloc the impage picker controller
- (void) allocAndInitFullScreenCamera
{
    // Create custom camera view
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    // Custom buttons
    imagePickerController.showsCameraControls = NO;
    imagePickerController.allowsEditing = NO;
    imagePickerController.navigationBarHidden=YES;
    
    NSString *xibName = @"CameraOverlayView";
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
    UIView* myView = [ nibViews objectAtIndex: 0];
    myView.frame = self.view.frame;
    
    imagePickerController.cameraOverlayView = myView;
    
    // Transform camera to get full screen
    double translationFactor = (self.view.frame.size.height - kCameraHeight) / 2;
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, translationFactor);
    imagePickerController.cameraViewTransform = translate;
    
    double rescalingRatio = self.view.frame.size.height / kCameraHeight;
    CGAffineTransform scale = CGAffineTransformScale(translate, rescalingRatio, rescalingRatio);
    imagePickerController.cameraViewTransform = scale;
    
    // flash disactivated by default
    imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    
    self.imagePickerController = imagePickerController;
}

// Display the relevant part of the photo once taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editInfo
{
    UIImage *image =  [editInfo objectForKey:UIImagePickerControllerOriginalImage];
    UIImageOrientation orientation;
    double targetRatio = kScreenWidth / self.view.frame.size.height;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // Force portrait, and avoid mirror of front camera
        orientation = self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
    } else {
        orientation = UIImageOrientationRight;
    }
    self.backgroundView.fullImage = [ImageUtilities imageWithImage:[ImageUtilities cropImage:image toFitWidthOnHeightTargetRatio:targetRatio andOrientate:orientation] scaledToSize:self.backgroundView.bounds.size];

    [self.backgroundView setImage:self.backgroundView.fullImage];
    [self unhideSaveandHideFlipButton];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
}

// --------------------------------
// Camera button clicked
// --------------------------------

- (IBAction)saveButtonClicked:(id)sender {

    // Remove button before saving
    [self.saveButton setHidden:YES];
    [self.cancelButton setHidden:YES];
    
    // Remove border around shapes
    for (ShapeView *views in self.flexibleSubViews){
        [views setImage:views.attachedImage];
    }
    
    // Create Image
    UIImage *imageToShare = [ImageUtilities imageFromView:self.imagePickerController.cameraOverlayView];
    
    [self.saveButton setHidden:NO];
    [self.cancelButton setHidden:NO];
    
    // Perform segue
    continueToSharing = TRUE;
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"Share From Create Push Segue" sender:imageToShare];    
}

// Front camera
- (IBAction)flipCameraButtonClicked:(id)sender
{
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

// Cancel path and pictures
- (IBAction)cancelButtonClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:ACTION_SHEET_CANCEL destructiveButtonTitle:nil otherButtonTitles:ACTION_SHEET_OPTION_3, ACTION_SHEET_OPTION_4, nil];
    
    [actionSheet showInView:self.backgroundView];
}

// --------------------------------
// backgroundViewDelegate protocol
// --------------------------------

// Take picture and display it on overlay
- (void)takePictureAndDisplay
{
    [self.imagePickerController takePicture];
}

// Import picure
- (void)letUserImportPhotoAndDisplay
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:ACTION_SHEET_CANCEL destructiveButtonTitle:nil otherButtonTitles:ACTION_SHEET_OPTION_1, ACTION_SHEET_OPTION_2, nil];
    
    [actionSheet showInView:self.backgroundView];
}

// Create flexible subview with the image inside the path
- (void)createFlexibleSubView
{
    if (!self.flexibleSubViews){
        self.flexibleSubViews = [NSMutableArray arrayWithCapacity:1];
    }
    
    // Return if we reached the limit of images
    if (self.subViewIndex > kMaxNumberOfShapes) {
        [GeneralUtilities showMessage:@"You reached the maximum number of pics!" withTitle:nil];
        return;
    }
        
    ShapeView *shape = [[ShapeView alloc] initWithImage:self.backgroundView.fullImage andPath:self.backgroundView.globalPath];
    shape.shapeViewDelegate = self;
    [self.flexibleSubViews addObject:shape];
    
    // Add this subview to cameraOverlayView (before buttons)
    self.subViewIndex ++;
    [self.imagePickerController.cameraOverlayView insertSubview:shape atIndex:self.subViewIndex];
    
    if (self.firstOpening) {
        shape.backgroundColor = [UIColor blackColor];
        self.firstOpening = NO;
        [self.tutoView setImage:[UIImage imageNamed:@"tuto2"]];
        self.tutoView.imageForTuto2 = shape;
        [self.imagePickerController.cameraOverlayView addSubview:self.tutoView];
    }
}

- (void)hideSaveandUnhideFlipButton
{
    [self.saveButton setHidden:YES];
    [self.cameraFlipButton setHidden:NO];
}

- (void)unhideSaveandHideFlipButton
{
    [self.saveButton setHidden:NO];
    [self.cameraFlipButton setHidden:YES];
}

- (void)handleCustomCameraZoom:(UIPinchGestureRecognizer *)recogniser
{
    if (recogniser.state == UIGestureRecognizerStateBegan) {
        self.referenceTransform = self.imagePickerController.cameraViewTransform;
    } else if (recogniser.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recogniser scale];
        self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.referenceTransform,scale,scale);
    }
}

// --------------------------------
// ShapeViewDelegate protocol
// --------------------------------

- (void)unhideBinButton
{
    [self.binButton setHidden:NO];
}

- (void)hideBinButton
{
    [self.binButton setHidden:YES];
}

- (void)deleteView:(ShapeView *)view ifBinContainsPoint:(CGPoint)point
{
    if (CGRectContainsPoint(self.binButton.frame,point)) {
        [view removeFromSuperview];
        [self.flexibleSubViews removeObject:view];
        self.subViewIndex --;
    }
    [self.binButton setHidden:YES];
}

- (void)sendToFrontView:(ShapeView *)view
{
    [self.imagePickerController.cameraOverlayView insertSubview:view atIndex:self.subViewIndex];
}


// --------------------------------
// Utilities
// --------------------------------

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:ACTION_SHEET_OPTION_1]) {
        // todo
        [GeneralUtilities showMessage:@"Coming soon" withTitle:nil];
    } else if ([buttonTitle isEqualToString:ACTION_SHEET_OPTION_2]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if ([buttonTitle isEqualToString:ACTION_SHEET_CANCEL]) {
        // do nothing
    } else if ([buttonTitle isEqualToString:ACTION_SHEET_OPTION_3]) {
        // Clean everything
        [self.backgroundView clearPathAndPictures];
        [self hideSaveandUnhideFlipButton];
        self.subViewIndex = 0;
        
        for(id subView in self.flexibleSubViews) {
            [(ShapeView *)subView removeFromSuperview];
        }
        self.flexibleSubViews = nil;
    } else if ([buttonTitle isEqualToString:ACTION_SHEET_OPTION_4]) {
        // Delete and return to feed
        continueToSharing = TRUE;
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
}


@end
