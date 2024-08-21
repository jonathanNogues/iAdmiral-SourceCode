//
//  SplashAnimSuview.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ship;

@interface SplashAnimSubview : UIView {
    NSMutableArray * _Splashes;
    
    NSRange _SplashRange;
}

/* init with default values */
- (id) initWithDefaultFrame;

/* places the splashes at appropriate positions */
- (void) prepareWithShip:(Ship *) victim
            andFirepower:(int) firepow;

/* performs the prepared animation */
- (void) performAnimation;

/* fades out the splashes */
- (void) animFinished:(NSString *)animationID
             finished:(NSNumber *)finished
              context:(void *)context;

@end
