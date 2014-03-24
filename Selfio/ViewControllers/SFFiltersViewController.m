//
//  SFFiltersViewController.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 20/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFFiltersViewController.h"
#import "UIImage+ImageEffects.h"
#import "SFFiltersUtility.h"
#import "SFGalleryManager.h"

#define BUTTON_TAG_INDEX 100

@interface SFFiltersViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredPhotoImageView;

@property (weak, nonatomic) IBOutlet UIButton *leftTopButton;
@property (weak, nonatomic) IBOutlet UIButton *leftMidButton;
@property (weak, nonatomic) IBOutlet UIButton *leftBottomButton;

@property (weak, nonatomic) IBOutlet UIButton *rightTopButton;
@property (weak, nonatomic) IBOutlet UIButton *rightMidButton;
@property (weak, nonatomic) IBOutlet UIButton *rightBottomButton;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)filterTapped:(UIButton *)sender;

@end

@implementation SFFiltersViewController
{
    CGSize viewSize;
    
    CGPoint leftTopButtonOriginalPos;
    CGPoint leftTopButtonHiddenPos;
    
    CGPoint leftMidButtonOriginalPos;
    CGPoint leftMidButtonHiddenPos;
    
    CGPoint leftBottomButtonOriginalPos;
    CGPoint leftBottomButtonHiddenPos;
    
    CGPoint rightTopButtonOriginalPos;
    CGPoint rightTopButtonHiddenPos;
    
    CGPoint rightMidButtonOriginalPos;
    CGPoint rightMidButtonHiddenPos;
    
    CGPoint rightBottomButtonOriginalPos;
    CGPoint rightBottomButtonHiddenPos;
    
    CGPoint saveButtonOriginalPos;
    CGPoint saveButtonHiddenPos;
    
    BOOL filtersHidden;
    
    SFGalleryManager *galleryManager;
    SFFilterType selectedFilter;
}

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        galleryManager = [SFGalleryManager sharedManager];
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
    
    viewSize = self.view.frame.size;
    
    self.photoImageView.image = galleryManager.lowResPhoto;
    
    self.blurredPhotoImageView.image = [galleryManager.lowResPhoto applyDarkEffect];
    
}

- (void)viewDidLayoutSubviews
{
    [self arrangeButtons];
    
    saveButtonOriginalPos = CGPointMake(viewSize.width/2, viewSize.height - (0.6 * self.saveButton.frame.size.height));
    saveButtonHiddenPos = CGPointMake(viewSize.width/2, viewSize.height+self.saveButton.frame.size.height);
                                      
    self.saveButton.center = saveButtonHiddenPos;
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.3 animations:^{
        self.blurredPhotoImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [self animateButtonsIn];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)arrangeButtons
{
    CGFloat leftX = viewSize.width * (1/3.0);
    CGFloat rightX = viewSize.width * (2/3.0);
    
    CGFloat reducedHeight = (viewSize.height - (1.3 * self.saveButton.frame.size.height));
    
    CGFloat topY = reducedHeight * (1/4.0);
    CGFloat midY = reducedHeight * (2/4.0);
    CGFloat bottomY = reducedHeight * (3/4.0);
    
    leftTopButtonOriginalPos = CGPointMake(leftX, topY);
    leftTopButtonHiddenPos = [self hiddenPointForPoint:leftTopButtonOriginalPos];
    self.leftTopButton.center = leftTopButtonHiddenPos;
    
    leftMidButtonOriginalPos = CGPointMake(leftX, midY);
    leftMidButtonHiddenPos = [self hiddenPointForPoint:leftMidButtonOriginalPos];
    self.leftMidButton.center = leftMidButtonHiddenPos;
    
    leftBottomButtonOriginalPos = CGPointMake(leftX, bottomY);
    leftBottomButtonHiddenPos = [self hiddenPointForPoint:leftBottomButtonOriginalPos];
    self.leftBottomButton.center = leftBottomButtonHiddenPos;
    
    rightTopButtonOriginalPos = CGPointMake(rightX, topY);
    rightTopButtonHiddenPos = [self hiddenPointForPoint:rightTopButtonOriginalPos];
    self.rightTopButton.center = rightTopButtonHiddenPos;
    
    rightMidButtonOriginalPos = CGPointMake(rightX, midY);
    rightMidButtonHiddenPos = [self hiddenPointForPoint:rightMidButtonOriginalPos];
    self.rightMidButton.center = rightMidButtonHiddenPos;
    
    rightBottomButtonOriginalPos = CGPointMake(rightX, bottomY);
    rightBottomButtonHiddenPos = [self hiddenPointForPoint:rightBottomButtonOriginalPos];
    self.rightBottomButton.center = rightBottomButtonHiddenPos;
    
}

- (CGPoint)hiddenPointForPoint:(CGPoint)point
{
    CGFloat reducedHeight = (viewSize.height - (1.2 * self.saveButton.frame.size.height));
    
    CGPoint diff = CGPointMake(point.x - viewSize.width/2, point.y - reducedHeight/2);
    float multiplier = 3;
    CGPoint hiddenPoint = CGPointMake(point.x + multiplier * diff.x, point.y + multiplier * diff.y);
    
    return hiddenPoint;
}

- (CGPoint)overShootForHiddedPoint:(CGPoint)hiddenPoint andOriginalPoint:(CGPoint)originalPoint
{
    int overShootFactor = 10;
    CGPoint overshoot = CGPointMake((originalPoint.x - hiddenPoint.x)/overShootFactor, (originalPoint.y - hiddenPoint.y)/overShootFactor);
    overshoot = CGPointMake(overshoot.x + originalPoint.x, overshoot.y + originalPoint.y);
    return overshoot;
}

- (void)animateButtonsIn
{
    float animationDuration = 0.2;
    float overshootDuration = 0.1;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.leftTopButton.center = [self overShootForHiddedPoint:leftTopButtonHiddenPos andOriginalPoint:leftTopButtonOriginalPos];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:overshootDuration animations:^{
            self.leftTopButton.center = leftTopButtonOriginalPos;
        }];
    }];
    
    [UIView animateWithDuration:animationDuration delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.leftMidButton.center = [self overShootForHiddedPoint:leftMidButtonHiddenPos andOriginalPoint:leftMidButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:overshootDuration animations:^{
            self.leftMidButton.center = leftMidButtonOriginalPos;
        }];
        
    }];
    
    [UIView animateWithDuration:animationDuration delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.leftBottomButton.center = [self overShootForHiddedPoint:leftBottomButtonHiddenPos andOriginalPoint:leftBottomButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:overshootDuration animations:^{
            self.leftBottomButton.center = leftBottomButtonOriginalPos;
        }];
        
    }];
    
    //--------------
    
    [UIView animateWithDuration:animationDuration delay:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.rightTopButton.center = [self overShootForHiddedPoint:rightTopButtonHiddenPos andOriginalPoint:rightTopButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:overshootDuration animations:^{
            self.rightTopButton.center = rightTopButtonOriginalPos;
        }];
        
    }];
    
    [UIView animateWithDuration:animationDuration delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.rightMidButton.center = [self overShootForHiddedPoint:rightMidButtonHiddenPos andOriginalPoint:rightMidButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:overshootDuration animations:^{
            self.rightMidButton.center = rightMidButtonOriginalPos;
        }];
        
    }];
    
    [UIView animateWithDuration:animationDuration delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.rightBottomButton.center = [self overShootForHiddedPoint:rightBottomButtonHiddenPos andOriginalPoint:rightBottomButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:overshootDuration animations:^{
            self.rightBottomButton.center = rightBottomButtonOriginalPos;
        }];
        
    }];
    
    
    //-------------
    //Save Button
    
    [UIView animateWithDuration:overshootDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.saveButton.center = [self overShootForHiddedPoint:saveButtonHiddenPos andOriginalPoint:saveButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.saveButton.center = saveButtonHiddenPos;
        }];
        
    }];
    
}

- (void)animateButtonsOut
{
    float animationDuration = 0.2;
    float overshootDuration = 0.1;
    
    [UIView animateWithDuration:overshootDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.leftTopButton.center = [self overShootForHiddedPoint:leftTopButtonHiddenPos andOriginalPoint:leftTopButtonOriginalPos];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:animationDuration animations:^{
            self.leftTopButton.center = leftTopButtonHiddenPos;
        }];
    }];
    
    [UIView animateWithDuration:overshootDuration delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.leftMidButton.center = [self overShootForHiddedPoint:leftMidButtonHiddenPos andOriginalPoint:leftMidButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.leftMidButton.center = leftMidButtonHiddenPos;
        }];
        
    }];
    
    [UIView animateWithDuration:overshootDuration delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.leftBottomButton.center = [self overShootForHiddedPoint:leftBottomButtonHiddenPos andOriginalPoint:leftBottomButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.leftBottomButton.center = leftBottomButtonHiddenPos;
        }];
        
    }];
    
    //--------------
    
    [UIView animateWithDuration:overshootDuration delay:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.rightTopButton.center = [self overShootForHiddedPoint:rightTopButtonHiddenPos andOriginalPoint:rightTopButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.rightTopButton.center = rightTopButtonHiddenPos;
        }];
        
    }];
    
    [UIView animateWithDuration:overshootDuration delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.rightMidButton.center = [self overShootForHiddedPoint:rightMidButtonHiddenPos andOriginalPoint:rightMidButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.rightMidButton.center = rightMidButtonHiddenPos;
        }];
        
    }];
    
    [UIView animateWithDuration:overshootDuration delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.rightBottomButton.center = [self overShootForHiddedPoint:rightBottomButtonHiddenPos andOriginalPoint:rightBottomButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.rightBottomButton.center = rightBottomButtonHiddenPos;
        }];
        
    }];
    
    //-------------
    //Save Button
    
    [UIView animateWithDuration:animationDuration delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.saveButton.center = [self overShootForHiddedPoint:saveButtonHiddenPos andOriginalPoint:saveButtonOriginalPos];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:overshootDuration animations:^{
            self.saveButton.center = saveButtonOriginalPos;
        }];
        
    }];
    
}

#pragma mark - IBActions

- (IBAction)imageTapped:(id)sender
{
    if (filtersHidden) {
        [self animateButtonsIn];
        [UIView animateWithDuration:0.3 animations:^{
            self.blurredPhotoImageView.alpha = 1;
        }];
    }
    else{
        [self animateButtonsOut];
        [UIView animateWithDuration:0.3 animations:^{
            self.blurredPhotoImageView.alpha = 0;
        }];
    }
    
    filtersHidden = !filtersHidden;
}


- (IBAction)filterTapped:(UIButton *)sender
{
    selectedFilter = sender.tag - BUTTON_TAG_INDEX;
    
    GPUImageFilter *filter = [SFFiltersUtility filterWithType:selectedFilter];
    
    UIImage *newImage = [filter imageByFilteringImage:galleryManager.lowResPhoto];
    self.photoImageView.image = newImage;
    
    UIImage *blurredImage = [newImage applyDarkEffect];
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
        self.blurredPhotoImageView.image = blurredImage;
    } completion:^(BOOL finished) {
        
        [self animateButtonsOut];
        filtersHidden = !filtersHidden;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.blurredPhotoImageView.alpha = 0;
        }];
    }];
    
}

- (IBAction)savePhoto:(id)sender {
    
    [self.spinner startAnimating];
    
    [galleryManager saveImageWithFilter:selectedFilter toAlbumWithCompletionBlock:^{
        
        [self.spinner stopAnimating];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
@end
