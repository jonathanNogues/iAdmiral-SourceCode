//
//  ShipAI.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ship;
@class HexBoard;
@class MapView;

typedef enum
{
	AIType_Protective,		//focus on staying close to FriendlySquadron ships
	AIType_Normal,			//normal
	AIType_Aggressive,		//lower safety consideration, greater desire for combat
	AIType_Coward,			//retreat AI (when on fire!)
	AIType_HunterSeeker,	//no enemies close enough for combat
    AIType_HunterKiller,    //no enemies close enough for combat, search for cargo ship
    AIType_Sentinel,        //for defending objectives / strategic points
	
} AIType;

@interface ShipAI : NSObject {
	Ship * _MyShip;
	AIType _MyType;
	
	Ship * _PrimaryTarget;
	
	NSMutableArray * _FriendlySquadron;		//friendly ships that are in formation with this one
											//recieves higher bonus for sticking close to them
	HexBoard * _HexBoard;
	
	NSSet * _ReachablePositionsSet;
	
	NSMutableArray * _BestWarpath;
	int _BestWarpathValue;

	MapView * _pMapView;
    
    //astarpath
    NSArray * _AStarPathThisTurn;
    bool _AStarBlocked;
}

@property (nonatomic, readonly) int _BestWarpathValue;
@property (nonatomic, readonly) Ship * _MyShip;
@property (nonatomic, assign) NSMutableArray * _BestWarpath;

@property (nonatomic, assign) Ship * _PrimaryTarget;
@property (nonatomic, assign) NSMutableArray * _FriendlySquadron;
@property (nonatomic, assign) AIType _MyType;

@property (nonatomic, readonly) bool _AStarBlocked;

- (id) initWithShip:(Ship *) ship
			 AIType:(AIType) ait
		   hexBoard:(HexBoard *) hb
		   pMapView:(MapView *) pmap;

/* get set of reachable positions - this will be for battle mode only */
- (void) getAndEvaluateReachablePositions;

/* find path towards enemy - hunter seekers and hunter killers */
- (void) calculatePathTowardsTarget;

/* to be called after partial move, to update the astar path by hexes already traveled */
- (void) trimAStarPath;

/* remove stored path, so that calculate function calculates new one,
   instead of updating the old one */
- (void) clearSavedPath;

/* checks if the ship is ready to perform moves this turn */
- (bool) canMakeAMove;

/* checks if the best warpath is not sitting around doing nothing */
- (bool) isWarpathSane;

/* for ordering by warpath value */
- (NSComparisonResult) compareWarpathValues: (ShipAI *) otherAI;


@end
