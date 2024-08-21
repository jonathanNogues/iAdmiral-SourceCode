//
//  VictoryConditions.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VictoryConditions.h"

#import "Ship.h"
#import "Hex.h"

@implementation VictoryConditions

- (id) initWithRedCargo:(BOOL) rc
             RedTargets:(BOOL) rt
              BlueCargo:(BOOL) bc
            BlueTargets:(BOOL) bt
{
    self = [super init];
    
    _RedSideCargoShipPresent = rc;
    _RedSidePriorityTargetsPresent = rt;
    
    _BlueSideCargoShipPresent = bc;
    _BlueSidePriorityTargetsPresent = bt;
    
    return self;
}

- (VictoryResult) checkVictoryWithRedShips:(NSArray *) redShips
                                 BlueShips:(NSArray * ) blueShips
{
    bool red_victory_flag = NO;
    bool blue_victory_flag = NO;
    
    //check for fleet counts
    if ([redShips count] == 0)
    {
        blue_victory_flag = YES;
        NSLog(@"Blue Victory by destroying all Red Ships.");
    }

    if ([blueShips count] == 0)
    {
        red_victory_flag = YES;
        NSLog(@"Red Victory by destroying all Blue Ships.");
    }

    //check status of red cargo ship
    if (_RedSideCargoShipPresent)
    {
        Ship * redCargoShip = nil;
        
        //check if it is still afloat
        for (Ship * ship in redShips)
        {
            if (ship._IAmCargoShip)
            {
                redCargoShip = ship;
                break;
            }
        }
        
        //if it is sunk, rais blue victory flag
        if (redCargoShip == nil || redCargoShip._HitPointsLeft <= 0)
        {
            blue_victory_flag = YES;
            NSLog(@"Blue Victory by sinking Red Cargo Ship.");
        }
        //else check if it has reached the objective
        else if (redCargoShip._CurrentHex._RedObjectiveHex)
        {
            red_victory_flag = YES;
            NSLog(@"Red Victory by Cargo Ship reaching Red Objective.");
        }
        else
        {
            NSLog(@"Red Cargo Ship still afloat.");
        }
    }
    else
    {
        NSLog(@"Red Cargo Ship not present...");
    }
    
    //check status of red priority targets
    if (_RedSidePriorityTargetsPresent)
    {
        bool red_prio_ok = NO;
        
        //check if there are priority targets left
        for (Ship * ship in redShips)
        {
            if (ship._IAmPriorityTarget)
            {
                //one is enough
                red_prio_ok = YES;
                NSLog(@"Red Priority Targets still around...");
                break;
            }
        }

        //no red priority targets were found
        if (! red_prio_ok)
        {
            blue_victory_flag = YES;
            NSLog(@"Blue Victory by destroying all Red Priority Targets.");
        }
    }
    else
    {
        NSLog(@"No Red Priority Targets present...");
    }
    
    //check status of blue cargo ship
    if (_BlueSideCargoShipPresent)
    {
        Ship * blueCargoShip = nil;
        
        //check if it is still afloat
        for (Ship * ship in blueShips)
        {
            if (ship._IAmCargoShip)
            {
                blueCargoShip = ship;
                break;
            }
        }
        
        //if it is sunk, raise blue victory flag
        if (blueCargoShip == nil || blueCargoShip._HitPointsLeft <= 0) 
        {
            red_victory_flag = YES;
            NSLog(@"Red Victory by sinking Blue Cargo Ship.");
        }
        //else check if it has reached the objective
        else if (blueCargoShip._CurrentHex._BlueObjectiveHex) 
        {
            blue_victory_flag = YES;   
            NSLog(@"Blue Victory by Cargo Ship reaching Blue Objective.");            
        }
        else
        {
            NSLog(@"Blue Cargo Ship still afloat...");
        }
    }
    else
    {
        NSLog(@"Blue Cargo Ship not present...");
    }
    
    //check status of blue priority targets
    if (_BlueSidePriorityTargetsPresent)
    {
        bool blue_prio_ok = NO;
        
        //check if there are priority targets left
        for (Ship * ship in blueShips)
        {
            if (ship._IAmPriorityTarget)
            {
                //one is enough
                blue_prio_ok = YES;
                NSLog(@"Blue Priority Targets still around...");
                break;
            }
        }
        
        //no blue priority targets were found
        if (! blue_prio_ok)
        {
            red_victory_flag = YES;
            NSLog(@"Red Victory by destroying all Blue Priority Targets.");
        }
    }
    else
    {
        NSLog(@"No Blue Priority Targets present...");
    }
    
    if (red_victory_flag && blue_victory_flag) return ResultDraw;
    if (red_victory_flag) return ResultRedSideWon;
    if (blue_victory_flag) return ResultBlueSideWon;
    return ResultUndecided;
}

- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super init];
    
    _RedSideCargoShipPresent =          [aDecoder decodeBoolForKey:@"_RedSideCargoShipPresent"];
    _RedSidePriorityTargetsPresent =    [aDecoder decodeBoolForKey:@"_RedSidePriorityTargetsPresent"];
    _BlueSideCargoShipPresent =         [aDecoder decodeBoolForKey:@"_BlueSideCargoShipPresent"];
    _BlueSidePriorityTargetsPresent =   [aDecoder decodeBoolForKey:@"_BlueSidePriorityTargetsPresent"];
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
    [aCoder encodeBool:_RedSideCargoShipPresent forKey:@"_RedSideCargoShipPresent"];
    [aCoder encodeBool:_RedSidePriorityTargetsPresent forKey:@"_RedSidePriorityTargetsPresent"];
    [aCoder encodeBool:_BlueSideCargoShipPresent forKey:@"_BlueSideCargoShipPresent"];
    [aCoder encodeBool:_BlueSidePriorityTargetsPresent forKey:@"_BlueSidePriorityTargetsPresent"];
}

@end
