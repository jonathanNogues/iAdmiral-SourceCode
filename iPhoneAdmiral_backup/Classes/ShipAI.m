//
//  ShipAI.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShipAI.h"

#import "Ship.h"
#import "HexBoard.h"
#import "MapView.h"

#import "ReachablePosition.h"
#import "Commands.h"

#import "HexAIHints.h"
#import "PositionAIHints.h"

@implementation ShipAI

@synthesize _PrimaryTarget;
@synthesize _FriendlySquadron;
@synthesize _MyType;
@synthesize _MyShip;

@synthesize _BestWarpath;
@synthesize _BestWarpathValue;
@synthesize _AStarBlocked;

- (id) init
{
	self = [super init];
	
	_BestWarpath = [[NSMutableArray alloc] initWithCapacity: 7];
	_BestWarpathValue = -9999;

	_ReachablePositionsSet = nil;
	
	_FriendlySquadron = [[NSMutableArray alloc] initWithCapacity: 3];	
	
	return self;
}

- (id) initWithShip:(Ship *) ship
			 AIType:(AIType) ait
		   hexBoard:(HexBoard *) hb
		   pMapView:(MapView *) pmap
{
	self = [self init];
	
	_MyShip = ship;
	_MyType = ait;
	_HexBoard = hb;
	_pMapView = pmap;
	
	return self;
}

/* get set of reachable positions */
- (void) getAndEvaluateReachablePositions
{
	//reset the best warpath (should be empty anyways)?
    //[_BestWarpath makeObjectsPerformSelector:@selector(release)];
	[_BestWarpath removeAllObjects];
	_BestWarpathValue = -9999;

	//release the old set
	[_ReachablePositionsSet release];

	//get the new set
	_ReachablePositionsSet = [_HexBoard getReachablePositionsSetForShip: _MyShip];
	
	NSLog(@"Reachable Positions Set for %@: ", _MyShip);
	
	//prepare target information for evaluation, but only if this ship still has guns
    if (_MyShip._Guns > 0)
    {
        for (ReachablePosition * rp in [_ReachablePositionsSet allObjects])
        {
            //create dummy
            Ship * dummy = [[Ship alloc] init];
            [dummy set_ID:			SHIP_DUMMY_ID];
            [dummy set_Course:		rp._CourseAtDestination];
            [dummy set_CurrentHex:	rp._Destination];
            [dummy set_IAmFort:     _MyShip._IAmFort];
            
            //calculate targets
            [rp._PositionAIHints assignTargetsToFiringArcsUsing: _HexBoard
                                                       andDummy: dummy];
            
            //evaluate targets
            [rp._PositionAIHints evaluateTargetsUsingShip: _MyShip];
            
            //get rid of dummy
            [dummy release];
            
            //NSLog(@"%@", rp);
        }
    }
    else
    {
        NSLog(@"%@ has no guns, therefore no targets.", _MyShip);
    }

	//NSLog(@" * * * * * * * * * * * * * * * * * * * * * * * *");
	
	//find and remember the best warpath
	//for (ReachablePosition * rp in [[_ReachablePositionsSet allObjects] sortedArrayUsingSelector:@selector(compare:)])
    for (ReachablePosition * rp in [_ReachablePositionsSet allObjects])
	{
		/*
		 finding best PATH is now straightforward:
		 //calculate safety / maneuverability value of hex at position
		 //calculate best left arc engagement value for whole path
		 //calculate best right arc engagement value for whole path
		 //sum and choose the highest
		 
		 */
		
		//treat THIS position as best...
		int destination_value = 0;	
		destination_value = [rp._PositionAIHints calculatePositionValueForShip: _MyShip
																	 andAIType: _MyType];
		
		int best_larc_eng_value =	rp._PositionAIHints._BestLeftArcTargetValue;
		int best_rarc_eng_value =	rp._PositionAIHints._BestRightArcTargetValue;
		Ship * best_larc_target =	rp._PositionAIHints._BestLeftArcTarget;
		Ship * best_rarc_target =	rp._PositionAIHints._BestRightArcTarget;
		int pos_to_fire_left    =	[rp._PreviousPositions count];
		int pos_to_fire_right   =	[rp._PreviousPositions count];
		
		for (ReachablePosition * iter in rp._PreviousPositions)
		{
			if (iter._PositionAIHints._BestLeftArcTargetValue > best_larc_eng_value)
			{
				best_larc_eng_value = iter._PositionAIHints._BestLeftArcTargetValue;
				best_larc_target = iter._PositionAIHints._BestLeftArcTarget;
				pos_to_fire_left = [rp._PreviousPositions indexOfObject: iter];
			}
			
			if (iter._PositionAIHints._BestRightArcTargetValue > best_rarc_eng_value)
			{
				best_rarc_eng_value = iter._PositionAIHints._BestRightArcTargetValue;
				best_rarc_target = iter._PositionAIHints._BestRightArcTarget;
				pos_to_fire_right = [rp._PreviousPositions indexOfObject: iter];
				
			}
		}//(rp._PreviousPositions iteration)
		
		FightCommand * fire_left = nil;
		FightCommand * fire_right = nil;
		
		NSMutableArray * warpath = [[NSMutableArray alloc] initWithArray: rp._WayToGetToDestination];
		
		if (best_larc_target != nil && !_MyShip._FiredLeft) 
		{
			fire_left = [[FightCommand alloc] initWithTarget: best_larc_target];
			[warpath insertObject: fire_left
						  atIndex: pos_to_fire_left];
		}
		
		//the positions calculated, do not take into account the fact that adding first fire command may affect
		//the position of second fire command in the warpath
		if (fire_left != nil && best_rarc_target != nil && pos_to_fire_left < pos_to_fire_right) pos_to_fire_right++;
		
		if (best_rarc_target != nil && !_MyShip._FiredRight)
		{
			fire_right = [[FightCommand alloc] initWithTarget: best_rarc_target];
			[warpath insertObject: fire_right
						  atIndex: pos_to_fire_right];
		}
		
		int sum_values = destination_value + best_larc_eng_value + best_rarc_eng_value;
		
		NSMutableString * warpath_string = [[NSMutableString alloc] initWithFormat:@"%@[%4d] (%3d+%2d+%2d) ",
											rp, sum_values,
											destination_value, best_larc_eng_value, best_rarc_eng_value];
		
        //probable mem leak
        //[fire_left release];
        //[fire_right release];
        
		for (id com in warpath) [warpath_string appendFormat:@"%@ ", com];
		NSLog(@"%@", warpath_string);
		[warpath_string release];
		
		if (sum_values > _BestWarpathValue)
		{
			_BestWarpath = [warpath retain];
			_BestWarpathValue = sum_values;
		}
        
        [warpath release];
	}
	
	//best warpath
	NSLog(@" * * * * * * * * * * * * * * * * * * * * * * * *");
	NSLog(@"Best warpath for %@", _MyShip);
    
	NSMutableString * best_warpath_string = [[NSMutableString alloc] initWithFormat:@"[%4d] : ", _BestWarpathValue];
	for (id com in _BestWarpath) [best_warpath_string appendFormat:@"%@ ", com];
	NSLog(@"%@", best_warpath_string);
	[best_warpath_string release];
	
	NSLog(@" * * * * * * * * * * * * * * * * * * * * * * * *");
	
}

- (void) calculatePathTowardsTarget
{
    //if we have no AStarPath stored, we need to generate new one
    if (_AStarPathThisTurn == nil)
    {
        //get array of hexes than need to be traversed from here to destination
        NSArray * AStarPath = [_HexBoard getAStarPathFromHex: _MyShip._CurrentHex
                                                       toHex: _PrimaryTarget._CurrentHex
                                                     bigShip: _MyShip._BigShip 
                                              courseAtOrigin: _MyShip._Course];
        
        //however, a ship can olny travel so far each turn
        NSRange turn_range = {0, _MyShip._MovePointsLeft};
        
        //so get only hexes that can be theoretically reached this turn
        _AStarPathThisTurn = [AStarPath subarrayWithRange: turn_range];
        [_AStarPathThisTurn retain];
    }
    
    //clear warpath of any remaining move commands
    //memory warning!
    [_BestWarpath removeAllObjects];
    
    //translate recieved path to a warpath
    _AStarBlocked = [_HexBoard transformAStarPath: _AStarPathThisTurn
                                        toWarpath: _BestWarpath
                                          forShip: _MyShip];
    
    //if path is blocked, we should check if it is blocked by an
    //immobilized or seriously slower (MP diff >= 2) ship
    //if so, we should try to calculate path around it
    
#ifdef NON_RELEASE
    NSLog(@"***********");
    NSLog(@"Warpath: ");
    for (MoveCommand * mc in _BestWarpath) NSLog(@"%@", mc);
    
    if (_AStarBlocked) NSLog(@"Warpath is BLOCKED!");
    else NSLog(@"Warpath is CLEAR!");
#endif
    
    //grade the warpath, if not blocked give it the highest score, else base it on warpath length
    if (_AStarBlocked) _BestWarpathValue = [_BestWarpath count] * 10;
    else _BestWarpathValue = 100;
}

- (void) trimAStarPath
{
    //this gets called after a part of AStarPath was travelled.    
    NSUInteger index_of_current_hex = [ _AStarPathThisTurn indexOfObject: _MyShip._CurrentHex._HexIDObject ];

    NSLog(@"AStar before trim:");
    for (NSNumber * num in _AStarPathThisTurn) NSLog(@"Hex: %d", [num intValue]);

    //nothing to trim
    if (index_of_current_hex == NSNotFound) return;
    
    NSRange new_range = {index_of_current_hex + 1, [_AStarPathThisTurn count] - (index_of_current_hex + 1)};
    
    NSLog(@"Current Hex (%d) found at index %d.",_MyShip._CurrentHex._HexID, index_of_current_hex);
    
    _AStarPathThisTurn = [_AStarPathThisTurn subarrayWithRange:new_range];
    [_AStarPathThisTurn retain];
    
    NSLog(@"AStar after trim:");
    for (NSNumber * num in _AStarPathThisTurn) NSLog(@"Hex: %d", [num intValue]);
}

- (void) clearSavedPath
{
    [_AStarPathThisTurn release];
    _AStarPathThisTurn = nil;
}


- (bool) isWarpathSane
{
	return (_BestWarpath.count > 0);
}

- (NSComparisonResult) compareWarpathValues: (ShipAI *) otherAI
{
    if (otherAI._BestWarpathValue > _BestWarpathValue) return NSOrderedAscending;
    
    if (otherAI._BestWarpathValue < _BestWarpathValue) return NSOrderedDescending;
    
    return NSOrderedSame;
}


/* checks if the ship is ready to perform moves this turn */
- (bool) canMakeAMove
{
	//check if the ship is afloat
	if (_MyShip._HitPointsLeft <= 0) return NO;

	//check if the ship ain't engaged in boarding
	if (_MyShip._EngagedInBoarding) return NO;
	
	//seems ok
	return YES;
}

- (void) dealloc
{
	NSLog(@"WARNING: ShipAI is being dealloc'd!");
	_MyShip = nil;
	_HexBoard = nil;
    _pMapView = nil;
	
	[_FriendlySquadron release];
	[_BestWarpath release];
	[_ReachablePositionsSet release];
	
	[super dealloc];
	
	NSLog(@"ShipAI dealloc ok!");
}

@end
