//
//  AIValues.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int AIHint_FoM_Radius;
extern const int AIHint_FirepowerMax_Radius;

enum
{
	//permanent values - those that can be calculated at the start of the game
	AIHint_FreedomOfManeuver = 0,		//penalty for being close to map edge, land, rocks
	AIHint_FreedomOfManeuver_BigShip,	//as above, but includes shallow water
    AIHint_StrategicallyIportantHex,    //hint for defensive AIs

	//HEX values
	AIHint_EnemyFirepower,				//penalty for being in range of enemy ship guns
	AIHint_EnemyBoardingStrength,		//notification on enemy boarding strength
	AIHint_WindPosition,				//bonus/penalty for being upwind/downwind of enemy
	AIHint_DistanceToNearestEnemy,		//used by hunter seeker algorithm
	
	//advanced hex values
	AIHint_ProximityToFriendlyShips,	//bonus for being close to friendlies
	AIHint_LeftArcEngagementValueMAX,	//maximum value of firing upon target in the left arc
	AIHint_RightArcEngagementValueMAX,	//maximum value of firing upon target in the right arc
		
	//guard
	AIHintsMAX,	
};

@class Ship;

@interface HexAIHints : NSObject <NSCopying>
{	
	NSMutableArray * _AIHintValues;

	//stores pointers to enemy ships that are in ranges from this hex
    NSMutableArray * _ShipsInRange;
}

@property (nonatomic, assign) NSMutableArray * _AIHintValues;
@property (nonatomic, assign) NSMutableArray * _ShipsInRange;

/* reset non permanet hints */
- (void) zeroNonPermanentHints;

@end
