//
//  AITargetData.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AITargetData.h"


@implementation AITargetData

@synthesize _Target, _Distance, _FiringArc;

- (id) initWithShip:(Ship *)targ Distance:(int)dist
{
    self = [super init];
    
    _Target = targ;
    _Distance = dist;
    
    return self;
}

- (void) dealloc
{
    //nothing to do here
    
    [super dealloc];
}

@end
