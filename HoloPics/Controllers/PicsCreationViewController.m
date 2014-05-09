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
#import "holoImageView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>
#import "flexibleImageView.h"
#import "TutoImageView.h"
#import "ShareViewController.h"
#import "MBProgressHUD.h"
#import "Holopic.h"

#define ACTION_SHEET_OPTION_1 NSLocalizedStringFromTable (@"photo_bank", @"Strings", @"comment")
#define ACTION_SHEET_OPTION_2 NSLocalizedStringFromTable (@"photo_library", @"Strings", @"comment")
#define ACTION_SHEET_CANCEL NSLocalizedStringFromTable (@"cancel", @"Strings", @"comment")

@interface PicsCreationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *binButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlipButton;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (weak, nonatomic) IBOutlet holoImageView *holoImageView;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!continueToSharing) {
        // Present the camera
        [self presentViewController:self.imagePickerController animated:NO completion:NULL];

        // Make this controller the delegate of holoImageView
        self.holoImageView.holoImageViewDelegate = self;

        // On first opening of the app
        if (self.firstOpening)
        {
            self.tutoView = [[TutoImageView alloc] initWithFrame:self.view.bounds];
            self.tutoView.image = [UIImage imageNamed:@"tuto1.png"];
            [self.imagePickerController.cameraOverlayView addSubview:self.tutoView];
        }
    } else {
        continueToSharing = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;

    if ([segueName isEqualToString: @"Share From Create Push Segue"]) {
        ((ShareViewController *) [segue destinationViewController]).imageToShare = (UIImage *)sender;
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
    self.holoImageView.fullImage = [ImageUtilities imageWithImage:[ImageUtilities cropImage:image toFitWidthOnHeightTargetRatio:targetRatio andOrientate:orientation] scaledToSize:self.holoImageView.bounds.size];

    [self.holoImageView setImage:self.holoImageView.fullImage];
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
    
    // Remove border around flexibleimageviews
    for (flexibleImageView *views in self.flexibleSubViews){
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
    
    // Share to FB, sms, email.. using UIActivityViewController
//    NSString *shareString = @"";
//    NSArray *activityItems = [NSArray arrayWithObjects:shareString, imageToShare, nil];
//    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop];
//    [self.imagePickerController presentViewController:activityViewController animated:YES completion:nil];
    
    
//    [GeneralUtilities showMessage:@"Image saved" withTitle:nil];
//    [self saveImageToFileSystem:[ImageUtilities imageFromView:self.imagePickerController.cameraOverlayView]];
//    if (![GeneralUtilities connected]) {
//        [GeneralUtilities showMessage:NSLocalizedStringFromTable (@"no_connection", @"Strings", @"comment") withTitle:nil];
//    } else {
//        NSString *imageName = [[GeneralUtilities getDeviceID] stringByAppendingFormat:@"--%lu", (unsigned long)[GeneralUtilities currentDateInMilliseconds]];
//        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
//        [s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:S3_BUCKET]];
//        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:imageName inBucket:S3_BUCKET];
//        por.contentType = @"image/jpeg";
//        NSData *imageData = UIImageJPEGRepresentation (self.holoImageView.fullImage, 0.8);
//        por.data = imageData;
//        [s3 putObject:por];
//        [self cancelButtonClicked:nil];
//    }
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
    continueToSharing = TRUE;
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

// --------------------------------
// holoImageViewDelegate protocol
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
    
    [actionSheet showInView:self.holoImageView];
}

// Create flexible subview with the image inside the path
- (void)createFlexibleSubView
{
    if (!self.flexibleSubViews){
        self.flexibleSubViews = [NSMutableArray arrayWithCapacity:1];
    }
    
    // Return if we reached the limit of images
    if (self.subViewIndex > kMaxNumberOfFlexibleImage) {
        [GeneralUtilities showMessage:@"You reached the maximum number of pics!" withTitle:nil];
        return;
    }
        
    flexibleImageView *flexibleImage = [[flexibleImageView alloc] initWithImage:self.holoImageView.fullImage andPath:self.holoImageView.globalPath];
    flexibleImage.flexibaleImageViewDelegate = self;
    [self.flexibleSubViews addObject:flexibleImage];
    
    // Add this subview to cameraOverlayView (before buttons)
    self.subViewIndex ++;
    [self.imagePickerController.cameraOverlayView insertSubview:flexibleImage atIndex:self.subViewIndex];
    
    if (self.firstOpening) {
        flexibleImage.backgroundColor = [UIColor blackColor];
        self.firstOpening = NO;
        [self.tutoView setImage:[UIImage imageNamed:@"tuto2"]];
        self.tutoView.imageForTuto2 = flexibleImage;
        [self.imagePickerController.cameraOverlayView addSubview:self.tutoView];
    } else {
        flexibleImage.center = CGPointMake(flexibleImage.center.x + 5, flexibleImage.center.y + 5);
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
// flexibleImageView protocol
// --------------------------------

- (void)unhideBinButton
{
    [self.binButton setHidden:NO];
}

- (void)hideBinButton
{
    [self.binButton setHidden:YES];
}

- (void)deleteView:(flexibleImageView *)view ifBinContainsPoint:(CGPoint)point
{
    if (CGRectContainsPoint(self.binButton.frame,point)) {
        [view removeFromSuperview];
        [self.flexibleSubViews removeObject:view];
        self.subViewIndex --;
    }
    [self.binButton setHidden:YES];
}

- (void)sendToFrontView:(flexibleImageView *)view
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
    }
}


@end
