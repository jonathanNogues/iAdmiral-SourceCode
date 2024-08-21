//
//  FireAnimSubview.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface FireAnimSubview : UIView {

    NSArray * _FiresOnBoard;
    
}

//initialize with ship
- (id) initWithCourse:(HexDirection) course
                 Size:(FireSize) size;

//update to new fire size
- (void) updateToFireSize:(FireSize) newsize;

//zap all animations
- (void) stopAnimating;

@end
