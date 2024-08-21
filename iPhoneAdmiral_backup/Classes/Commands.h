//
//  MoveCommand.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ship;

/**************************** MOVE COMMAND ****************************/
typedef enum
{
	MoveCommand_TurnLeft,
	MoveCommand_TurnRight,
	MoveCommand_MoveAhead,
} MoveCommandType;

@interface MoveCommand : NSObject
{
	MoveCommandType _move;
}

@property (nonatomic, readonly) MoveCommandType _move;

- (id) initWithCommandType:(MoveCommandType) mct;

@end


/**************************** FIGHT COMMAND ****************************/
@interface FightCommand : NSObject
{
	Ship * _Target;
}

@property (nonatomic, readonly) Ship * _Target;

- (id) initWithTarget:(Ship *) targ;

@end