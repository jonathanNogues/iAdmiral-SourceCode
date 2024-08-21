//
//  ShootingAnimSubview.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class Ship;

@interface ShootingAnimSubview : UIView {
    NSMutableArray * _Clouds;
        
    NSRange _CloudRange;
}

/* the default setup method */
- (id) initWithDefaultFrame;

/* prepares appropriate number of clouds at their starting positions*/
- (void) prepareWithShip:(Ship *) striker
               firingArc:(FiringArc) firearc;

/* performs the prepared animation */
- (void) performAnimation;

/* fades out the clouds */
- (void) shootingFinished:(NSString *)animationID
				 finished:(NSNumber *)finished
				  context:(void *)context;

@end
