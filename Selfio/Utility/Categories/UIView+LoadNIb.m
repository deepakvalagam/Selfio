//
//  UIView+LoadNIb.m
//  IntroToLetters
//
//  Created by Ramsundar Shandilya on 15/10/13.
//  Copyright (c) 2013 Ramsundar Shandilya. All rights reserved.
//

#import "UIView+LoadNIb.h"

@implementation UIView (LoadNIb)

+ (id)loadInstanceFromNib
{
    UIView *result = nil;
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            result = anObject;
            break;
        }
    }
    return result;
}

+ (id)loadInstanceFromNibWithOwner:(id)owner
{
    UIView *result = nil;
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:owner options:nil];
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            result = anObject;
            break;
        }
    }
    return result;
}

@end
  