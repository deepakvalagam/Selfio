//
//  SFImageData.h
//  Selfio
//
//  Created by Ramsundar Shandilya on 20/02/14.
//  Copyright (c) 2014 Ruggers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFImageData : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSMutableDictionary *metaData;

- (id)initWithImage:(UIImage *)image andMetadata:(NSDictionary *)metadata;

@end
