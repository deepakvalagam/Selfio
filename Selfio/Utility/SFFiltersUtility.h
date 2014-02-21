//
//  SFFiltersUtility.h
//  Selfio
//
//  Created by Ramsundar Shandilya on 21/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

typedef NS_ENUM(NSInteger, SFFilterType) {
    SFFilterTypeApple,
    SFFilterTypeBanana,
    SFFilterTypeGrapes,
    SFFilterTypeLemon,
    SFFilterTypeMango,
    SFFilterTypeOrange,
    SFFilterTypeWatermelon
};

@interface SFFiltersUtility : NSObject

+ (GPUImageFilter *)filterWithType:(SFFilterType)filterType;

@end
