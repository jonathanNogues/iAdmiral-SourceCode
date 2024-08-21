//
//  HitAnimSubview.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ship;

@interface HitAnimSubview : UIView 
{
    NSMutableArray * _Clouds;
    
    NSRange _CloudRange;
}

/* init with default values */
- (id) initWithDefaultFrame;

/* places the clouds at appropriate positions */
- (void) prepareWithShip:(Ship *) victim;

/* performs the prepared animation */
- (void) performAnimation;

/* fades out the clouds */
- (void) animFinished:(NSString *)animationID
             finished:(NSNumber *)finished
              context:(void *)context;

@end
