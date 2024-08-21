//
//  StatisticsContainer.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsContainer.h"

#import "HexBoard.h"

@implementation StatisticsContainer

@synthesize _winnerIs;
@synthesize _WasMultiplayerGame;

- (id) initWithHexBoard:(HexBoard *) hb
{
	self = [super init];

	memset(_ShipNumbers, 0, sizeof(int) * SideMAX * ClassMAX * StateMax);
	
	NSMutableArray * allships = [NSMutableArray arrayWithArray: hb._RedSideShips];
	[allships addObjectsFromArray: hb._BlueSideShips];
	
	//deal with floating ships
	for (Ship * ship in allships)
	{
        //ships are considered crippled when their hitpoints are lower than half or movepoints are 0 (but not forts)
		if ((ship._HitPointsLeft > ship._HitPoints / 2) && (ship._MovePoints > 0 && !ship._IAmFort))
		{
			_ShipNumbers[ship._Side][ship._Class][Surviving]++;
			NSLog(@"%@ is surviving!", ship);
		}
		else
		{
			_ShipNumbers[ship._Side][ship._Class][Crippled]++;	
			NSLog(@"%@ is crippled!", ship);
		}
	}
	
	//deal with sinkers
	for (Ship * wreck in hb._RemovedShips)
	{
		_ShipNumbers[wreck._Side][wreck._Class][Lost]++;
		NSLog(@"%@ is lost!", wreck);
	}
    
    _winnerIs = [hb checkForVictory];
    
    _WasMultiplayerGame = hb._MultiPlayer;
    
	NSLog(@"Statistics init completed!");
	return self;
}

- (int) retrieveNumForSide:(SideOfConflict) side
					 Class:(ShipClass) sc
					 State:(ShipStateForStats) ssfs
{
	return _ShipNumbers[side][sc][ssfs];
}

- (NSString *) retrieveStrNumForSide:(SideOfConflict) side
							   Class:(ShipClass) sc
							   State:(ShipStateForStats) ssfs
{
	return [NSString stringWithFormat:@"%2d", _ShipNumbers[side][sc][ssfs] ];
}

- (void) dealloc
{
	[super dealloc];
}

@end
