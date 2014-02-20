//
//  UILabel+Resize.m
//  IntroToLetters
//
//  Created by Ramsundar Shandilya on 24/12/13.
//  Copyright (c) 2013 Ramsundar Shandilya. All rights reserved.
//

#import "UILabel+Resize.h"

@implementation UILabel (Resize)

- (CGFloat)resizeToFit
{
    CGFloat expectedHeight = [self expectedHeight];
    
    CGRect newFrame = self.frame;
    newFrame.size.height = expectedHeight;
    
    [self setFrame:newFrame];
    return expectedHeight;
}

- (CGFloat)expectedHeight
{
    
    CGFloat expectedLabelHeight;
    
    [self sizeToFit];
    
    [self setNumberOfLines:0];
    
    CGSize maxSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    CGSize requiredSize = [self sizeThatFits:maxSize];
    expectedLabelHeight = requiredSize.height;
        
    return ceilf(expectedLabelHeight);
}

@end
