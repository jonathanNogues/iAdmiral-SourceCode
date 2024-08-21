//
//  BoardingActionInfo.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#if 0

#import "BoardingActionInfo.h"
#import "BoardingAction.h"
#import "Ship.h"
#import "Hex.h"
#import "Common.h"

@implementation BoardingActionInfo

@synthesize _BoardingID, _ShipA_row, _ShipA_hrw, _ShipB_row, _ShipB_hrw;
@synthesize _RedDamadge, _BlueDamadge;
@synthesize _SomethingSunk, _BoardingState;
@synthesize _IDsToDrop;


- (id) initWithBoardingAction:(BoardingAction *) ba
{
	self = [super init];
	
	_BoardingID = ba._BoardingID;
	
	_ShipA_row = ba._BlueShip._CurrentHex._Row;
	_ShipA_hrw = ba._BlueShip._CurrentHex._HexInRow;
	_ShipB_row = ba._RedShip._CurrentHex._Row;
	_ShipB_hrw = ba._RedShip._CurrentHex._HexInRow;
	
	_RedDamadge = [ba retrieveDmgInfoForSide:RedSide];
	_BlueDamadge = [ba retrieveDmgInfoForSide:BlueSide];
	
	_IDsToDrop = nil;
	
	return self;
}

@end

#endif