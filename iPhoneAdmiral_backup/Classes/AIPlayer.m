//
//  AIPlayer.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AIPlayer.h"
#import "HexBoard.h"
#import "HexAIHints.h"
#import "ShipAI.h"
#import "MapView.h"
#import "AIDefines.h"
#import "Commands.h"
#import "Ship.h"

#define NO_MORE_MOVES		NO
#define MORE_MOVES_AVAIL	YES

//delay between commands in warpath
#define AI_COMMAND_DELAY    0.4

@implementation AIPlayer

- (id) initWithBoard:(HexBoard *) hb
			 forSide:(SideOfConflict) side
			pMapView:(MapView *) pmap
{
	self = [super init];
	
	_MySide = side;
	_HexBoard = hb;
	_pMapView = pmap;
	
	if (side == RedSide)
	{
		_MyShips = _HexBoard._RedSideShips;
		_EnemyShips = _HexBoard._BlueSideShips;
	}
	else 
	{
		_MyShips = _HexBoard._BlueSideShips;
		_EnemyShips = _HexBoard._RedSideShips;
	}
	
	_MyAIs = [[NSMutableArray alloc] initWithCapacity:[_MyShips count]];
	
	for (Ship * ship in _MyShips)
	{
		ShipAI * sai = [[ShipAI alloc] initWithShip: ship
											 AIType: AIType_Normal
										   hexBoard: _HexBoard
										   pMapView: pmap];
		
		[_MyAIs addObject: sai];
        [sai release];
	}
	
	_BattleModeAIs = [[NSMutableArray alloc] initWithCapacity:[_MyShips count]];
	_SentinelAndFortAIs = [[NSMutableArray alloc] initWithCapacity:[_MyShips count] / 2];
	_HunterAIs = [[NSMutableArray alloc] initWithCapacity:[_MyShips count]];
    
    _TurnPreparationComplete = NO;
    _ActiveSAI = nil;
    
	NSLog(@"SKYNET: Side %d is operational.", side);
	
	return self;
}

/* prepare for decision making process */
- (void) prepareForTurn
{
    _TurnPreparationComplete = NO;
    
	NSLog(@"AI preparing...");
	
    //remove AIs for sunken ships and towns - we do not want those
    
    for (ShipAI * sai in [_MyAIs copy])
    {
        if (sai._MyShip._HitPointsLeft <= 0 || sai._MyShip._Type == town)
        {
            NSLog(@"Removing AI for %@. Rest in pieces.", sai._MyShip);
            [_MyAIs removeObject: sai];
        }
    }
        
    //calculate who is winning
    int my_strength = 0;
    int enemy_strength = 0;
    AIType this_turn_default = AIType_Normal;
    
    for (Ship * ship in _MyShips)
    {
        my_strength += ship._Guns;
        my_strength += ship._HitPointsLeft * 5;
    }
    
    for (Ship * ship in _EnemyShips)
    {
        enemy_strength += ship._Guns;
        enemy_strength += ship._HitPointsLeft * 5;
    }
    
    NSLog(@"SKYNET: My strength is %d, while the puny human has: %d", my_strength, enemy_strength);
    
    if (2 * my_strength < enemy_strength)
    {
        NSLog(@"SKYNET: Adopting Perseverance protocol.");
        this_turn_default = AIType_Coward;
    }
    
    if (my_strength > enemy_strength * 2)
    {
        NSLog(@"SKYNET: Adopting EndGame protocol.");
        this_turn_default = AIType_Aggressive;
    }
    //finshed calculating strenghts
    
    [_SentinelAndFortAIs removeAllObjects];
    [_HunterAIs removeAllObjects];
    [_BattleModeAIs removeAllObjects];
    
    //assign ai types to AIs under my command
    //and group them accordingly
	for (ShipAI * myai in _MyAIs)
	{
        //check for forts
        if (myai._MyShip._IAmFort)
        {
            NSLog(@"%@ is a fort.", myai._MyShip);
            myai._MyType = AIType_Normal;
            [_SentinelAndFortAIs addObject: myai];
            continue;       //this ship is set, move to the next one
        }
        
        //check for sentinels
        if (myai._MyShip._Sentinel)
        {
            NSLog(@"%@ is now in SENTINEL mode.", myai._MyShip);
            myai._MyType = AIType_Sentinel;
            [_SentinelAndFortAIs addObject: myai];
            continue;       //this ship is set, move to the next one
        }
		
        //check for ships in fighting distance
		for (Ship * enemy_vessel in _EnemyShips)
		{
			int distance = [_HexBoard fastHexDistanceForHexID: myai._MyShip._CurrentHex._HexID 
													 andHexID: enemy_vessel._CurrentHex._HexID ];
			
			if (distance < AI_SEEKING_DISTANCE)
			{
				NSLog(@"%@ is now in HUNTER mode.", myai._MyShip);
				
                //check if it should hunt for cargo ships or just anything
                if (myai._MyShip._HunterKiller) myai._MyType = AIType_HunterKiller;
                else myai._MyType = AIType_HunterSeeker;
                
                if (! [_HunterAIs containsObject: myai])
                {
                    //add this ai to the hunters
                    [_HunterAIs addObject: myai];
                    
                    //clear its calculated path
                    [myai clearSavedPath];
                }
			}
			
			if (distance < AI_FIGHTING_DISTANCE)
			{
				NSLog(@"%@ is now in BATTLE mode.", myai._MyShip);
				myai._MyType = this_turn_default;
                [_BattleModeAIs addObject: myai];
                [_HunterAIs removeObject: myai];
				break;	//one ship in fighting distance is enough to trigger battle mode
			}
		}
	}
    
    NSLog(@"SKYNET: Initial assigning complete.");
    NSLog(@"Sentinel n Fort AIs count: %d", [_SentinelAndFortAIs count]);
    NSLog(@"BattleMode AIs count: %d", [_BattleModeAIs count]);
    NSLog(@"HunterMode AIs count: %d", [_HunterAIs count]);
    
    //all ais should be in their buckets, but now we need to tidy the sentinel and fort bucket

    for (ShipAI * ai in [_SentinelAndFortAIs copy])
    {
        int activation_range;
        if (ai._MyType == AIType_Sentinel) activation_range = AI_FIGHTING_DISTANCE;
        else activation_range = 5;      //so < this will make a target be in firing range
        
        bool targets_in_range = NO;
        
        for (Ship * enemy_vessel in _EnemyShips)
        {
            int distance = [_HexBoard fastHexDistanceForHexID: ai._MyShip._CurrentHex._HexID 
													 andHexID: enemy_vessel._CurrentHex._HexID ];
            
            //no target in range
            if (distance <= activation_range)
            {
                targets_in_range = YES;
                break;
            }

        }
        
        if (targets_in_range)
        {
            //leave forts as they are, but move sentinels to battle mode
            if (ai._MyType == AIType_Sentinel)
            {
                [_BattleModeAIs addObject: ai];
                [_SentinelAndFortAIs removeObject: ai];
            }
        }
        else
        {
            //no target in range, ignore this ai for this turn
            [_SentinelAndFortAIs removeObject: ai];
        }
    }
    
    NSLog(@"SKYNET: Final assigning complete.");
    NSLog(@"Fort AIs count: %d", [_SentinelAndFortAIs count]);
    NSLog(@"BattleMode AIs count: %d", [_BattleModeAIs count]);
    NSLog(@"HunterMode AIs count: %d", [_HunterAIs count]);
    
    //update hexais, so initial calculations are done on real data
    NSLog(@"Analyzing hexboard...");
    [_HexBoard updateHexAIhints:_MySide];
    
    if ([_HunterAIs count] > 0)
    {
        NSLog(@"SKYNET: Assigning targets to Hunter AIs");
        
        for (ShipAI * ai in _HunterAIs)
        {            
            //if hunter killer, focus on cargo ship ONLY
            if (ai._MyType == AIType_HunterKiller && ai._PrimaryTarget == nil)
            {
                //search for cargo ship
                for (Ship * enemy_vessel in _EnemyShips)
                    if (enemy_vessel._IAmCargoShip)
                    {
                        ai._PrimaryTarget = enemy_vessel;
                        break;
                    }
            }
            
            //if hunter seeker, focus on closest ship
            if (ai._MyType == AIType_HunterSeeker)
            {
                //reset the target
                ai._PrimaryTarget = [_EnemyShips objectAtIndex: 0];
                int distance = [_HexBoard fastHexDistanceForHexID: ai._MyShip._CurrentHex._HexID
                                                         andHexID: ai._PrimaryTarget._CurrentHex._HexID];
                
                for (Ship * enemy_vessel in _EnemyShips)
                {
                    int new_distance = [_HexBoard fastHexDistanceForHexID: ai._MyShip._CurrentHex._HexID
                                                                 andHexID: enemy_vessel._CurrentHex._HexID];
                    
                    if (new_distance < distance)
                    {
                        distance = new_distance;
                        ai._PrimaryTarget = enemy_vessel;
                    }
                }
            }
            
            NSLog(@"Ship %@ has now targeted %@", ai._MyShip, ai._PrimaryTarget);
        }//all ais in hunter ais
    }//if hunter ai count > 0
    
    //perform initial warpath calculation
    NSLog(@"Initial Warpaths calculation for %d Battle Mode AIs...", [_BattleModeAIs count]);
    for (ShipAI * ai in _BattleModeAIs) [ai getAndEvaluateReachablePositions];
    [_BattleModeAIs sortUsingSelector:@selector(compareWarpathValues:)];
    
    NSLog(@"Initial Warpaths calculation for %d Hunter Mode AIs...", [_HunterAIs count]);
    for (ShipAI * ai in _HunterAIs) [ai calculatePathTowardsTarget];
    [_HunterAIs sortUsingSelector:@selector(compareWarpathValues:)];
    
    _TurnPreparationComplete = YES;
}

- (void) selectNextWarpathWithBoardAnalysis:(NSNumber *) hex_analysis
{
    NSLog(@"SKYNET: Searching for next warpath");
    
    if (!_TurnPreparationComplete)
    {
        NSLog(@"SKYNET: Preparations not complete! Reinitializing.");
        [self prepareForTurn];
    }
    
    if ([hex_analysis boolValue])
    {
        NSLog(@"SKYNET: Board analysis requested, performing...");
        [_HexBoard updateHexAIhints: _MySide];
    }
    
    _ActiveSAI = nil;
    
    //for each ShipAI
    for (ShipAI * sai in [_SentinelAndFortAIs copy])
    {
        [sai getAndEvaluateReachablePositions];
        
        //if warpath is sane == can fire on something, fire
        if ([sai._BestWarpath count] > 0)
        {
            _ActiveSAI = sai;
            goto ACTIVE_SAI_SELECTED;
        }
        else
        {
            NSLog(@"SKYNET: Moving AI for %@ to the back of the list", sai._MyShip);
            [_SentinelAndFortAIs removeObject: sai];
            [_SentinelAndFortAIs addObject: sai];
        }
    }
    
    //check if there are forts remaining
    if ([_SentinelAndFortAIs count] > 0)
    {
        NSLog(@"SKYNET: Remaining %d forts cannot engage enemy.", [_SentinelAndFortAIs count]);
        [_BattleModeAIs addObjectsFromArray:_SentinelAndFortAIs];
        [_SentinelAndFortAIs removeAllObjects];
        [self selectNextWarpathWithBoardAnalysis:YES_NUM];
        return;
    }
        
    // if we are here, this means all forts are either dealt with, or merged with battle ais
    // so we proceed with battle mode AIs
    
    if ([_BattleModeAIs count] > 0)
    {
        NSLog(@"SKYNET: Gettysburg protocol active.");
        
        if ([hex_analysis boolValue])
        {
            NSLog(@"SKYNET: Performing AI evaluation...");

            //calculate warpaths
            for (ShipAI * ai in _BattleModeAIs) [ai getAndEvaluateReachablePositions];
            
            //sort them by value
            [_BattleModeAIs sortUsingSelector:@selector(compareWarpathValues:)];
            
#ifdef NON_RELEASE
            //debug
            for (ShipAI * ai in _BattleModeAIs) 
                NSLog(@"Warpath Value for %@ = %d", ai._MyShip, ai._BestWarpathValue);
#endif            
            
            //we calculated everything here, so we can just choose the best sai and move on to execution
            _ActiveSAI = [_BattleModeAIs lastObject];
        }
        else
        {
            //no hexboard analysis required, so we just take the best AI, recalculate it for good measure
            //and execute
            _ActiveSAI = [_BattleModeAIs lastObject];
            
            int previous_warpath_value = _ActiveSAI._BestWarpathValue;
            
            //recalculate warpath value for good measure
            [_ActiveSAI getAndEvaluateReachablePositions];
            
            //this will probably never happen, but if it did, i'd like to know
            if (_ActiveSAI._BestWarpathValue != previous_warpath_value)
                NSLog(@"SKYNET: Warpath value changed");
        }
        
        //check if selected SAI has sane warpath
        if ([_ActiveSAI._BestWarpath count] > 0)
        {
            goto ACTIVE_SAI_SELECTED;
        }
        else
        {
            NSLog(@"SKYNET: Best available SAI has warpath of length 0. Initiating deep search.");
            
            for (ShipAI * deep_sai in _BattleModeAIs)
            {
                if ( [deep_sai._BestWarpath count] > 0)
                {
                    _ActiveSAI = deep_sai;
                    goto ACTIVE_SAI_SELECTED;
                }
            }
            
            NSLog(@"SKYNET: No BattleMode SAI has warpath of length > 0");
            [_BattleModeAIs removeAllObjects];
            [self selectNextWarpathWithBoardAnalysis:YES_NUM];
            return;
        }

    }
    
    //if we are here, it means all battle ais have been dealt with, we can now move to hunter ais
    
    if ([_HunterAIs count] > 0)
    {
        NSLog(@"SKYNET: Voyager protocol active");
        
        if ([hex_analysis boolValue])
        {
            NSLog(@"SKYNET: Board analysis requested, performing...");
            
            //calculate all paths
            for (ShipAI * ai in _HunterAIs) [ai calculatePathTowardsTarget];
            
            //sort by path value
            [_HunterAIs sortUsingSelector:@selector(compareWarpathValues:)];
            
            //begin executing, starting from best warpath
            _ActiveSAI = [_HunterAIs lastObject];
        }
        else
        {
            //select best warpath
            _ActiveSAI = [_HunterAIs lastObject];
            
            //recalculate for safety
            [_ActiveSAI calculatePathTowardsTarget];
        }
    
        //check if selected SAI has sane warpath
        if ([_ActiveSAI._BestWarpath count] > 0)
        {
            goto ACTIVE_SAI_SELECTED;
        }
        else
        {
            NSLog(@"SKYNET: Best available SAI has warpath of length 0. Initiating deep search.");
            
            for (ShipAI * deep_sai in _HunterAIs)
            {
                if ( [deep_sai._BestWarpath count] > 0)
                {
                    _ActiveSAI = deep_sai;
                    goto ACTIVE_SAI_SELECTED;
                }
            }
            
            NSLog(@"SKYNET: No BattleMode SAI has warpath of length > 0");
            [_HunterAIs removeAllObjects];
            [self selectNextWarpathWithBoardAnalysis:YES_NUM];
            return;
        }
    }
    
ACTIVE_SAI_SELECTED:
    
    if (_ActiveSAI != nil)
	{
		NSLog(@"SKYNET: %@ selected as active", _ActiveSAI._MyShip);

        //store data
        _WarpathUnderExecution = _ActiveSAI._BestWarpath;
        _ShipExecutingWarpath = _ActiveSAI._MyShip;
        
        //select this ship
        _pMapView._SelectedShip = _ShipExecutingWarpath;
        [_pMapView handleShipSelected];
        
        //remember if starting position indicates AI Hints update will be necessary after warpath is done
        _BegginingOfWarpathHex = _ActiveSAI._MyShip._CurrentHex;
        
        //give mapview time to zoom to ship!
        [self performSelector: @selector(executeWarpathCommand) withObject: nil afterDelay: AI_COMMAND_DELAY];
    }
	else
	{
		NSLog(@"SKYNET: I am done for now...");

        _TurnPreparationComplete = NO;
		
        [_pMapView handleEndTurn];
	}
    
}

                                /*  WARPATH EXECUTUION  */
 
- (void) executeWarpathCommand
{
    if (_Pause)
    {
        NSLog(@"SKYNET: taking a break...");
        return;
    }
    
    if (_WarpathUnderExecution.count == 0)
	{
		NSLog(@"Warpath empty!");
		_WarpathUnderExecution = nil;
		        
        //if this was a fort, then it is done for this turn
        if (_ActiveSAI._MyShip._IAmFort)
        {
            NSLog(@"SKYNET: Fort is done: %@", _ActiveSAI._MyShip);
            [_SentinelAndFortAIs removeObject:_ActiveSAI];
            [_BattleModeAIs removeObject: _ActiveSAI];
            [self selectNextWarpathWithBoardAnalysis: NO_NUM];
            return;
        }
        
        switch (_ActiveSAI._MyType) 
        {
            case AIType_Aggressive:
            case AIType_Coward:
            case AIType_Normal:
            case AIType_Sentinel:
                //check if we should remove this ai
                if (_ActiveSAI._MyShip._MovePointsLeft == 0 || (_ActiveSAI._MyShip._FiredLeft && _ActiveSAI._MyShip._FiredRight))
                {
                    NSLog(@"SKYNET: ship used up all MPs or fired both broadsides. It is done.");
                    [_BattleModeAIs removeObject:_ActiveSAI];
                }
                
                //first check if hexupdate is required
                if (_BegginingOfWarpathHex._HexID == _ActiveSAI._MyShip._CurrentHex._HexID)
                {
                    NSLog(@"SKYNET: AI did not move.");
                    [self selectNextWarpathWithBoardAnalysis: NO_NUM];
                    return;
                }
                
                //second check if update is required
                if ([[_BegginingOfWarpathHex._AIValues._AIHintValues objectAtIndex:AIHint_EnemyFirepower] intValue] == 0 && 
                    [[_ActiveSAI._MyShip._CurrentHex._AIValues._AIHintValues objectAtIndex:AIHint_EnemyFirepower] intValue] == 0)
                {
                    NSLog(@"SKYNET: AI did moved from safe to safe postion.");
                    [self selectNextWarpathWithBoardAnalysis: NO_NUM];
                    return;
                }
                
                //seems like update is required
                NSLog(@"SKYNET: HEXAIHINTS update is required.");
                [self selectNextWarpathWithBoardAnalysis: YES_NUM];
                return;
                
                break;
                
            case AIType_HunterKiller:
            case AIType_HunterSeeker:
                if (! _ActiveSAI._AStarBlocked )
                {
                    NSLog(@"SKYNET: Whole path executed, removing from active AI list.");
                    [_HunterAIs removeObject:_ActiveSAI];
                }
                else
                {
                    NSLog(@"SKYNET: Path was blocked, updating and moving to the end of the list.");

                    [_ActiveSAI trimAStarPath];
                    
                    [_HunterAIs removeObject:_ActiveSAI];
                    [_HunterAIs addObject:_ActiveSAI];
                }

                [self selectNextWarpathWithBoardAnalysis: NO_NUM];

                break;
                
            default:
                break;
        }
                
		return;
	}
    
    //select the ship
    _pMapView._SelectedShip = _ShipExecutingWarpath;
	
	id com = [[_WarpathUnderExecution objectAtIndex: 0] retain];
	[_WarpathUnderExecution removeObjectAtIndex: 0];
    
	//if move then move
	if ([com isKindOfClass: [MoveCommand class]])
	{
		MoveCommand * mc = (MoveCommand *) com;
        
		switch (mc._move)
		{
			case MoveCommand_MoveAhead:
				[_pMapView handleGoButton];
				break;
				
			case MoveCommand_TurnLeft:
				[_pMapView handleTurnLeftButton];
				break;
                
			case MoveCommand_TurnRight:
				[_pMapView handleTurnRightButton];
				break;
		}
        
        //this function will be called again after mapview finishes animating move
    }
	
	//if fire then fire
	if ([com isKindOfClass: [FightCommand class]])
	{
		FightCommand * fc = (FightCommand *) com;
		[_pMapView handleShipToShipFire: fc._Target];
		
		//this function will be called again after mapview finishes animatind damage
	}
    
    [com release];
}

//called by mapview after turn / move
- (void) navigationFinished
{
    NSLog(@"SKYNET: Continuing...");
    
    //check for hunter ais entering battle distance!
    if ((_ActiveSAI._MyType == AIType_HunterKiller || _ActiveSAI._MyType == AIType_HunterSeeker) &&
        ([[_ActiveSAI._MyShip._CurrentHex._AIValues._AIHintValues objectAtIndex: AIHint_EnemyFirepower] intValue] != 0))
    {
        NSLog(@"SKYNET: During navigation, %@ detected enemy near hex %d", _ActiveSAI._MyShip, _ActiveSAI._MyShip._CurrentHex._HexID);
        
        //remove this ai as a hunter and enter battle mode
        [_HunterAIs removeObject: _ActiveSAI];
        [_BattleModeAIs addObject: _ActiveSAI];
        
        //change AI type
        _ActiveSAI._MyType = AIType_Normal;
        
        //analyze the board, find a battle - warpath
        [self performSelector: @selector(selectNextWarpathWithBoardAnalysis:) withObject: YES_NUM afterDelay: AI_COMMAND_DELAY];
        return;
    }
    
    //continue with normal warpath execution
    [self performSelector: @selector(executeWarpathCommand) withObject: nil afterDelay: AI_COMMAND_DELAY];
}

//called by mapview after cannon fire
- (void) shootingFinished:(BOOL) target_sunk
{
    if (target_sunk)
    {
        NSLog(@"SKYNET: Target destroyed, reevaluating position.");
        
        //add active SAI to battle mode ais once again
        [self performSelector: @selector(selectNextWarpathWithBoardAnalysis:) withObject: YES_NUM afterDelay: AI_COMMAND_DELAY];
    }
    else
    {
        NSLog(@"SKYNET: Continuing...");
        [self performSelector: @selector(executeWarpathCommand) withObject: nil afterDelay: AI_COMMAND_DELAY];
    }
}

//called when mapview pauses
- (void) setPause:(BOOL) pause
{
    _Pause = pause;

    if (pause)
    {
        NSLog(@"SKYNET: entering standby mode.");
    }
    else
    {
        NSLog(@"SKYNET: resuming full annihilation mode.");
        [self executeWarpathCommand];
    }
}


- (void) dealloc
{	
	NSLog(@"WARNING: AI Player for side %d is being dealloc'd!", _MySide);

	[NSObject cancelPreviousPerformRequestsWithTarget: self];
    
    _HexBoard = nil;
	_pMapView = nil;
	
	[_MyAIs release];
    
	_MyShips = nil;
    _EnemyShips = nil;
	
	[super dealloc];
	
	NSLog(@"AI Player for side %d dealloc ok!", _MySide);
}

@end
