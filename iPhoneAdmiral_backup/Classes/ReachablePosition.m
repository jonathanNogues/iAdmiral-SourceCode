//
//  ReachablePosition.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReachablePosition.h"
#import "Hex.h"
#import "Ship.h"
#import "Commands.h"
#import "PositionAIHints.h"
#import "HexBoard.h"

@implementation ReachablePosition

@synthesize _WayToGetToDestination, _MPLeftAtDestination, _TPLeftAtDestination, _NTurnsAtDestination,
            _CourseAtDestination, _Destination, _PositionAIHints, _PreviousPositions;

- (id) initWithPosition:(ReachablePosition *) prev_pos
				command:(MoveCommand *) mc
{
	return [self initWithPosition: prev_pos
						  command: mc
						 moveCost: 1];
}


- (id) initWithPosition:(ReachablePosition *) prev_pos
				command:(MoveCommand *) mc
			   moveCost:(int) mp_cost
{
	self = [super init];
	
	//copy required movecommands
	_WayToGetToDestination = [[NSMutableArray alloc] initWithArray: prev_pos._WayToGetToDestination];
	[_WayToGetToDestination addObject: mc];
	
	//copy previous positions list
	_PreviousPositions = [[NSMutableArray alloc] initWithArray: prev_pos._PreviousPositions];
	[_PreviousPositions addObject: prev_pos];
	
	//calculate this position's values
	switch (mc._move)
	{
		case MoveCommand_TurnLeft:	
			_Destination = prev_pos._Destination;
			_MPLeftAtDestination = prev_pos._MPLeftAtDestination - mp_cost;
			_TPLeftAtDestination = prev_pos._TPLeftAtDestination - 1;
            _NTurnsAtDestination = prev_pos._NTurnsAtDestination + 1;

			if (prev_pos._CourseAtDestination != LEFT) _CourseAtDestination = prev_pos._CourseAtDestination - 1;
			else _CourseAtDestination = LEFT_DOWN;
			break;
			
		case MoveCommand_TurnRight:
			_Destination = prev_pos._Destination;
			_MPLeftAtDestination = prev_pos._MPLeftAtDestination - mp_cost;
			_TPLeftAtDestination = prev_pos._TPLeftAtDestination - 1;
            _NTurnsAtDestination = prev_pos._NTurnsAtDestination + 1;
			
            _CourseAtDestination = prev_pos._CourseAtDestination + 1;
			if (_CourseAtDestination > 5) _CourseAtDestination = 0;
			break;
			
		case MoveCommand_MoveAhead:
			_Destination = [prev_pos._Destination GetHexNeighbourAtDirection:prev_pos._CourseAtDestination];
			_MPLeftAtDestination = prev_pos._MPLeftAtDestination - mp_cost;
            _NTurnsAtDestination = prev_pos._NTurnsAtDestination - 1;
			_TPLeftAtDestination = prev_pos._TPLeftAtDestination;
			_CourseAtDestination = prev_pos._CourseAtDestination;
			break;
	}
	
	// __COPY__ ai hint values
	_PositionAIHints = [[PositionAIHints alloc] initWithHexHints: _Destination._AIValues];
	
	return self;
}

/* initialize with ship - this is to be called at the start of calculating reachable positions */
- (id) initWithShip:(Ship *) ship
{
	self = [super init];
	
	_Destination = ship._CurrentHex;	
	_MPLeftAtDestination = ship._MovePointsLeft;
	_TPLeftAtDestination = ship._TurnPointsLeft;
    _NTurnsAtDestination = ship._NTurnsMade;
	_CourseAtDestination = ship._Course;
	
	_WayToGetToDestination = [[NSMutableArray alloc] initWithCapacity:5];
	_PreviousPositions = [[NSMutableArray alloc] initWithCapacity:5];
	
	// __COPY__ ai hint values
	_PositionAIHints = [[PositionAIHints alloc] initWithHexHints: _Destination._AIValues];
	
	return self;
}

				/***************
				 *	UTILITIES  *
				 ***************/

- (NSComparisonResult) compare: (ReachablePosition *) aPos
{
	if (self._Destination._HexID > aPos._Destination._HexID) return NSOrderedDescending;
	
	if (self._Destination._HexID < aPos._Destination._HexID) return NSOrderedAscending;
	
	//if we're here, then hexIDs must match
	
	if (self._CourseAtDestination > aPos._CourseAtDestination) return NSOrderedDescending;

	if (self._CourseAtDestination < aPos._CourseAtDestination) return NSOrderedAscending;
	
	return NSOrderedSame;
}

- (NSString *) description
{
	return 	[NSString stringWithFormat: @"<%2d|%@> ", _Destination._HexID, courseToString(_CourseAtDestination) ];
}

- (void) dealloc
{
	[super dealloc];
	
	_Destination = nil;
	
	[_PositionAIHints release];
	[_WayToGetToDestination release];
	[_PreviousPositions release];
}


@end
