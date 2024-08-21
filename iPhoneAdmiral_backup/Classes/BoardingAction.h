//
//  BoardingAction.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

//class for boarding actions, 1 on 1, but one ship may be engaged in more than one

@class Ship;
@class DamadgeInfo;

@interface BoardingAction : NSObject <NSCoding>
{
	int _BoardingID;
	
	Ship * _RedShip;
	Ship * _BlueShip;
	
	DamadgeInfo * _RedDamadge;
	DamadgeInfo * _BlueDamadge;
}

@property (nonatomic, readonly) int _BoardingID;
@property (nonatomic, readonly) Ship * _RedShip;
@property (nonatomic, readonly) Ship * _BlueShip;


- (id) initWithShip:(Ship *) shipA
		andWithShip:(Ship *) shipB;

- (void) addShip:(Ship *) ship;

/* return true if something sinks */
- (bool) processRoundOfFighting;

/* returns damadge info for given side */
- (DamadgeInfo *) retrieveDmgInfoForSide:(SideOfConflict) sd;

/* returns ship info for given side */
- (Ship *) retrieveShipFromSide:(SideOfConflict) sd;

@end
