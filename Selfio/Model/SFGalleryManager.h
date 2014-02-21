//
//  SFGalleryManager.h
//  Selfio
//
//  Created by Ramsundar Shandilya on 15/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SFImageData.h"

#define GALLERY_NAME @"Selfio"

typedef enum {
    SFImageTypeThumbnail,
    SFImageTypeScreenResolution,
    SFImageTypeFullResolution
}SFImageType;

@interface SFGalleryManager : NSObject

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetPhotos;
@property (nonatomic) BOOL displayLatestPhotoFirst;

/*Latest photo taken */
@property (nonatomic, strong) SFImageData *photo;

@property (nonatomic, strong) UIImage *lowResPhoto;

+ (instancetype)sharedManager;

- (NSInteger)photosCount;

- (UIImage *)imageAtIndex:(NSInteger)index imageType:(SFImageType)type;

- (UIImage *)latestImage;

- (void)saveImagetoAlbumWithCompletionBlock:(void(^)())completionBlock;

- (void)flushData;

@end
