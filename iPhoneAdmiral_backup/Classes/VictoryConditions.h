//
//  VictoryConditions.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"

@interface VictoryConditions : NSObject <NSCoding>
{
    bool _RedSideCargoShipPresent;
    bool _RedSidePriorityTargetsPresent;
    
    bool _BlueSideCargoShipPresent;
    bool _BlueSidePriorityTargetsPresent;
}

- (id) initWithRedCargo:(BOOL) rc
             RedTargets:(BOOL) rt
              BlueCargo:(BOOL) bc
            BlueTargets:(BOOL) bt;

- (VictoryResult) checkVictoryWithRedShips:(NSArray *) redShips
                                 BlueShips:(NSArray * ) blueShips;


@end
