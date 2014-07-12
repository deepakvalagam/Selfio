//
//  UITableView+CellAnimation.h
//  IntroToLetters
//
//  Created by Ramsundar Shandilya on 13/11/13.
//  Copyright (c) 2013 Ramsundar Shandilya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    UITableViewAnimationDirectionFromLeft,
    UITableViewAnimationDirectionFromRight
}UITableViewAnimationDirection;

@interface UITableView (CellAnimation)

- (void)animateRowsFromLeft;
- (void)animateRowsFromRight;

@end
