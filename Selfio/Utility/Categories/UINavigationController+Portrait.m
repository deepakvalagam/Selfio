//
//  UINavigationController+Portrait.m
//  IntroToLetters
//
//  Created by Ramsundar Shandilya on 14/11/13.
//  Copyright (c) 2013 Ramsundar Shandilya. All rights reserved.
//

#import "UINavigationController+Portrait.h"

@implementation UINavigationController (Portrait)

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
