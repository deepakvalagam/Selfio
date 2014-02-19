//
//  SFGalleryManager.h
//  Selfio
//
//  Created by Ramsundar Shandilya on 15/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

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

+ (instancetype)sharedManager;

- (NSInteger)photosCount;

- (UIImage *)imageAtIndex:(NSInteger)index imageType:(SFImageType)type;

- (UIImage *)latestImage;

- (void)saveImagetoAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata completionBlock:(void(^)())completionBlock;

@end
