//
//  PersonalAIHints.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PositionAIHints.h"
#import "HexBoard.h"
#import "Ship.h"
#import "ShipAI.h"
#import "Common.h"
#import "AIDefines.h"
#import "AITargetData.h"

@implementation PositionAIHints

@synthesize _ShipsInRightFiringArc, _ShipsInLeftFiringArc;
@synthesize _BestLeftArcTarget, _BestRightArcTarget;
@synthesize _BestLeftArcTargetValue, _BestRightArcTargetValue;

- (id) initWithHexHints:(HexAIHints *) aih
{
	//self super = [aih copy];
	//self = [super init];
	
	//first, lets copy our papa
	self._AIHintValues = [aih._AIHintValues mutableCopy];  
    self._ShipsInRange = [aih._ShipsInRange mutableCopy];
	
	_ShipsInLeftFiringArc = 0;
	_ShipsInRightFiringArc = 0;

	_BestLeftArcTarget = nil;
	_BestRightArcTarget = nil;
	
	_BestLeftArcTargetValue = 0;
	_BestRightArcTargetValue = 0;
	
	return self;
}

- (void) assignTargetsToFiringArcsUsing:(HexBoard *) hb
							   andDummy:(Ship *) dummy
{
	//if entering this pos means boarding (AIHint_EnemyBoardingStrength < 0) no targets are to be had
    //this is not the case for forts, however
	if ([[_AIHintValues objectAtIndex:AIHint_EnemyBoardingStrength] intValue] != 0 && !dummy._IAmFort)
	{
        //this will fuck up if both ships end up with equal boarding strength
		NSLog(@"Hex %d, no targets due to boarding!", dummy._CurrentHex._HexID);
		return;
	}
	
	//check if some targets are available
    if ([_ShipsInRange count] <= 0) return;
    
    //assign targets to firing arcs
	for (AITargetData * target_data in _ShipsInRange)
	{
		FiringArc arc = [hb checkFiringArcForShip: dummy
											ToRow: target_data._Target._CurrentHex._Row
										 HexInRow: target_data._Target._CurrentHex._HexInRow ];
        
        //if distance is 1, shooting can only occur if either the shooter or the target is a fort
        if ( target_data._Distance == 1 && !( dummy._IAmFort || target_data._Target._IAmFort ) )
            target_data._FiringArc = ArcNone;
        else
            target_data._FiringArc = arc;

    }
}

- (void) evaluateTargetsUsingShip:(Ship *) ship
{
    //evaluate all targets and pick best for each arc
    for (AITargetData * target_data in _ShipsInRange)
    {
        //calculate this target's engagement value
        int engagement_value = [self calculateSingleEngagementValueForShip: ship
                                                                 andVictim: target_data._Target
                                                                  distance: target_data._Distance ];

        //now let's check its firing arc
        if (target_data._FiringArc == ArcLeft)
        {
            //previous best enagement value in this arc
			int cev = [[_AIHintValues objectAtIndex: AIHint_LeftArcEngagementValueMAX] intValue];
			
            //if this one is better, remember it
			if (engagement_value > cev)
			{
				[_AIHintValues replaceObjectAtIndex: AIHint_LeftArcEngagementValueMAX
										 withObject: [NSNumber numberWithInt: engagement_value] ];
                
				
				_BestLeftArcTarget = target_data._Target;
				_BestLeftArcTargetValue = engagement_value;
			}
            
            //increase count of targets in left arc
            _ShipsInLeftFiringArc++;
            
        }

        if (target_data._FiringArc == ArcRight)
        {
            //previous best enagement value in this arc
            int cev = [[_AIHintValues objectAtIndex: AIHint_RightArcEngagementValueMAX] intValue];
			
            //if this one is better, remember it
			if (engagement_value > cev)
			{
				[_AIHintValues replaceObjectAtIndex: AIHint_RightArcEngagementValueMAX
										 withObject: [NSNumber numberWithInt: engagement_value] ];
                
				_BestRightArcTarget = target_data._Target;
				_BestRightArcTargetValue = engagement_value;
			}

            //increase count of targets in right arc
            _ShipsInRightFiringArc++;
        }
    }
}

- (int) calculateSingleEngagementValueForShip:(Ship *) striker
									andVictim:(Ship *) victim
                                     distance:(int) distance;
{
	int engagement_value = 0;
	
	//bonus for a ship just being there
	engagement_value += AI_ENG_VALUE_BASE_BONUS;
    
    //calculate own firepower vs target
    engagement_value += normalizedFirePowerValue(striker._Guns, distance, AmmoRoundShot);
	
	//bonus if ship is of the same class
	if (striker._Class == victim._Class)
		engagement_value += AI_ENG_VALUE_CLASS_MATCH_BONUS;
	
	//small bonus if ship is of higher class
	if (striker._Class + 1 == victim._Class)
		engagement_value += AI_ENG_VALUE_HIGHER_CLASS_BONUS;
	
	//big bonus if ship is severly damadged (hp <= 50%)
	if (victim._HitPointsLeft <= victim._HitPoints / 2)
		engagement_value += AI_ENG_VALUE_DMG_BONUS;
	
	//another big bonus if ship is critically damadged (hp <= 25%)
	if (victim._HitPointsLeft <= victim._HitPoints / 4)
		engagement_value += AI_ENG_VALUE_HVY_DMG_BONUS;
	
	//another bonus if ship is just barely above the water (hp == 1)
	if (victim._HitPointsLeft == 1)
		engagement_value += AI_ENG_VALUE_CRIT_DMG_BONUS;
	
	//huge penalty if the ship is engaged in boarding with friendly ship
	if (victim._EngagedInBoarding)
		engagement_value -= AI_ENG_VALUE_BOARDING_PENALTY;
	
	//penalty for firing at pickets from capital ships
	if (victim._Class == ClassPicket && striker._Class == ClassCapital)
		engagement_value -= AI_ENG_VALUE_SOL_ON_SMALL_PENALTY;
	    
    //small bonus for firing on flagship
    if (victim._IAmFlagship)
        engagement_value += AI_ENG_VALUE_FLAGSHIP_BONUS;
    
    //huge bonus for firing on cargoship
    if (victim._IAmCargoShip)
        engagement_value += AI_ENG_VALUE_CARGOSHIP_BONUS;
	
	return engagement_value;		
}

//this will be a function of ShipAI
- (int) calculatePositionValueForShip:(Ship *) ship
							andAIType:(AIType) ait
{
	int retval = 0;

	switch(ait)
	{
        case AIType_Sentinel:
            retval += [[_AIHintValues objectAtIndex:AIHint_StrategicallyIportantHex] intValue];
            
            //FALLTHROUGH, because the rest should be the same!
        
        case AIType_Aggressive:
        case AIType_Coward:
		case AIType_Normal:
		{
			//substract proper maneuverability penalty
			if (ship._BigShip)
				retval += [[_AIHintValues objectAtIndex:AIHint_FreedomOfManeuver_BigShip] intValue];
			else
				retval += [[_AIHintValues objectAtIndex:AIHint_FreedomOfManeuver] intValue];
			
			//calculate firepower hint
			int enemy_firepower = [[_AIHintValues objectAtIndex:AIHint_EnemyFirepower] intValue];
			
			//we can ignore some of the enemy firepower, based upon our health
			int ignore_value = (ship._HitPointsLeft / 4) * 10;
			
			//this can be further increased if AI is aggressive
			if (ait == AIType_Aggressive) ignore_value = ignore_value * AI_POS_VALUE_AGGR_AI_IGNORE_MOD;
			if (ait == AIType_Coward) ignore_value = ignore_value * AI_POS_VALUE_COWARD_AI_IGNORE_MOD;
			
			if (enemy_firepower + ignore_value < 0) enemy_firepower += ignore_value;
			else enemy_firepower = 0;
			
			retval += enemy_firepower;
			
			//include boarding
			int boarding_hint = [[_AIHintValues objectAtIndex:AIHint_EnemyBoardingStrength] intValue];
			
			//if boarding possible (boarding_hint < 0) then calculate our own strength
			if (boarding_hint != 0) 
			{
				//(hint value is < 0 so we just add our strength)
				boarding_hint = boarding_hint + normalizedBoardingStrength(ship);
				//NSLog(@"Final boarding hint value for %d = %d", _Destination._HexID, boarding_hint);
				retval += boarding_hint;
			}
			
			//include ships in sight count, to discourage the AI from pointless turning
			retval += _ShipsInLeftFiringArc + _ShipsInRightFiringArc;
			
			//provide small bonuses if the position enables the continued engagement of best targets
			//if ([_ShipsInRightFiringArc containsObject:_BestRightArcTarget]) retval += AI_POS_VALUE_BEST_TARGET_IN_F_ARC;
			//if ([_ShipsInLeftFiringArc containsObject:_BestLeftArcTarget]) retval += AI_POS_VALUE_BEST_TARGET_IN_F_ARC;
			
			//include wind positions
			
			//include friendly ships nearby
		}//AITYPE NORMAL
			break;
			
		case AIType_HunterSeeker:
		{
            //The job of hunter seeker AI is to get into engagement distance (7 hexes) to nearest enemy, then switch to BATTLE mode
            int distance = [[_AIHintValues objectAtIndex:AIHint_DistanceToNearestEnemy] intValue];
			retval = AI_SEEKING_DISTANCE - abs( distance - AI_FIGHTING_DISTANCE );
		}//AITYPE HUNTER SEEKER
			break;
            
        case AIType_Protective:
            NSLog(@"Not yet in place...");
            break;
			
	}//switch AITYPE
	
	return retval;
}

- (void) dealloc
{
	[super dealloc];
	
	_BestLeftArcTarget = nil;
	_BestRightArcTarget = nil;
	
    [_ShipsInRange removeAllObjects];
    [_ShipsInRange release];
}

@end
