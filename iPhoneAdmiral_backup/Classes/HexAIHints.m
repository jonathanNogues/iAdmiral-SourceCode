//
//  AIValues.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HexAIHints.h"

#import "Ship.h"

//globally used constant values
const int AIHint_FoM_Radius = 3;
const int AIHint_FirepowerMax_Radius = 7;

@implementation HexAIHints;

@synthesize _AIHintValues;
//@synthesize _ShipsAtCloseRange, _ShipsAtLongRange;
@synthesize _ShipsInRange;

- (id) init
{
	self = [super init];
	
	_AIHintValues = [[NSMutableArray alloc] initWithCapacity: AIHintsMAX];
	
	for (int i = 0; i < AIHintsMAX; i++)
	{
		[_AIHintValues insertObject: [NSNumber numberWithInt:0]
							atIndex: i];
	}
		
    _ShipsInRange = [[NSMutableArray alloc] initWithCapacity: 8];
	
	return self;
}

/* reset non permanet hints */
- (void) zeroNonPermanentHints
{
	[_AIHintValues replaceObjectAtIndex: AIHint_EnemyFirepower
							 withObject: [NSNumber numberWithInt: 0]];

	[_AIHintValues replaceObjectAtIndex: AIHint_EnemyBoardingStrength
							 withObject: [NSNumber numberWithInt: 0]];
	
	[_AIHintValues replaceObjectAtIndex: AIHint_WindPosition
							 withObject: [NSNumber numberWithInt: 0]];

	[_AIHintValues replaceObjectAtIndex: AIHint_DistanceToNearestEnemy
							 withObject: [NSNumber numberWithInt: 0]];

    [_ShipsInRange removeAllObjects];
}



- (id) copyWithZone:(NSZone *) zone
{
	HexAIHints * hint_copy = [[HexAIHints allocWithZone: zone] init];
	
	hint_copy._AIHintValues = [_AIHintValues mutableCopy];
	//hint_copy._ShipsAtCloseRange = [_ShipsAtCloseRange mutableCopy];
	//hint_copy._ShipsAtLongRange = [_ShipsAtLongRange mutableCopy];
    
    hint_copy._ShipsInRange = [_ShipsInRange mutableCopy];
	
	return hint_copy;
}

- (void) dealloc
{
	[super dealloc];
	
	[_AIHintValues release];
    
    //memleak is better than outright crash right?
	//[_ShipsAtCloseRange removeAllObjects];
	//[_ShipsAtCloseRange release];
	//[_ShipsAtLongRange removeAllObjects];
	//[_ShipsAtLongRange release];
}

@end
