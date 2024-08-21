//
//  StatisticsContainer.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"
#import "Ship.h"

@class HexBoard;

typedef enum 
{
	Surviving,
	Crippled,
	Lost,
	StateMax,
} ShipStateForStats;


@interface StatisticsContainer : NSObject
{	
	int _ShipNumbers[SideMAX][ClassMAX][StateMax];
    
    VictoryResult _winnerIs;
    bool          _WasMultiplayerGame; 
}

@property (nonatomic, readonly) VictoryResult _winnerIs;
@property (nonatomic, readonly) bool _WasMultiplayerGame;

- (id) initWithHexBoard:(HexBoard *) hb;

- (int) retrieveNumForSide:(SideOfConflict) side
					 Class:(ShipClass) sc
					 State:(ShipStateForStats) ssfs;

- (NSString *) retrieveStrNumForSide:(SideOfConflict) side
							   Class:(ShipClass) sc
							   State:(ShipStateForStats) ssfs;

@end
