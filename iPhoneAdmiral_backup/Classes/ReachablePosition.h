//
//  ReachablePosition.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class Hex;
@class MoveCommand;
@class Ship;
@class PositionAIHints;
@class HexBoard;

@interface ReachablePosition : NSObject {
	Hex * _Destination;
	
	HexDirection _CourseAtDestination;
	
	int _TPLeftAtDestination;
	int _MPLeftAtDestination;
    int _NTurnsAtDestination;
	
	NSMutableArray * _WayToGetToDestination;	//list of movecommands that allow to reach the position
	NSMutableArray * _PreviousPositions;		//list of all positions visited prior to this one
	
	PositionAIHints * _PositionAIHints;
}
@property (nonatomic, readonly) Hex * _Destination;
@property (nonatomic, readonly) HexDirection _CourseAtDestination;
@property (nonatomic, readonly) int _TPLeftAtDestination;
@property (nonatomic, readonly) int _MPLeftAtDestination;
@property (nonatomic, readonly) int _NTurnsAtDestination;

@property (nonatomic, readonly) NSMutableArray * _WayToGetToDestination;
@property (nonatomic, readonly) NSMutableArray * _PreviousPositions;

@property (nonatomic, readonly) PositionAIHints * _PositionAIHints;

/* initialize by making a single move command from previous position */
- (id) initWithPosition:(ReachablePosition *) prev_pos
				command:(MoveCommand *) mc;

/* initialize by making a single move command from previous position, with specified move cost */
- (id) initWithPosition:(ReachablePosition *) prev_pos
				command:(MoveCommand *) mc
			   moveCost:(int) mp_cost;

/* initialize with ship - this is to be called at the start of calculating reachable positions */
- (id) initWithShip:(Ship *) ship;

/* comparator selector, for sorting */
- (NSComparisonResult) compare: (ReachablePosition *) aPos;

@end
