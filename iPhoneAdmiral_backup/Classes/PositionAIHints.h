//
//  PersonalAIHints.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HexAIHints.h"
#import "ShipAI.h"	//for aitype, move aitype to common

@class Ship;
@class HexBoard;

@interface PositionAIHints : HexAIHints {
	int _ShipsInLeftFiringArc;
	int _ShipsInRightFiringArc;
	
	Ship * _BestLeftArcTarget;
	Ship * _BestRightArcTarget;
	
	int _BestLeftArcTargetValue;
	int _BestRightArcTargetValue;
}

@property (nonatomic, readonly) int _ShipsInLeftFiringArc;
@property (nonatomic, readonly) int _ShipsInRightFiringArc;
@property (nonatomic, readonly) Ship * _BestLeftArcTarget;
@property (nonatomic, readonly) Ship * _BestRightArcTarget;
@property (nonatomic, readonly) int _BestLeftArcTargetValue;
@property (nonatomic, readonly) int _BestRightArcTargetValue;

/* initialize by cooying global hints */
- (id) initWithHexHints:(HexAIHints *) aih;

/* prepares the personal ai hints using functions from hexboard */
- (void) assignTargetsToFiringArcsUsing:(HexBoard *) hb
							   andDummy:(Ship *) dummy;

/* evalueates possible targets for supplied ship */
- (void) evaluateTargetsUsingShip:(Ship *) ship;

/* calculate single engagement value */
- (int) calculateSingleEngagementValueForShip:(Ship *) striker
									andVictim:(Ship *) victim
                                     distance:(int) distance;

- (int) calculatePositionValueForShip:(Ship *) ship
							andAIType:(AIType) ait;

@end
