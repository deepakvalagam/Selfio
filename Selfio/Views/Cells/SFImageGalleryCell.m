//
//  SFImageGalleryCell.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 15/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFImageGalleryCell.h"

@implementation SFImageGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSString *)reuseIdentifier
{
    return IMAGE_GALLERY_CELL_IDENTIFIER;
}

@end
