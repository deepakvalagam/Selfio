//
//  UITableView+CellAnimation.m
//  IntroToLetters
//
//  Created by Ramsundar Shandilya on 13/11/13.
//  Copyright (c) 2013 Ramsundar Shandilya. All rights reserved.
//

#import "UITableView+CellAnimation.h"

@implementation UITableView (CellAnimation)

- (void)animateRowsFromLeft
{
    [self animateRowsFromDirection:UITableViewAnimationDirectionFromLeft];
}

- (void)animateRowsFromRight
{
    [self animateRowsFromDirection:UITableViewAnimationDirectionFromRight];
}

-(void)animateRowsFromDirection:(UITableViewAnimationDirection)direction{
    
    self.layer.masksToBounds = NO;
    
    CGFloat xOffset = 1.5 * ((direction == UITableViewAnimationDirectionFromLeft) ? -self.frame.size.width : self.frame.size.width);
    CGFloat overShoot = (direction == UITableViewAnimationDirectionFromLeft) ? -self.frame.size.width/8 : self.frame.size.width/8;

    for (int i = 0; i < self.visibleCells.count; i++) {
        UITableViewCell *cell = [self.visibleCells objectAtIndex:i];
        
        cell.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, xOffset, 0);
    }
    
    
    
    for (int i = 0; i < self.visibleCells.count; i++) {
        UITableViewCell *cell = [self.visibleCells objectAtIndex:i];
        
        float delay = (float)i/20.0f;
        
        [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
            cell.transform = CGAffineTransformTranslate(cell.transform, -xOffset - overShoot, 0);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.transform = CGAffineTransformTranslate(cell.transform, overShoot, 0);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    
    [self performSelector:@selector(animationCompleted) withObject:nil afterDelay:0.7];
}

- (void)animationCompleted
{
//    self.layer.masksToBounds = YES;
}

@end
