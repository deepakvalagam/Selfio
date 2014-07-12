//
//  SFGalleryManager.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 15/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFGalleryManager.h"

@interface SFGalleryManager ()

@property (nonatomic, strong) NSMutableArray *assetGroups;

@end

@implementation SFGalleryManager

#pragma mark - Init

+ (instancetype)sharedManager
{
    static SFGalleryManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SFGalleryManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        _displayLatestPhotoFirst = YES;
        
        [self populatePhotos];
    }
    return self;
}

#pragma mark - Private Methods

- (void)assetGroupsList:(void (^)(NSArray *assetGroups))assetGroups
{
    if (_assetGroups == nil) {
        _assetGroups = [[NSMutableArray alloc] init];
    }
    
    [_assetGroups removeAllObjects];
    
    
    void (^assetsGroupEnumertator)(ALAssetsGroup *, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        if (group == nil)
        {
            // end of enumeration
            assetGroups(_assetGroups);
            return;
        }
        
        [_assetGroups addObject:group];
    };
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        NSLog(@"Error : %@", [error description]);
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetsGroupEnumertator failureBlock:failureBlock];

}

- (void)assetPhotosForGroup:(ALAssetsGroup *)assetGroup result:(void (^)(NSArray *assetPhotos))assetPhotos
{
    if (_assetPhotos == nil) {
        _assetPhotos = [[NSMutableArray alloc] init];
    }
    
    [_assetPhotos removeAllObjects];
    
    [assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    [assetGroup enumerateAssetsUsingBlock:^(ALAsset *photo, NSUInteger index, BOOL *stop) {
        
        if(photo == nil)
        {
            if (_displayLatestPhotoFirst) {
                _assetPhotos = [[NSMutableArray alloc] initWithArray:[[_assetPhotos reverseObjectEnumerator] allObjects]];
            }

            assetPhotos(_assetPhotos);
            return;
        }
        [_assetPhotos addObject:photo];
    }];
}

- (void)populatePhotos
{
   [self assetGroupsList:^(NSArray *assetGroups) {
       
       for (ALAssetsGroup *assetGroup in assetGroups) {
           if ([[assetGroup valueForProperty:ALAssetsGroupPropertyName] isEqualToString:GALLERY_NAME]) {
               [self assetPhotosForGroup:assetGroup result:^(NSArray *assetPhotos) {
                   
               }];
           }
       }
   }];
   
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName  completionBlock:(void(^)())completionBlock
{
    BOOL didFindGroup;
    
    for (ALAssetsGroup *assetGroup in self.assetGroups) {
        if ([[assetGroup valueForProperty:ALAssetsGroupPropertyName] isEqualToString:GALLERY_NAME]) {
            didFindGroup = YES;
            
            [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                
                [assetGroup addAsset:asset];
                [self.assetPhotos insertObject:asset atIndex:0];
                //[self populatePhotos];
                
                completionBlock();
            
            } failureBlock:^(NSError *error) {
                NSLog(@"Error : %@", error.localizedDescription);
            }];
            
        }
    }
    
    __weak SFGalleryManager *weakSelf = self;
    
    if (!didFindGroup) {
        
        [self.assetsLibrary addAssetsGroupAlbumWithName:GALLERY_NAME resultBlock:^(ALAssetsGroup *group) {
            
            [weakSelf.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                
                [group addAsset:asset];
                
                [weakSelf.assetPhotos insertObject:asset atIndex:0];
//                [weakSelf populatePhotos];
                completionBlock();
                
            } failureBlock:^(NSError *error) {
                NSLog(@"Error : %@", error.localizedDescription);
            }];
            
        } failureBlock:nil];
    }
}

#pragma mark - Public Methods

- (NSInteger)photosCount
{
    return self.assetPhotos.count;
}

- (UIImage *)imageAtIndex:(NSInteger)index imageType:(SFImageType)type
{
    UIImage *photoImage = nil;
    
    if (_assetPhotos) {
        ALAsset *photoAsset = [_assetPhotos objectAtIndex:index];
        
        if (photoAsset) {
            
            ALAssetRepresentation *assetRepresentation = [photoAsset defaultRepresentation];
            
            switch (type) {
                case SFImageTypeThumbnail:
                    photoImage = [UIImage imageWithCGImage:photoAsset.thumbnail];
                    break;
                    
                case SFImageTypeScreenResolution:
                    photoImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]];
                    break;
                    
                case SFImageTypeFullResolution:
                    photoImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]];
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    return photoImage;
}

- (UIImage *)latestImage
{
    return [self imageAtIndex:0 imageType:SFImageTypeThumbnail];
}

- (void)saveImageWithFilter:(SFFilterType)filterType :(UIImage*)tosave toAlbumWithCompletionBlock:(void (^)())completionBlock
{
    GPUImageFilter *filter = [SFFiltersUtility filterWithType:filterType];
    
    
    
    UIImage *resultImage = [filter imageByFilteringImage:tosave];
    
    __weak SFGalleryManager *weakSelf = self;
    
    /*[self.assetsLibrary writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(resultImage, 0.9) metadata:self.photo.metaData completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [self addAssetURL:assetURL toAlbum:GALLERY_NAME completionBlock:^{
            completionBlock();
            [weakSelf flushData];
        }]
     
    }];*/
    [self.assetsLibrary writeImageToSavedPhotosAlbum: resultImage.CGImage orientation:resultImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error)
     {
         //[self addAssetURL:assetURL toAlbum:GALLERY_NAME completionBlock:^{
             completionBlock();
             [weakSelf flushData];
          //}];
     }];
}

- (void)flushData
{
    self.photo = nil;
    self.lowResPhoto = nil;
}

@end
