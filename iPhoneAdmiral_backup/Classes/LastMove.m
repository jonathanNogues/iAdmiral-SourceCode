//
//  LastMove.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LastMove.h"
#import "Ship.h"
#import "Hex.h"

@implementation LastMove

@synthesize _ship, _MPCost, _NTurns, _originalHex, _originalCourse;

- (Ship *) undoMove
{
	//check for movement
	if (_ship._CurrentHex._HexID != _originalHex._HexID)
	{
		NSLog(@"Returning ship to original hex!");
		_ship._CurrentHex._ShipInHex = nil;
		_originalHex._ShipInHex = _ship;
		_ship._CurrentHex = _originalHex;
		
		_ship._MovePointsLeft += _MPCost;
        _ship._NTurnsMade = _NTurns;
		_ship._FinishedMove = NO;
	}
	else	//no movement, so there must have been some turning
	{
		NSLog(@"Undoing last course change!\n");
		_ship._Course = _originalCourse;

        _ship._NTurnsMade = _NTurns;
		_ship._MovePointsLeft += 1;
		_ship._TurnPointsLeft += 1;
		_ship._FinishedMove = NO;
	}
	
	
	return _ship;
}


@end
