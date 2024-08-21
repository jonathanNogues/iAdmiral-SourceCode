//
//  AStarNode.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface AStarNode : NSObject 
{
    int _HexID;
    int _ParentHexID;
    
    int _Gcost;
    int _Hcost;
    
    HexDirection _DirectionInNode;
}

@property (nonatomic, assign) int _HexID;
@property (nonatomic, assign) int _ParentHexID;
@property (nonatomic, assign) HexDirection _DirectionInNode;

@property (nonatomic, assign) int _Gcost;
@property (nonatomic, assign) int _Hcost;

//fakes
@property (nonatomic, readonly) int _Fcost;
@property (nonatomic, readonly) NSNumber * _Key;

- (id) initWithHID:(int) hid
              pHID:(int) phid
             gCost:(int) gc
             hCost:(int) hc
         direction:(HexDirection) dir;

@end
