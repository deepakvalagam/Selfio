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

#define RADIANS_TO_DEGREES(x) (180/M_PI)*x

static int const thresholdAngle = 170;

@interface SFCameraViewController ()

@property (weak, nonatomic) IBOutlet GPUImageView *cameraPreview;
@property (weak, nonatomic) IBOutlet UIButton *tapButton;
@property (weak, nonatomic) IBOutlet UIImageView *finalImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *flipLabel;
@property (weak, nonatomic) IBOutlet UIButton *latestImageButton;

@property (nonatomic, strong) SFGalleryManager *galleryManager;

@end

@implementation SFCameraViewController
{
    GPUImageStillCamera *stillCamera;
    
    CMMotionManager *motionManager;
    CMAttitude *referenceAttitude;
    
    GPUImageGammaFilter *defaultFilter;
    BOOL didFlip;
    BOOL didCameraRotate;
    
    NSData *finalImageData;
    NSDictionary *finalImageMetaData;
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
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [stillCamera addTarget:self.cameraPreview];
    [stillCamera rotateCamera];
    stillCamera.jpegCompressionQuality = 0.9;
    [stillCamera startCameraCapture];
    
    defaultFilter = [[GPUImageGammaFilter alloc] init];
    [stillCamera addTarget:defaultFilter];
    
    motionManager = [[CMMotionManager alloc] init];
    
    if (!motionManager.isDeviceMotionAvailable) {
        //FAIL
    }
    
    motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.cameraPreview setTransform:CGAffineTransformMakeScale(-1, 1)];
    
    [self startMotionUpdates];
    
    [_latestImageButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self updateLatestThumbnailImage];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateLatestThumbnailImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

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
                    [self.cameraPreview setTransform:CGAffineTransformMakeScale(1, 1)];
                    self.flipLabel.alpha = 0;
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
                            
                            finalImageData = processedJPEG;
                            finalImageMetaData = stillCamera.currentCaptureMetadata;
                            
                            self.finalImageView.image = [UIImage imageWithData:processedJPEG];
                            
                            [self showImage];
                            
                            NSLog(@"DONE");
                            
                        }];
                        
                    });
                }
            }
        }
        
    }];
    
}

- (void)playBeep
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"beep--attention" ofType:@"aif"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

- (void)showImage
{
    self.view.userInteractionEnabled = YES;
    self.containerView.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.alpha = 1;
    }];
    
    self.cameraPreview.hidden = YES;
    self.tapButton.hidden = YES;
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
    
    
    [stillCamera rotateCamera];
}

- (void)resetValues
{
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
    
    //TODO: Rotate the view Controls
    
}


#pragma mark - Button Actions

- (IBAction)buttonTapped:(id)sender
{
    
    referenceAttitude = motionManager.deviceMotion.attitude;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tapButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.flipLabel.alpha = 1;
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
    [_galleryManager saveImagetoAlbum:finalImageData metadata:finalImageMetaData completionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.2 animations:^{
                self.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                self.containerView.hidden = YES;
            }];
            
            [self resetView];
            
            [self updateLatestThumbnailImage];
        });
        
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
