//
//  AStarNode.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AStarNode.h"


@implementation AStarNode

@synthesize _HexID, _ParentHexID;
@synthesize _DirectionInNode;

@synthesize _Hcost, _Gcost;

//fake properites
- (int) _Fcost
{
    return _Hcost + _Gcost;
}

- (NSNumber *) _Key
{
    return [NSNumber numberWithInt:_HexID];
}

//end of fake properties

- (id) initWithHID:(int) hid
              pHID:(int) phid
             gCost:(int) gc
             hCost:(int) hc
         direction:(HexDirection) dir
{
    self = [super init];
    
    _HexID = hid;
    _ParentHexID = phid;
    _Gcost = gc;
    _Hcost = hc;
    _DirectionInNode = dir;
    
    return self;
}

@end
