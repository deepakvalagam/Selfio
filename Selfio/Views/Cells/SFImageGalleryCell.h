//
//  SFImageGalleryCell.h
//  Selfio
//
//  Created by Ramsundar Shandilya on 15/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_GALLERY_CELL_IDENTIFIER   @"ImageGalleryCell"

@interface SFImageGalleryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@end
