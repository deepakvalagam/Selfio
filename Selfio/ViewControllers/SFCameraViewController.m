//
//  SFCameraViewController.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 13/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFCameraViewController.h"
#import "GPUImage.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SFImageGalleryViewController.h"
#import "SFGalleryManager.h"
#import "UIImage+FX.h"
#import "UIImage+ImageEffects.h"
#import "SFFiltersViewController.h"
#import "SFImageData.h"
#import "SFFiltersViewController.h"

#define RADIANS_TO_DEGREES(x) (180/M_PI)*x

#define CAMERA_PREVIEW_PRESET AVCaptureSessionPresetHigh
#define CAMERA_SAVE_PRESET AVCaptureSessionPresetPhoto

#define BLUR_RADIUS 6

static int const thresholdAngle = 170;

@interface SFCameraViewController () 

@property (weak, nonatomic) IBOutlet GPUImageView *cameraPreview;
@property (weak, nonatomic) IBOutlet UIButton *tapButton;
@property (weak, nonatomic) IBOutlet UIImageView *finalImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *flipImageView;
@property (weak, nonatomic) IBOutlet UIButton *latestImageButton;

@property (nonatomic, strong) SFGalleryManager *galleryManager;

@end

@implementation SFCameraViewController
{
    GPUImageStillCamera *stillCamera;
    CMMotionManager *motionManager;
    CMAttitude *referenceAttitude;
    
    GPUImageGammaFilter *defaultFilter;
    GPUImageGaussianBlurFilter *blurFilter;
    
    BOOL didFlip;
    BOOL didCameraRotate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _galleryManager = [SFGalleryManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect viewFrame;
    viewFrame = self.view.frame;
    viewFrame.size.width = 320.0f;
    
    if (IS_IPHONE_5) {
        viewFrame.size.height = 568.0f;
    }
    else{
        viewFrame.size.height = 480.0f;
    }
    [self.view setFrame:viewFrame];
    
    
    [self.cameraPreview setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.cameraPreview setContentMode:UIViewContentModeCenter];
    
    defaultFilter = [[GPUImageGammaFilter alloc] init];
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter.blurRadiusInPixels = 1;
    
    //TODO: Tweak the quality
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:CAMERA_PREVIEW_PRESET cameraPosition:AVCaptureDevicePositionFront];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    stillCamera.jpegCompressionQuality = 0.9;
    
    [stillCamera addTarget:defaultFilter];
    [stillCamera addTarget:blurFilter];
    [blurFilter addTarget:self.cameraPreview];
    
    [stillCamera startCameraCapture];
    motionManager = [[CMMotionManager alloc] init];
    
    if (!motionManager.isDeviceMotionAvailable) {
        //FAIL
    }
    
    motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.cameraPreview setTransform:CGAffineTransformMakeScale(-1, 1)];
    
    [self startMotionUpdates];
    
    [self setupLatestImageView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateLatestThumbnailImage];
    
    [stillCamera startCameraCapture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [stillCamera stopCameraCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)setupLatestImageView
{
    [self.latestImageButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self updateLatestThumbnailImage];
    
    self.latestImageButton.layer.cornerRadius = self.latestImageButton.bounds.size.width/2;
}

- (void)startMotionUpdates
{
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        if (referenceAttitude) {
            
            CMAttitude *currentAttitude = motion.attitude;
            
            if (currentAttitude) {
                
                [currentAttitude multiplyByInverseOfAttitude:referenceAttitude];
                
                float degreesRotated = RADIANS_TO_DEGREES(currentAttitude.roll);
                
                NSString *degrees = [NSString stringWithFormat:@"%f", degreesRotated];
                
                NSLog(@"Roll : %@", degrees);
                
                if (!didCameraRotate && fabs(degreesRotated) > 90) {
                    didCameraRotate = YES;
                    
                    [stillCamera rotateCamera];
                    stillCamera.captureSessionPreset = CAMERA_SAVE_PRESET;
                    
                    blurFilter.blurRadiusInPixels = 1;
                    
                    [self.cameraPreview setTransform:CGAffineTransformMakeScale(1, 1)];
                    self.flipImageView.alpha = 0;
                }
                if (didCameraRotate && fabs(degreesRotated) < 90) {
                    didCameraRotate = NO;
                    
                    [stillCamera rotateCamera];
                    stillCamera.captureSessionPreset = CAMERA_PREVIEW_PRESET;
                    
                    blurFilter.blurRadiusInPixels = BLUR_RADIUS;
                    
                    [self.cameraPreview setTransform:CGAffineTransformMakeScale(-1, 1)];
                    self.flipImageView.alpha = 1;
                }
                
                //TODO: Restrict pitch and Yaw, Auto Focus, Accelerometer
                
                if (!didFlip && fabs(degreesRotated) > thresholdAngle) {
                    
                    didFlip = YES;
                    
                    [motionManager stopDeviceMotionUpdates];
                    NSLog(@"STOPPED");
                    
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [stillCamera capturePhotoAsJPEGProcessedUpToFilter:defaultFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
                            
                            UIImage *jpegImage = [UIImage imageWithData:processedJPEG];
                            
                            self.galleryManager.photo = [[SFImageData alloc] initWithImage:jpegImage andMetadata:stillCamera.currentCaptureMetadata];
                            
                            self.galleryManager.lowResPhoto = [jpegImage imageScaledToFitSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
                            
                            runOnMainQueueWithoutDeadlocking(^{
                                
                                self.finalImageView.image = self.galleryManager.lowResPhoto;
                                
                                [self showImage];
                            });
                            
                            
                            NSLog(@"DONE");
                            
                        }];
                        
                    });
                }
            }
        }
        
    }];
    
}

- (void)showImage
{
//    [stillCamera removeAllTargets];
//    [stillCamera stopCameraCapture];
    
    blurFilter.blurRadiusInPixels = BLUR_RADIUS;
    
    self.view.userInteractionEnabled = YES;
    self.containerView.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.alpha = 1;
    }];
    
//    self.cameraPreview.hidden = YES;
    self.tapButton.hidden = YES;
    
    stillCamera.captureSessionPreset = CAMERA_PREVIEW_PRESET;
    [stillCamera rotateCamera];
    [self.cameraPreview setTransform:CGAffineTransformMakeScale(-1, 1)];
}

- (void)updateLatestThumbnailImage
{
    UIImage *latestImage = [_galleryManager latestImage];
    
    if (latestImage) {
        [_latestImageButton setImage:latestImage forState:UIControlStateNormal];
    }
}

- (void)resetView
{
    self.tapButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tapButton.alpha = 1;
    }];
    
    self.cameraPreview.hidden = NO;
    [self.cameraPreview setTransform:CGAffineTransformMakeScale(-1, 1)];
    
    self.view.userInteractionEnabled = YES;
    
//    stillCamera.captureSessionPreset = CAMERA_PREVIEW_PRESET;
//    [stillCamera rotateCamera];
//    [stillCamera addTarget:blurFilter];
//    [blurFilter addTarget:self.cameraPreview];
//    [stillCamera startCameraCapture];
}

- (void)resetValues
{
    blurFilter.blurRadiusInPixels = 1;
    
    referenceAttitude = nil;
    didFlip = NO;
    didCameraRotate = NO;
    
    [self startMotionUpdates];
}

#pragma mark - Selectors

- (void)orientationChanged:(NSNotification *)info
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    NSLog(@"Orientation - %ld", deviceOrientation);
    
    CGFloat finalAngle;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            finalAngle = 0;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            finalAngle = M_PI_2;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            finalAngle = -M_PI_2;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            finalAngle = M_PI;
        }
            break;
            
        default:
        {
            finalAngle = 0;
        }
            break;
    }
    
    [self rotateViewsByAngle:finalAngle];
}

- (void)rotateViewsByAngle:(CGFloat)angle
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tapButton setTransform:CGAffineTransformMakeRotation(angle)];
        [self.flipImageView setTransform:CGAffineTransformMakeRotation(angle)];
        [self.latestImageButton setTransform:CGAffineTransformMakeRotation(angle)];
    }];
}

#pragma mark - Button Actions

- (IBAction)buttonTapped:(id)sender
{
    //Blur
    blurFilter.blurRadiusInPixels = BLUR_RADIUS;
    
    //Take Reference attitude
    referenceAttitude = motionManager.deviceMotion.attitude;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tapButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.flipImageView.alpha = 1;
        }];
    }];
    
    self.view.userInteractionEnabled = NO;
}

- (IBAction)noTapped:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.alpha = 0;
    } completion:^(BOOL finished) {
        self.containerView.hidden = YES;
    }];
    
    [self resetView];
    
    [self resetValues];
}

- (IBAction)yesTapped:(id)sender
{
    SFFiltersViewController *filtersViewController = [[SFFiltersViewController alloc] initWithNibName:@"SFFiltersViewController" bundle:nil];
    
    [self.navigationController presentViewController:filtersViewController animated:NO completion:^{
        self.containerView.alpha = 0;
        self.containerView.hidden = YES;
        
        [self resetView];
        
        [self resetValues];
    }];
}

- (IBAction)galleryTapped:(id)sender
{
    SFImageGalleryViewController *imageGalleryViewController = [[SFImageGalleryViewController alloc] initWithNibName:@"SFImageGalleryViewController" bundle:nil];
    
    [self.navigationController presentViewController:imageGalleryViewController animated:YES completion:^{
        
    }];
}

@end
