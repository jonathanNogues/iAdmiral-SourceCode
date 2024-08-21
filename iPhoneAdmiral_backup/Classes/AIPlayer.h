//
//  AIPlayer.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class HexBoard;
@class MapView;
@class Ship;
@class ShipAI;
@class Hex;

@interface AIPlayer : NSObject {
	SideOfConflict _MySide;
	
	NSMutableArray * _MyShips;
	NSMutableArray * _EnemyShips;
	
	NSMutableArray * _MyAIs;
	
	HexBoard * _HexBoard;
	MapView * _pMapView;
    
    //warpath that is being executed
    NSMutableArray * _WarpathUnderExecution;
    Ship * _ShipExecutingWarpath;
    
    ShipAI * _ActiveSAI;
    
    //if set to true, AI will wait for coming back out of pause
    BOOL _Pause;
    
    //for categorizing AI during turn
    NSMutableArray * _BattleModeAIs;
    NSMutableArray * _SentinelAndFortAIs;
    NSMutableArray * _HunterAIs;
    
    BOOL _TurnPreparationComplete;
    
    Hex * _BegginingOfWarpathHex;
}

/* initialize as player for one side */
- (id) initWithBoard:(HexBoard *) hb
			 forSide:(SideOfConflict) side
			pMapView:(MapView *) pmap;

/* Make one decision , returns NO when no more decisions available */
//- (bool) makeOneDecision;

- (void) selectNextWarpathWithBoardAnalysis:(NSNumber *) hexboard_analysis_needed;


/* prepare for decision making process */
- (void) prepareForTurn;

/// warpath execution

- (void) executeWarpathCommand;

//called by mapview after turn / move
- (void) navigationFinished;

//called by mapview after cannon fire
- (void) shootingFinished:(BOOL) target_sunk;

//called when mapview pauses
- (void) setPause:(BOOL) pause;


@end
