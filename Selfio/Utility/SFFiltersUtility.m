//
//  SFFiltersUtility.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 21/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFFiltersUtility.h"

@implementation SFFiltersUtility

+ (GPUImageFilter *)filterWithType:(SFFilterType)filterType
{
    GPUImageFilter *filter = nil;
    
    switch (filterType) {
        case SFFilterTypeApple:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Apple.acv"];
        }
            break;
        case SFFilterTypeBanana:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Banana.acv"];
        }
            break;
        case SFFilterTypeGrapes:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Grapes.acv"];
        }
            break;
        case SFFilterTypeLemon:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Lemon.acv"];
        }
            break;
        case SFFilterTypeMango:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Mango.acv"];
        }
            break;
        case SFFilterTypeOrange:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Orange.acv"];
        }
            break;
        case SFFilterTypeWatermelon:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Watermelon.acv"];
        }
            break;
            
        default:
            break;
    }
    
    return filter;
}

@end
