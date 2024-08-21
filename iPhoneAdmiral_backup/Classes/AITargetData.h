//
//  AITargetData.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"

@class Ship;


@interface AITargetData : NSObject {
    Ship *      _Target;
    int         _Distance;
    FiringArc   _FiringArc;
}

@property (nonatomic, readonly) Ship *  _Target;
@property (nonatomic, readonly) int     _Distance;
@property (nonatomic, assign) FiringArc _FiringArc;

- (id) initWithShip:(Ship *) targ
           Distance:(int) dist;

@end
