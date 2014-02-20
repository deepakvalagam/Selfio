//
//  SFImageData.m
//  Selfio
//
//  Created by Ramsundar Shandilya on 20/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import "SFImageData.h"

@implementation SFImageData

- (id)initWithJpegData:(NSData *)data andMetadata:(NSDictionary *)metadata
{
    self = [super init];
    if (self) {
        _jpegData = [[NSData alloc] initWithData:data];
        _metaData = [[NSMutableDictionary alloc] initWithDictionary:metadata];
    }
    return self;
}
@end
