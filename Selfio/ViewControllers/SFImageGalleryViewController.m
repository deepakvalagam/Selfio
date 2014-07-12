//
//  SFImageGalleryViewController.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 15/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFImageGalleryViewController.h"
#import "SFImageGalleryCell.h"
#import "SFGalleryManager.h"
#import "SFImageGalleryCell.h"

@interface SFImageGalleryViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) SFGalleryManager *galleryManager;

@end

@implementation SFImageGalleryViewController

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
    
    UINib *imageGalleryCell = [UINib nibWithNibName:@"SFImageGalleryCell" bundle:nil];
    
    [self.photosCollectionView registerNib:imageGalleryCell forCellWithReuseIdentifier:@"ImageGalleryCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self.galleryManager photosCount];
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFImageGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IMAGE_GALLERY_CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.photoImageView.image = [self.galleryManager imageAtIndex:indexPath.row imageType:SFImageTypeThumbnail];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(104, 104);
}

#pragma mark -  Button Actions

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
