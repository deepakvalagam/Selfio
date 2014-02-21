//
//  SFImageData.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 20/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFImageData.h"

@implementation SFImageData

- (id)initWithImage:(UIImage *)image andMetadata:(NSDictionary *)metadata
{
    self = [super init];
    if (self) {
        _image = image;
        _metaData = [[NSMutableDictionary alloc] initWithDictionary:metadata];
    }
    return self;
}
@end
