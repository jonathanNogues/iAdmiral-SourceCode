//
//  MoveCommand.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Commands.h"

/**************************** MOVE COMMAND ****************************/
@implementation MoveCommand

@synthesize _move;

- (id) initWithCommandType:(MoveCommandType) mct
{
	self = [super init];
	
	_move = mct;
	
	return self;
}

- (NSString *) description
{
	switch (_move)
	{
		case MoveCommand_TurnLeft:
			return @"TL";
			
		case MoveCommand_TurnRight:
			return @"TR";
			
		case MoveCommand_MoveAhead:
			return @"GO";
			
		default:
			return @"??";
	}
}

@end

/**************************** FIGHT COMMAND ****************************/
@implementation FightCommand

@synthesize _Target;

- (id) initWithTarget:(Ship *) targ
{
	self = [super init];
	_Target = targ;
	
	return self;
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"Fire at %@", _Target];
}

- (void) dealloc
{
	[super dealloc];
	_Target = nil;
}

@end
