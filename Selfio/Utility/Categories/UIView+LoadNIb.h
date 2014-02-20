//
//  UIView+LoadNIb.h
//  IntroToLetters
//
//  Created by Ramsundar Shandilya on 15/10/13.
//  Copyright (c) 2013 Ramsundar Shandilya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoadNIb)

+ (id)loadInstanceFromNib;
+ (id)loadInstanceFromNibWithOwner:(id)owner;

@end
