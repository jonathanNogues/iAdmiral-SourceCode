//
//  HexBoard.m
//  ObjCHexboard
//
//  Created by Piotr Sarnowski on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HexBoard.h"
#import "Ship.h"
#import "DamadgeInfo.h"
#import "LastMove.h"
#import "BoardingAction.h"
#import "UIBoardingNfo.h"
#import "FiringSolutionInfo.h"

#import "AIDefines.h"

#import "HexAIHints.h"
#import "PositionAIHints.h"
#import "ReachablePosition.h"
#import "Commands.h"
#import "AITargetData.h"
#import "VictoryConditions.h"

#import "AStarNode.h"

#import "Common.h"

#import "SettingsContainer.h"

#define DEFAULT_HEX_COUNT			100
#define DEFAULT_SHIPS_PER_SIDE		10
#define DEFAULT_DAMADGE_INFOS		10
#define DEFAULT_BOARDING_ACTIONS	10

#define CANNON_RANGE			5
#define COLLATERAL_MODIFIER		0.5

//so in the future, if something changes we can handle different map file verisions
#define MAP_FILE_VERSION        1.0

static inline int course_change_required(HexDirection course, HexDirection desired_course);

@implementation HexBoard

@synthesize _HexesPerRow, _RowCount, _RedSideShips, _BlueSideShips, _RemovedShips, _WindDirection, _CurrentSide;
@synthesize _ScenarioName, _ScenarioDifficulty;
@synthesize _MultiPlayer;

#ifdef MAPCREATOR
@synthesize _VictoryConditions;
#endif

					/********************
					 *	INITIALIZATION	*
					 ********************/

- (HexBoard *) initWithHexesPerRow:(int)hpr
						  RowCount:(int)rc
{
	_RedSideShips = [[NSMutableArray alloc] initWithCapacity:DEFAULT_SHIPS_PER_SIDE];
	_BlueSideShips = [[NSMutableArray alloc] initWithCapacity:DEFAULT_SHIPS_PER_SIDE];
	_RemovedShips = [[NSMutableArray alloc] initWithCapacity:DEFAULT_SHIPS_PER_SIDE * 1.5];
	
	//_Damadges = [[NSMutableArray alloc] initWithCapacity: DEFAULT_DAMADGE_INFOS];
	_BoardingActions = [[NSMutableArray alloc] initWithCapacity: DEFAULT_BOARDING_ACTIONS];
	//_BoardingActionInfos = [[NSMutableArray alloc] initWithCapacity: 10];
	
	_UIUpdates = [[NSMutableArray alloc] initWithCapacity: 20];
	
	_RowCount = rc;
	_HexesPerRow = hpr;	
	[self createBoardWithRows:rc HexesPerRow: hpr];
	
	//last move
	_LastMove = [[LastMove alloc] init];
	_CanUndoLastMove = NO;
	
	//wind
	_WindIsOn = YES;
	_WindDirection = LEFT;
	
	return self;
}

- (void) createBoardWithRows:(int) rc
				 HexesPerRow:(int) hpr
{
	_HexArray = [[NSMutableArray alloc] initWithCapacity: hpr * rc];
	
	//reset the ID Hex class assigns to its objects, so that they match indexes of _HexArray
	[Hex resetID];
	
	//push hexes into array
	for (int i = 0; i < hpr * rc; i++)
	{
		[_HexArray addObject: [[Hex alloc] init]];
	}
	
	_RowCount = rc;
	_HexesPerRow = hpr;
	
	//Connect hexes to one another
	//int cur_hex = 0;
	int cur_row = 0;
	int hex_crawler = 0;
	int max_hexes_this_row = hex_crawler + _HexesPerRow - 1;
	
	//connect hexes in the first row, but the last one
	for (; hex_crawler <= max_hexes_this_row - 1; hex_crawler++)
	{
		[[_HexArray objectAtIndex:hex_crawler] 
		 ConnectToHex:[_HexArray objectAtIndex:hex_crawler + 1] 
		 inDirection:RIGHT];
	}
	
	//connect all remaining rows
	cur_row = 1;
	
	while (cur_row < _RowCount)
	{
		//check for oddness
		if ((cur_row % 2) == 1)
		{
			//move into the row
			hex_crawler++;
			
			//odd rows have one less hex per row (hpr - 2)
			max_hexes_this_row = hex_crawler + _HexesPerRow - 2;
			
			//connect all but last hex int this row
			for (; hex_crawler <= max_hexes_this_row - 1; hex_crawler++)
			{
				[[_HexArray objectAtIndex:hex_crawler] 
				 ConnectToHex:[_HexArray objectAtIndex:hex_crawler + 1] 
				 inDirection:RIGHT];
				
				[[_HexArray objectAtIndex:hex_crawler] 
				 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow] 
				 inDirection:LEFT_UP];
				
				[[_HexArray objectAtIndex:hex_crawler] 
				 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow + 1] 
				 inDirection:RIGHT_UP];
			}
			
			//last hex heas no right neighbour
			[[_HexArray objectAtIndex:hex_crawler] 
			 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow] 
			 inDirection:LEFT_UP];
			
			[[_HexArray objectAtIndex:hex_crawler] 
			 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow + 1] 
			 inDirection:RIGHT_UP];
			
			cur_row++;
		}
		else
		{
			//move into the row
			hex_crawler++;
			
			//even rows have hpr - 1 hexes
			max_hexes_this_row = hex_crawler + _HexesPerRow - 1;
			
			//first element has no left_up neighbour
			[[_HexArray objectAtIndex:hex_crawler] 
			 ConnectToHex:[_HexArray objectAtIndex:hex_crawler + 1] 
			 inDirection:RIGHT];
			
			[[_HexArray objectAtIndex:hex_crawler] 
			 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow + 1] 
			 inDirection:RIGHT_UP];
			
			hex_crawler++;
			
			//all alements but first and last
			for (; hex_crawler <= max_hexes_this_row - 1; hex_crawler++)
			{
				[[_HexArray objectAtIndex:hex_crawler] 
				 ConnectToHex:[_HexArray objectAtIndex:hex_crawler + 1] 
				 inDirection:RIGHT];
				
				[[_HexArray objectAtIndex:hex_crawler] 
				 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow] 
				 inDirection:LEFT_UP];
				
				[[_HexArray objectAtIndex:hex_crawler] 
				 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow + 1] 
				 inDirection:RIGHT_UP];
			}
			
			//last element has only the left_up neighbour
			[[_HexArray objectAtIndex:hex_crawler] 
			 ConnectToHex:[_HexArray objectAtIndex:hex_crawler - _HexesPerRow] 
			 inDirection:LEFT_UP];
			
			cur_row++;
		}
		
	}
	
	//additional loop to set hexcoordinates, done elsewhere not to clog previous loops
	int hex_selector = 0;
	for (int r = 0; r < rc; r++)	//row loop
	{
		for (int h = 0; h < hpr; h++) //hex loop
		{
			if ((r % 2 == 1) && (h == hpr - 1)) break;
			[[_HexArray objectAtIndex:hex_selector] SetRow:r HexInRow:h];
			hex_selector++;
		}		
	}
	
	//initializing new coordinates system
	hex_selector = 0;
	int this_row_leftmost_x_coord = 0;
	for (int r = 0; r < rc; r++)	//row loop
	{
		for (int h = 0; h < hpr; h++) //hex loop
		{
			if ((r % 2 == 1) && (h == hpr - 1)) break;
			[[_HexArray objectAtIndex:hex_selector] set_CoordX: this_row_leftmost_x_coord + h];
			[[_HexArray objectAtIndex:hex_selector] set_CoordY: r];
			hex_selector++;
		}
		if (r % 2 == 1) this_row_leftmost_x_coord--; //this runs AFTER this row has been processed, so affects the next
	}	
}

/* initializes permanent AI values for all hexes */
- (void) initAI
{
	NSLog(@"Calculating permanent AI hints for entire map...");
    
    //if this is called from mapcreator, we must mark defensive positions ourselves
	for (Hex * hex in _HexArray)
	{
        if (hex._RedObjectiveHex || hex._BlueObjectiveHex || hex._StrategicHex)
        {
            hex._DefendThisHex = YES;
            NSLog(@"Marking hex %d as position to defend.", hex._HexID);
            
            for (Hex * neigh in [hex GetNeighbours])
            {
                neigh._DefendThisHex = YES;
                NSLog(@"Marking hex %d as position to defend.", neigh._HexID);
            }
        }
    }
    
    for (Hex * hex in _HexArray)
    {
		//get all hexes up to 3 hexes away
		NSDictionary * neighbours = [self getHexNeighbourhoodWithDistances: hex
															withinDiameter: AIHint_FoM_Radius];
		
		int neighbourhood_count = 0;
		int maneuver_penalty = 0;
		int maneuver_penalty_bigship = 0;
		
		//calculate neighbourhood value
		for (NSNumber * hexID in [neighbours allKeys])
		{
			//NSLog(@"hex id: %@ distance from origin: %@", hexID, [neighbours objectForKey:hexID]);
			
			Hex * hex = (Hex *)[_HexArray objectAtIndex: [hexID intValue]];
			
			if (hex._Terrain != TerrainDeepWater)
			{
				//if it aint deep water, it incures maneuver penalty
				//the closer to origin, the greater the penalty
				
				NSNumber * distance = [neighbours objectForKey:hexID];
				int int_distance = [distance intValue];
				int importance = 4 - int_distance;
				
				if (hex._Terrain == TerrainShallowWater)
				{
					maneuver_penalty_bigship -= importance;
				}
				else
				{
					maneuver_penalty -= importance;
					maneuver_penalty_bigship -= importance;					
				}
			}
			neighbourhood_count++;
		}
		
		//if the hex is close to the edge, it will have smaller neighbourhood set
		//full set should contain 37 hexes, so we deduct one for each hex missing
		maneuver_penalty -= (37 - neighbourhood_count);
		maneuver_penalty_bigship -= (37 - neighbourhood_count);
		
		NSNumber * man_penalty = [NSNumber numberWithInt: maneuver_penalty];
		NSNumber * man_penalty_bigship = [NSNumber numberWithInt: maneuver_penalty_bigship];
		
		[hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_FreedomOfManeuver
											   withObject: man_penalty];
		
		[hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_FreedomOfManeuver_BigShip
											   withObject: man_penalty_bigship];
		
        //if this hex is not in the immediate defensive zone, give it a huge penalty
        //so ships in sentinel mode do not stray from this area
        if (! hex._DefendThisHex)
        {
            NSNumber * sent_penalty = [NSNumber numberWithInt:AI_POS_VALUE_PENALTY_FOR_SENTINEL];
            
            [hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_StrategicallyIportantHex
                                                   withObject: sent_penalty];
        }
        else
        {
            [hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_StrategicallyIportantHex
                                                   withObject: [NSNumber numberWithInt: 0]];
            
            //NSLog(@"Hex %d strategic hint = %d", hex._HexID, 
              //    [[hex._AIValues._AIHintValues objectAtIndex:AIHint_StrategicallyIportantHex] intValue]);

        }
        
        //provide a small bonus for the objective/strategic hexes, so sentinels sit right on them,
        //when no targets are around
        if ( hex._StrategicHex || hex._RedObjectiveHex || hex._BlueObjectiveHex)
        {
            NSNumber * strat_bonus = [NSNumber numberWithInt:AI_POS_VALUE_STRATEGIC_POS_BONUS];
            
            [hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_StrategicallyIportantHex
                                                   withObject: strat_bonus];

            //NSLog(@"Hex %d strategic hint = %d", hex._HexID, 
              //    [[hex._AIValues._AIHintValues objectAtIndex:AIHint_StrategicallyIportantHex] intValue]);
}
        
		//neighbours no longer stores any objects that are part of hexboard, so it is safe to release
		[neighbours release];
	}
	
    NSLog(@"Permanent AI hints calculated!");
    
	[self updateHexAIhints:_CurrentSide];
}

					/****************
					 *	AI RELATED	*
					 ****************/

/* called at the beggining of a turn to set global AI values */
- (void) updateHexAIhints:(SideOfConflict) our_side;
{
	NSArray * our_ships;
	NSArray * enemy_ships;
	
	//to avoid later confusion
	if (our_side == RedSide) 
	{
		our_ships = _RedSideShips;
		enemy_ships = _BlueSideShips;
	}
	else
	{
		our_ships = _BlueSideShips;
		enemy_ships = _RedSideShips;		
	}
	
	//zero the AIHints
	for (Hex * hex in _HexArray)
	{
		[hex._AIValues zeroNonPermanentHints];
	}
	
	//update enemy firepower
	for (Ship * enemy_vessel in enemy_ships)
	{
		NSDictionary * neighbours = [self getHexNeighbourhoodWithDistances: enemy_vessel._CurrentHex
															withinDiameter: AIHint_FirepowerMax_Radius];
		/*
		NSLog(@"\n");		
		NSLog(@"**************************************************************");
		NSLog(@"* Updating firepower for ship %@  *", enemy_vessel);
		NSLog(@"**************************************************************");
		NSLog(@"\n");		
		*/
		
		//calculate neighbourhood value
		for (NSNumber * hexID in [neighbours allKeys])
		//ordered for easier debug
		//for (NSNumber * hexID in [[neighbours allKeys] sortedArrayUsingSelector:@selector(compare:)])
		{
			Hex * hex = (Hex *)[_HexArray objectAtIndex: [hexID intValue]];
			int distance = [[neighbours objectForKey:hexID] intValue];
			
			//get current firepower value
			int current_firepower = [[hex._AIValues._AIHintValues objectAtIndex: AIHint_EnemyFirepower] intValue];
			int new_firepower = current_firepower;
			
			//get current boarding strength value
			int current_boarding = [[hex._AIValues._AIHintValues objectAtIndex: AIHint_EnemyBoardingStrength] intValue];
			int new_boarding = current_boarding;
			
			//check for LOS block
			bool losblocked = ([self checkDistanceAndLOSForShip: enemy_vessel
													   ToHexRow: hex._Row
													   HexInRow: hex._HexInRow] == 0);
			            
			//actually, we probably get away with just returning here
			if (losblocked)
            {
                distance = 0;
                //NSLog(@"No LOS between hexes %d and %d", enemy_vessel._CurrentHex._HexID, hex._HexID);
            }
			
			//calculate new firepower value
			switch (distance)
			{
				case 0:
					//the enemy vessel - hex is unreachable so just ignore it
					break;
					
				case 1:
                    {  
                    //if enemy vessel is a fort, calculate firepower
                        if (enemy_vessel._IAmFort)
                            new_firepower -= normalizedFirePowerValue(enemy_vessel._Guns, 1, AmmoRoundShot);
                        else //not a fort, so update boarding strength around it
                            new_boarding -= normalizedBoardingStrength(enemy_vessel);
                        
                        //add enemy vessel as a target to be shot at - even when it's not a fort
                        //because the SHOOTER can be a fort, we will remove targets at distance 1
                        //for non-forts at the time of position ai hints creation
                        
                        AITargetData * aitd = [[AITargetData alloc] initWithShip: enemy_vessel
                                                                        Distance: distance ];
                        [hex._AIValues._ShipsInRange addObject: aitd];
                        
                        //memory warning
                        [aitd release];                        

                    }
					break;
				
                case 2:
                case 3:
                case 4:
                case 5:
                    //add enemy vessel as target
                    {
                        AITargetData * aitd = [[AITargetData alloc] initWithShip: enemy_vessel
                                                                    Distance: distance ];
                        [hex._AIValues._ShipsInRange addObject: aitd];
                    
                        //memory warning
                        [aitd release];

                        //calculate hint
                        new_firepower -= normalizedFirePowerValue(enemy_vessel._Guns, distance, AmmoRoundShot);
                    }
                    break;
                    
                case 6:
                case 7:
                    //calculate firepower if not a fort 'cause forts do not move
                    if (! enemy_vessel._IAmFort)
                        new_firepower -= normalizedFirePowerValue(enemy_vessel._Guns, distance, AmmoRoundShot);
                    
                    break;
            }
			
			//NSLog(@"Hex %3d (dist:%d) oldFP:%3d  newFP:%3d LOSBLOCK:%d", 
			//	  hex._HexID, distance, current_firepower, new_firepower, losblocked);
			
			//insert new firepower hint value (if it has changed, else don't bother)
			if (new_firepower != current_firepower)
			{
				NSNumber * new_firepower_hint = [NSNumber numberWithInt:new_firepower];
				[hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_EnemyFirepower
													   withObject: new_firepower_hint ];
            }
			
			//insert new boarding hint value (if it has changed, else don't bother)
			if (new_boarding != current_boarding)
			{
				NSNumber * new_boarding_hint = [NSNumber numberWithInt:new_boarding];
				[hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_EnemyBoardingStrength
													   withObject: new_boarding_hint ];
			}
			
		}
		
		//get ready for new neighbourhood dict
		[neighbours release];
	}
	
	//update upwind/downwind bonus
	
    
    //AS OF AI 1.1 this is not longet required
    /*
	//check for distance to enemy vessels
	for (Hex * hex in _HexArray)
	{		
		int temp_dist, distance_min = 9999;
		
		for (Ship * enemy_ship in enemy_ships)
		{
			temp_dist = [self fastHexDistanceForHexID: hex._HexID
											 andHexID: enemy_ship._CurrentHex._HexID ];
			
			if (temp_dist < distance_min) distance_min = temp_dist;
		}

		NSNumber * new_distance_hint = [NSNumber numberWithInt: distance_min];
		[hex._AIValues._AIHintValues replaceObjectAtIndex: AIHint_DistanceToNearestEnemy
											   withObject: new_distance_hint ];
	}
    */
}

static inline AStarNode * getLowestFCostNodeFrom(NSDictionary * node_dict)
{
    NSArray * nodes = [node_dict allValues];
    
    AStarNode * retval = [nodes objectAtIndex:0];
    
    for (AStarNode * asn in nodes)
    {
        if (asn._Fcost < retval._Fcost) retval = asn;
    }
    
    return retval;
}


/* gets path to target using AStar algorithm */
- (NSArray *) getAStarPathFromHex:(Hex *) origin
                            toHex:(Hex *) destination
                          bigShip:(BOOL) big_ship
                   courseAtOrigin:(HexDirection) course
{
    NSLog(@"Searching for path between %d and %d for shipsize %d", origin._HexID, destination._HexID, big_ship);
        
    NSMutableDictionary * open_nodes = [NSMutableDictionary dictionaryWithCapacity:50];
    NSMutableDictionary * closed_nodes = [NSMutableDictionary dictionaryWithCapacity:50];
    
    int max_normal_turns = 2;
    if (big_ship) max_normal_turns = 1;
    
    bool destination_reached = NO;
        
    //add first node to open nodes
    int raw_hex_dist = [self fastHexDistanceForHexID:origin._HexID andHexID:destination._HexID];
    AStarNode * initial_node = [[AStarNode alloc] initWithHID:origin._HexID pHID: -1 gCost: 0 hCost:raw_hex_dist direction:course];
    [open_nodes setObject:initial_node forKey:initial_node._Key];
    [initial_node release];
    
    //the algorithm itself
    while ([open_nodes count] > 0)
    {
        //find lowest Fcost node
        AStarNode * active_node = getLowestFCostNodeFrom(open_nodes);
        
        //add to closed, remove from open
        [closed_nodes setObject:active_node forKey: active_node._Key];
        [open_nodes removeObjectForKey: active_node._Key];
        
        //NSLog(@"Active node id: %d, moved to closed list", active_node._HexID);
        
        //check for reaching the target hex
        if (active_node._HexID == destination._HexID)
        {
            //NSLog(@"Destination reached!");
            destination_reached = YES;
            break;
        }
        
        //get neighbours
        NSArray * active_neighbours = [((Hex *)[_HexArray objectAtIndex: active_node._HexID]) GetNeighbours];
        
        //NSLog(@"%d neighbours to process...", [active_neighbours count]);
        
        //iterate over them
        for (Hex * hex in active_neighbours)
        {
            //if hex impassable, continue
            if (hex._Terrain == TerrainLand || hex._Terrain == TerrainRocks || 
                (hex._Terrain == TerrainShallowWater && big_ship && hex._HexID != destination._HexID)) 
            {
                //NSLog(@"Ignoring hex %d because of terrain type", hex._HexID);
                
                //but - it may be the target hex - if it is a fort! so:
                if (hex._HexID != destination._HexID) continue;
            }
            
            //if hex is next to a immobilized friendly ship but not a fort - it is impassable
            bool immo_detected = NO;
            for (Hex * immo_check_hex in [hex GetNeighbours])
            {
                if ((immo_check_hex._ShipInHex != nil) && !immo_check_hex._ShipInHex._IAmFort && (immo_check_hex._ShipInHex._MovePoints == 0))
                {
                    NSLog(@"Immobilized ship (%@) was detected at hex %d", immo_check_hex._ShipInHex, immo_check_hex._HexID);
                    immo_detected = YES;
                    break;
                }
            }
            if (immo_detected) 
            {
                NSLog(@"Ignoring hex %d because an immobilized ship was detected", hex._HexID);
                continue;
            }
            
            //if hex on the closed list, continue
            if ([closed_nodes objectForKey: hex._HexIDObject] != nil)
            {
                //NSLog(@"Ignoring hex %d because it is already on the closed list", hex._HexID);
                continue;
            }
            
            //NSLog(@"Processing hex %d", hex._HexID);
            
            AStarNode * old_node = [open_nodes objectForKey: hex._HexIDObject];
            //if not on the open list, add it
            if (old_node == nil)
            {
                int raw_hex_dist = [self fastHexDistanceForHexID:hex._HexID 
                                                        andHexID:destination._HexID];
                
                //calculate cost of reaching this node
                Hex * active_node_hex = [_HexArray objectAtIndex:active_node._HexID];

                //calculate the MP cost of moving from active node hex to this hex
                int gcost = [self calculateMPcostForCourse: [active_node_hex getDirectionOfNeighbourID:hex._HexID]
                                                   bigShip: big_ship ];
                                
                //if direction from active_node_hex to THIS hex is NOT THE SAME as direction stored in active_node,
                //it means that a turn has to be made, thus increasing the gcost
                HexDirection fromActiveToThis = [active_node_hex getDirectionOfNeighbourID:hex._HexID];
                int gcost_of_turning = ABS( course_change_required(fromActiveToThis, active_node._DirectionInNode) );
                gcost += gcost_of_turning;
                
                //increase gcost if turning this hard would cause a ship to make an emergency turn
                if (AppWideSettings._RealisticModeOn && (gcost_of_turning > max_normal_turns)) 
                {
                    gcost += 1;
                    //NSLog(@"Increasing Gcost further for emergency turn!");
                }
                
                AStarNode * new_node = [[AStarNode alloc] initWithHID: hex._HexID 
                                                                 pHID: active_node._HexID
                                                                gCost: gcost + active_node._Gcost
                                                                hCost: raw_hex_dist
                                                            direction: fromActiveToThis];
                
                //NSLog(@"Added to open list, node for hex %d, with gcost %d", hex._HexID, gcost + active_node._Gcost);
                
                [open_nodes setObject:new_node forKey:new_node._Key];
                [new_node release];
                
                //NSLog(@"Added node for hex %d to open nodes.", new_node._HexID);
            }
            else
            {                
                Hex * active_node_hex = [_HexArray objectAtIndex:active_node._HexID];

                //neighbourhood node exists on the open list - so modify it if it has worse g cost
                //calculate by addint cost of moving from THIS hex to the old hex, plus the cost to get to THIS hex
                int new_gcost = active_node._Gcost + [self calculateMPcostForCourse: [active_node_hex getDirectionOfNeighbourID:old_node._HexID] 
                                                                            bigShip: big_ship ];

                //check if turning is required, if so, increase gcost by turns needed
                HexDirection fromActiveToOld = [active_node_hex getDirectionOfNeighbourID: old_node._HexID];
                int gcost_of_turning = ABS( course_change_required(fromActiveToOld, active_node._DirectionInNode) );
                new_gcost += gcost_of_turning;
                
                //increase gcost if turning this hard would cause a ship to make an emergency turn
                if (AppWideSettings._RealisticModeOn && (gcost_of_turning > max_normal_turns))
                {
                    new_gcost += 1;
                    //NSLog(@"Increasing Gcost further for emergency turn!");
                }

                
                if (old_node._Gcost > new_gcost)
                {
                    old_node._Gcost = new_gcost;
                    old_node._ParentHexID = active_node._HexID;
                    old_node._DirectionInNode = fromActiveToOld;
                    
                    //NSLog(@"Updated Gcost for node of hex %d to %d", old_node._HexID, new_gcost);
                }
            }
        }//finished iterating over active node neighbours
    }//break by reaching target or no open nodes left
    
    if (destination_reached)
    {
        NSMutableArray * retval = [NSMutableArray arrayWithCapacity:25];
                
        NSNumber * hid = destination._HexIDObject;
        
        while ([hid intValue] != origin._HexID)
        {
            AStarNode * node = [closed_nodes objectForKey:hid];
            [retval insertObject: node._Key atIndex: 0];
            hid = [NSNumber numberWithInt: node._ParentHexID];
        }
        
        NSLog(@"The path: ");
        
        //the right order...
        for (NSNumber * n in retval)
        {
            NSLog(@"Hex: %d", [n intValue]);
        }

        return retval;
    }
    else
    {
        NSLog(@"Target Unreachable");
        
        return nil;
    }
    
    //NSLog(@"********");
}

static inline int course_change_required(HexDirection course, HexDirection desired_course)
{    
    //check if we can reach desired course by 3 course increases (TURNS RIGHT)
    for (int i = 0; i <= 3; i++)
    {
        if (((course + i) % DIRECTION_MAX) == desired_course) return i;
    }
    
    //check if we can reach course by 3 desired_course increases (TURNS LEFT)
    for (int i = 0; i <= 3; i++)
    {
        if (((desired_course + i) % DIRECTION_MAX) == course) return -i;
    }
    
    NSLog(@"OOOOPS!");
    
    return 0;
}

- (bool) transformAStarPath:(NSArray *) astarpath
                  toWarpath:(NSMutableArray *) warpath
                    forShip:(Ship *) ship
{
    //create our dummy ship
    Ship * dummy = [[Ship alloc] init];
    [dummy set_ID:              ship._ID];
    [dummy set_Course:          ship._Course];
    [dummy set_CurrentHex:      ship._CurrentHex];
    [dummy set_MovePointsLeft:  ship._MovePointsLeft ];
    [dummy set_TurnPointsLeft:  ship._TurnPointsLeft ];
    [dummy set_NTurnsMade:      ship._NTurnsMade];
    [dummy set_BigShip:         ship._BigShip];
    [dummy set_Side:            ship._Side];
    [dummy set_Dummy:           YES];

    bool blocked = NO;
    int next_hex_index = 0;
    
    while (! blocked && dummy._MovePointsLeft > 0 && next_hex_index < [astarpath count])
    {
        Hex * next_hex = [_HexArray objectAtIndex: [[astarpath objectAtIndex:next_hex_index] intValue] ];
        //turn to face next hex
        int course_diff = course_change_required(dummy._Course, [dummy._CurrentHex getDirectionOfNeighbourID: next_hex._HexID]);
        
        NSLog(@"Course diffirence: %d", course_diff);
        
        while (course_diff != 0 && dummy._MovePointsLeft > 0 && dummy._TurnPointsLeft > 0)
        {
            if (course_diff > 0)
            {
                NSLog(@"Turning Right!");
                MoveCommand * mc = [[MoveCommand alloc] initWithCommandType:MoveCommand_TurnRight];
                dummy._Course = (dummy._Course + 1) % DIRECTION_MAX;
                [warpath addObject:mc];
                [mc release];
                course_diff--;
            }
            
            if (course_diff < 0)
            {
                NSLog(@"Turning LEFT!");
                MoveCommand * mc = [[MoveCommand alloc] initWithCommandType:MoveCommand_TurnLeft];
                if (dummy._Course == 0) dummy._Course = 5;
                else dummy._Course--;
                [warpath addObject:mc];
                [mc release];
                course_diff++;
            }
            
            int mp_cost = 1;
            if (AppWideSettings._RealisticModeOn)
            {
                if (dummy._NTurnsMade >= dummy._MaxNormalTurns) mp_cost = dummy._MovePointsLeft;
            }
            
            dummy._NTurnsMade++;
            dummy._MovePointsLeft -= mp_cost;
            dummy._TurnPointsLeft--;
        }
        
        //if we could not reach the desired direction, we are done here, and the path is optimal:
        //we were not blocked by anything else than this ship's limitations
        if (course_diff != 0) 
        {
            NSLog(@"Could not turn to desired course!");
            return NO;
        }
        
        //lets try to move to the next hex, but first check if we have MP's left
        int move_cost = [self calculateMPcostForShip:dummy];
        
        NSLog(@"Move cost calculated: %d", move_cost);
        
        if (move_cost > dummy._MovePointsLeft)
        {
            NSLog(@"Not enough move points to execute this move... %d > %d", move_cost, dummy._MovePointsLeft);
            return NO;
        }

        //check if movement is possible
        MoveResult mr = [self canMoveShip: dummy];
        
        if (mr != MoveImpossible)
        {
            NSLog(@"Moving");
            dummy._MovePointsLeft -= move_cost;
            dummy._NTurnsMade--;
            dummy._CurrentHex = next_hex;
            next_hex_index++;
            
            MoveCommand * mc = [[MoveCommand alloc] initWithCommandType:MoveCommand_MoveAhead];
            [warpath addObject:mc];
            [mc release];
        }
        else
        {
            NSLog(@"Move Path is blocked!");
            return YES;
        }
    }
    
    //quitting the loop may mean two things - path is blocked, or target has been reached
    
    return blocked;
}



					/****************
					 *	UTILITIES	*
					 ****************/

/* Translate cooridnates into hex designator */
- (int) TranslateRowNum:(int) rowno
			   HexInRow:(int) hrw
{	
	return rowno * _HexesPerRow - (rowno / 2) + hrw;
}

/* called to break up boardings that the ship may be involved in */
- (void) breakupBoardingsForShip:(Ship *) ship
{
	//define other side of conflict than the sinking ship
	SideOfConflict other_side;
	if (ship._Side == RedSide) other_side = BlueSide;
	else other_side = RedSide;
	
	NSMutableArray * boardings_to_break = [[NSMutableArray alloc] initWithCapacity:3];
	
	//find boardings to break
	for (BoardingAction * breakup in _BoardingActions)
	{
		if ([breakup retrieveShipFromSide:ship._Side]._ID == ship._ID)
		{
			NSLog(@"Found a boarding, breaking it up!");
			
			//free the ship from the other side
			[[breakup retrieveShipFromSide:other_side] decreaseBoardingCount];
			
			//prepare update for ui
			UIBoardingNfo * bai = [[UIBoardingNfo alloc] initWithID: [breakup _BoardingID]];
			[_UIUpdates addObject:bai];
			
			//add to breakup list
			[boardings_to_break addObject:breakup];
		}
	}

	//remove boardings
	for (BoardingAction * br in boardings_to_break)
		[_BoardingActions removeObject:br];
	
	[boardings_to_break release];
}

/* checks if given hex is on the right side of the ship (if this returns no, it means
 the hex is on the left side of the ship)*/
- (bool) isOnTheRightHexRow:(int) target_row
				   HexInRow:(int) target_hir
				   FromShip:(Ship * )ship
{
	int orig_row = ship._CurrentHex._Row;
	int orig_hir = ship._CurrentHex._HexInRow;
	float course_degree = ship._Course * 60;
	
	const float size = 10.0;
	
	float x0 = sqrt(3) * size * orig_hir;
	float y0 = 1.5 * size * orig_row;
	if (orig_row % 2 == 1) x0 += sqrt(3) * size / 2;
	
	float x1 = sqrt(3) * size * target_hir;
	float y1 = 1.5 * size * target_row;
	if (target_row % 2 == 1) x1 += sqrt(3) * size / 2;
	
	//function parameters
	float a = tan(course_degree * M_PI / 180);
	float b = y0 - a * x0;
	
	//NSLog(@"RIGHT OR NOT: Function : F(X) = (%f)X + %f\n", a, b);
	
	switch (ship._Course) 
	{
		case LEFT:
			if (y1 < y0) return YES;
			break;
			
		case RIGHT:
			if (y1 > y0) return YES;
			break;
			
		case LEFT_UP:
		case LEFT_DOWN:
			if (y1 < (a * x1 + b)) return YES;
			break;
			
		case RIGHT_DOWN:
		case RIGHT_UP:
			if (y1 > (a * x1 + b)) return YES;			
			break;
            
        case DIRECTION_MAX:
        default:
            NSLog(@"WARNING: something fishy is going on!");
            break;
	}
	
	return NO;
}

/* helper function for Distance and LOS checking	*/
- (HexDirection) getDirI:(int) i
					   J:(int) j
{
	if (j == -1)
	{
		if (i == -1) return LEFT_UP;
		if (i == 0) return LEFT;
		if (i == 1) return RIGHT_UP;
	}
	else //j == 1
	{
		if (i == -1) return LEFT_DOWN;
		if (i == 0) return RIGHT;
		if (i == 1) return RIGHT_DOWN;
	}
	
	return 666;
}

/* actual calculating function for movement cost */
- (int) calculateMPcostForCourse:(HexDirection) course
						 bigShip:(bool) bship
{
    int retval = 100;
    
    //new, hopefully faster method
    if (course == _WindDirection) return 1;
    if (((course + 1) % DIRECTION_MAX) == _WindDirection) return 1;
    if (((_WindDirection + 1) % DIRECTION_MAX) == course) return 1;
        
    if (((course + 2) % DIRECTION_MAX) == _WindDirection) retval =  2;
    if (((_WindDirection + 2) % DIRECTION_MAX) == course) retval =  2;
        
    //realistic mode
    if (AppWideSettings._RealisticModeOn)
    {
        if (retval == 2 && bship ) return 3; 
        else return retval;
    }
    else
    {
        if ( bship ) return 100;
        else return retval;
    }
    
}


/* helper function that determines the movement cost in respect to wind */
- (int) calculateMPcostForShip:(Ship *) ship
{
	return [self calculateMPcostForCourse: ship._Course
								  bigShip: ship._BigShip ];
}

/* gets all hexes that are inside given diameter and assigns them
 a value equal to distance from original hex */
- (NSDictionary *) getHexNeighbourhoodWithDistances:(Hex *) hex
									 withinDiameter:(int) diam
{
	NSMutableDictionary * ret_dict = [[NSMutableDictionary alloc] initWithCapacity: 3.2 * (diam * diam)];
	
    Hex * upwards = hex;
    Hex * downwards = [hex GetHexNeighbourAtDirection:RIGHT_DOWN];
        
    Hex * rightwards;
    Hex * leftwards;
    
    //add all hex in origin row and up
    for (int up_diam = 0; up_diam <= diam; up_diam++)
    {
        //NSLog(@"up_diam = %d", up_diam);
        
        //check for hitting the map edge
        if (upwards == nil) break;
        
        //right limit = diam - 1 for every TWO steps up/down
        
        //decide on limits for left/right traversing
        int right_limit = diam - ((1 + up_diam)/2);
        int left_limit = diam - ((1 + up_diam)/2);
        int left_distance_mod = 0;
        if (up_diam % 2 != 0)
        {
            left_limit++;
            left_distance_mod = 1;
        }
        
        //set orignal traversing hexes
        rightwards = upwards;
        leftwards = [upwards GetHexNeighbourAtDirection:LEFT];
        
        //add hexes on the right
        for (int r = 0; r <= right_limit; r++)
        {
            //check if hex exists
            if (rightwards == nil) break;
            
            //NSLog(@"Adding hex %d at distance %d", rightwards._HexID, max(r + ((1 + up_diam)/2), up_diam));
            
            //store it
            [ret_dict setObject: [NSNumber numberWithInt: MAX(r + ((1 + up_diam)/2), up_diam)] 
                         forKey: rightwards._HexIDObject ];
            
            //move further right
            rightwards = [rightwards GetHexNeighbourAtDirection: RIGHT];    
        }
        
        //add hexes on the left
        for (int l = 1; l <= left_limit; l++)
        {
            //check if hex exists
            if (leftwards == nil) break;

            //NSLog(@"Adding hex %d at distance %d", leftwards._HexID, max(l - left_distance_mod + ((1 + up_diam)/2), up_diam));

            //store it
            [ret_dict setObject: [NSNumber numberWithInt: MAX(l - left_distance_mod + ((1 + up_diam)/2), up_diam)] 
                         forKey: leftwards._HexIDObject ];
            
            //move further left
            leftwards = [leftwards GetHexNeighbourAtDirection: LEFT];
        }
        
        //update original hex (distance gets updated automatically - it's in the for loops condition)
        if (up_diam % 2 == 0) upwards = [upwards GetHexNeighbourAtDirection:RIGHT_UP];
        else upwards = [upwards GetHexNeighbourAtDirection:LEFT_UP];
        
        //NSLog(@"Moved upwards to hex %d", upwards._HexID);
    }
    
    //and now the same but downwards
    for (int down_diam = 1; down_diam <= diam; down_diam++)
    {
        //NSLog(@"down_diam = %d", down_diam);
        
        //check for hitting the map edge
        if (downwards == nil) break;
        
        //right limit = diam - 1 for every TWO steps up/down
        
        //decide on limits for left/right traversing
        int right_limit = diam - ((1 + down_diam)/2);
        int left_limit = diam - ((1 + down_diam)/2);
        int left_distance_mod = 0;
        if (down_diam % 2 != 0)
        {
            left_limit++;
            left_distance_mod = 1;
        }
        
        //set orignal traversing hexes
        rightwards = downwards;
        leftwards = [downwards GetHexNeighbourAtDirection:LEFT];
        
        //add hexes on the right
        for (int r = 0; r <= right_limit; r++)
        {
            //check if hex exists
            if (rightwards == nil) break;
            
            //NSLog(@"Adding hex %d at distance %d", rightwards._HexID, max(r + ((1 + down_diam)/2), down_diam));
            
            //store it
            [ret_dict setObject: [NSNumber numberWithInt: MAX(r + ((1 + down_diam)/2), down_diam)] 
                         forKey: rightwards._HexIDObject ];
            
            //move further right
            rightwards = [rightwards GetHexNeighbourAtDirection: RIGHT];    
        }
        
        //add hexes on the left
        for (int l = 1; l <= left_limit; l++)
        {
            //check if hex exists
            if (leftwards == nil) break;
            
            //NSLog(@"Adding hex %d at distance %d", leftwards._HexID, max(l - left_distance_mod + ((1 + down_diam)/2), down_diam));
            
            //store it
            [ret_dict setObject: [NSNumber numberWithInt: MAX(l - left_distance_mod + ((1 + down_diam)/2), down_diam)] 
                         forKey: leftwards._HexIDObject ];
            
            //move further left
            leftwards = [leftwards GetHexNeighbourAtDirection: LEFT];
        }
        
        //update original hex (distance gets updated automatically - it's in the for loops condition)
        if (down_diam % 2 == 0) downwards = [downwards GetHexNeighbourAtDirection:RIGHT_DOWN];
        else downwards = [downwards GetHexNeighbourAtDirection:LEFT_DOWN];
        
        //NSLog(@"Moved downwards to hex %d", upwards._HexID);
    }
    
/*
    //old method
    NSMutableDictionary * wanderer = [[NSMutableDictionary alloc] init];
	[self getHexNeighbourhoodWithDistances: hex
							withinDiameter: diam
						   currentDistance: 0
								   useDict: wanderer];
    
    //compare results
    NSLog(@"Keys in old dict: %d, keys in new dict: %d", [[wanderer allKeys] count],[[ret_dict allKeys] count]);
    bool all_ok = YES;
    
    //NSLog(@"HEX OLD NEW");
    for (NSNumber * key in [[wanderer allKeys] sortedArrayUsingSelector:@selector(compare:)])
    {
       // NSLog(@"%3d %3d %3d", [key intValue], [[wanderer objectForKey:key] intValue], [[ret_dict objectForKey:key] intValue]);
        if ([[wanderer objectForKey:key] intValue] != [[ret_dict objectForKey:key] intValue]) all_ok = NO;
    }

    if (all_ok) NSLog(@"ALL OK!");
    else NSLog(@"FAILED!");
 */
 
    return ret_dict;
}


/* crawler function for getting reachable hexes */
- (void) getReachablePositionsForShip:(Ship *) ship
							   useSet:(NSMutableSet *) wandering_set
					  currentPosition:(ReachablePosition *) cur_pos
{
	/*
	 algorithm for fiding all reachable hexes:
		if able to turn - turn left, add that position
		then move forward and add that position
		then turn right (if able to) and add that position)
	 */
	
	//add myself
	[wandering_set addObject:cur_pos];
	
	if (cur_pos._MPLeftAtDestination > 0)
	{
		//check if turning is possible
		if (cur_pos._TPLeftAtDestination > 0)
		{
			//if the last move performed was TR, it would be stupid to TL
			MoveCommand * lmc = (MoveCommand *)[cur_pos._WayToGetToDestination lastObject];
			if (lmc == nil || lmc._move != MoveCommand_TurnRight)
			{
				//turn left
				MoveCommand * turn_left = [[MoveCommand alloc] initWithCommandType: MoveCommand_TurnLeft];
                int mp_cost = 1;

				if (AppWideSettings._RealisticModeOn)
                {
                    if (cur_pos._NTurnsAtDestination >= ship._MaxNormalTurns) mp_cost = cur_pos._MPLeftAtDestination;
                }
                
				ReachablePosition * new_pos_tl = [[ReachablePosition alloc] initWithPosition: cur_pos
                                                                                     command: turn_left
                                                                                    moveCost: mp_cost];

                //NSLog(@"Was at %@, moving to %@ by turning LEFT with cost: %d", cur_pos, new_pos_tl, mp_cost);
                
				[self getReachablePositionsForShip: ship
											useSet: wandering_set
								   currentPosition: new_pos_tl];
			}
			
			//check if last move was not TL (cause it would be stupid to TR right after)
			if (lmc == nil || lmc._move != MoveCommand_TurnLeft)
			{
				//turn right
				MoveCommand * turn_right = [[MoveCommand alloc] initWithCommandType: MoveCommand_TurnRight];
                int mp_cost = 1;

				if (AppWideSettings._RealisticModeOn)
                {
                    if (cur_pos._NTurnsAtDestination >= ship._MaxNormalTurns) mp_cost = cur_pos._MPLeftAtDestination;
                }
                 
                ReachablePosition * new_pos_tr = [[ReachablePosition alloc] initWithPosition: cur_pos
                                                                                     command: turn_right
                                                                                    moveCost: mp_cost];

                //NSLog(@"Was at %@, moving to %@ by turning RIGHT with cost: %d", cur_pos, new_pos_tr, mp_cost);

				[self getReachablePositionsForShip: ship
											useSet: wandering_set
								   currentPosition: new_pos_tr];
			}		
		}
		
		//special turning case, when ships TPs been reduced to zero
		if (cur_pos._MPLeftAtDestination == ship._MovePoints && ship._TurnPoints == 0)
		{
			NSLog(@"SKYNET: analyzing emergency turns!");
			
			//emergency left
			MoveCommand * emerg_left = [[MoveCommand alloc] initWithCommandType: MoveCommand_TurnLeft];
			ReachablePosition * new_pos_etl = [[ReachablePosition alloc] initWithPosition: cur_pos
																				  command: emerg_left
																				 moveCost: ship._MovePoints];
            
			[self getReachablePositionsForShip: ship
										useSet: wandering_set
							   currentPosition: new_pos_etl];
			
			//emergency right
			MoveCommand * emerg_right = [[MoveCommand alloc] initWithCommandType: MoveCommand_TurnRight];
			ReachablePosition * new_pos_etr = [[ReachablePosition alloc] initWithPosition: cur_pos
																				  command: emerg_right
																				 moveCost: ship._MovePoints];
            
			[self getReachablePositionsForShip: ship
										useSet: wandering_set
							   currentPosition: new_pos_etr];
			
			
		}
		
		//check if we can move ahead
		Hex * hex_ahead = [cur_pos._Destination GetHexNeighbourAtDirection:cur_pos._CourseAtDestination];

		//check if there even is a hex ahead
		if (hex_ahead == nil) return;
		
		//test for impassable terrain
		if (hex_ahead._Terrain == TerrainLand || hex_ahead._Terrain == TerrainRocks) return;
		if (hex_ahead._Terrain == TerrainShallowWater && ship._BigShip) return;	//AI will never beach itself
		
		//test for ships in vicinity
		bool boarding_flag = NO;
		for (int i = 0; i < DIRECTION_MAX; i++) 
		{
			Hex * neighbour = [hex_ahead GetHexNeighbourAtDirection:i];
			
			//check if ship is present at neighbour
			Ship * ship_at_neighbour = neighbour._ShipInHex;
			if (ship_at_neighbour != nil)
			{
				//a ship present, but an enemy ship is ok
				//it is also ok, if that ship is the ship that is being tested
				if (ship_at_neighbour._Side == ship._Side && ship_at_neighbour._ID != ship._ID) return;
				if (ship_at_neighbour._Side != ship._Side) boarding_flag = YES;
			}
		}
		
		//check for movement against the wind
		int move_cost = [self calculateMPcostForCourse: cur_pos._CourseAtDestination
											   bigShip: ship._BigShip ];
		
		//NSLog(@"At hex: %d mp_cost: %d", cur_pos._Destination._HexID, move_cost);
		
		//movement impossible due to wind
		if (move_cost == 0 || move_cost > cur_pos._MPLeftAtDestination) return;
		
		//if boarding, this will be the last move
		if (boarding_flag) move_cost = cur_pos._MPLeftAtDestination;
		
		//move ahead
		MoveCommand * move_ahead = [[MoveCommand alloc] initWithCommandType: MoveCommand_MoveAhead];
		ReachablePosition * new_pos_go = [[ReachablePosition alloc] initWithPosition: cur_pos
																			 command: move_ahead
																			moveCost: move_cost];

		[self getReachablePositionsForShip: ship
									useSet: wandering_set
						   currentPosition: new_pos_go];		
	}
		
}

/* Gets all hexes that can be reached by given ship */
- (NSSet *) getReachablePositionsSetForShip:(Ship *) ship
{
	NSMutableSet * wandering_set = [[NSMutableSet alloc] init];
		
	//create current position
	ReachablePosition * rp = [[ReachablePosition alloc] initWithShip:ship];
	
	//start the voyage! (current position will be added automatically)
	[self getReachablePositionsForShip: ship
								useSet: wandering_set
					   currentPosition: rp];
	
	//we should clean the set first
	//there are some (rare) cases when the same hex and course can be reached by various ways
	//that is okay, because in the end tha AI evaluates whole paths and one can be better than the other
	
	return wandering_set;
}

					/***************************
					 *	HEXBOARD MANIPULATORS  *
					 ***************************/

/* Adds a ship to hexboard and to ships table for given side */
- (void) addShip:(Ship *) ship
		   AtRow:(int) row
		HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];
	
	[[_HexArray objectAtIndex: hex_des] set_ShipInHex: ship];
	
	if (ship._Side == RedSide) [_RedSideShips addObject: ship];
	else [_BlueSideShips addObject: ship];
	
	[ship set_CurrentHex: [_HexArray objectAtIndex: hex_des]];
		
	NSLog(@"Added ship to hex %d\n", hex_des);
}


/* Removes a ship from a gven hex */
- (void) removeShipAtRow:(int) row
				HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];

	[[_HexArray objectAtIndex: hex_des] set_ShipInHex: nil];
}

/* set terrain at specified hex to specified value */
- (void) SetTerrainTo:(TerrainType) terrain
			   ForRow:(int) row
			 HexInRow:(int) hri
{
	int hex_des = [self TranslateRowNum:row HexInRow:hri];

#ifdef MAPCREATOR
    switch (terrain)
    {
        case TerrainLand:
        case TerrainRocks:
        case TerrainShallowWater:
        case TerrainDeepWater:
            [[_HexArray objectAtIndex: hex_des] set_Terrain: terrain];
            [[_HexArray objectAtIndex: hex_des] set_RedObjectiveHex: NO];
            [[_HexArray objectAtIndex: hex_des] set_BlueObjectiveHex: NO];
            [[_HexArray objectAtIndex: hex_des] set_StrategicHex: NO];
            break;
            
        case TerrainOBJECTIVERED:
            [[_HexArray objectAtIndex: hex_des] set_RedObjectiveHex: YES];
            [[_HexArray objectAtIndex: hex_des] set_BlueObjectiveHex: NO];
            [[_HexArray objectAtIndex: hex_des] set_StrategicHex: YES];
            break;
            
        case TerrainOBJECTIVEBLUE:
            [[_HexArray objectAtIndex: hex_des] set_RedObjectiveHex: NO];
            [[_HexArray objectAtIndex: hex_des] set_BlueObjectiveHex: YES];
            [[_HexArray objectAtIndex: hex_des] set_StrategicHex: YES];
            break;
            
        case TerrainSTRATEGIC:
            [[_HexArray objectAtIndex: hex_des] set_RedObjectiveHex: NO];
            [[_HexArray objectAtIndex: hex_des] set_BlueObjectiveHex: NO];
            [[_HexArray objectAtIndex: hex_des] set_StrategicHex: YES];
            break;
    }
#else
    
    [[_HexArray objectAtIndex: hex_des] set_Terrain: terrain];
    
#endif
}

					/****************************
					 *	INFORMATION RETRIEVERS  *
					 ****************************/

/* gets id of the ship at given hex (0 when empty!) */
- (int) getShipIdAtRow:(int) row
			  HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];

	int retval = 0;
	
	//NSLog(@"Checking for ships at hex %d\n", hex_des);

	if ([[_HexArray objectAtIndex: hex_des] _ShipInHex] != nil)
	{
		retval = [[[_HexArray objectAtIndex: hex_des] _ShipInHex] _ID];
		//NSLog(@"HexBoard found a ship here.\n");
	}
	
	return retval;
}

- (MoveResult) canMoveShip:(Ship *) ship
{
    Hex * oldhex = ship._CurrentHex;
    Hex * newhex = [oldhex GetHexNeighbourAtDirection: ship._Course];
    
	bool beached_flag = NO;
    
    //check for hex existing
    if (newhex == nil) return MoveImpossible;
    
    //check terrain
    switch (newhex._Terrain) 
    {
        case TerrainDeepWater:
            //nothing to be done here
            break;

        case TerrainShallowWater:
            if (ship._BigShip) beached_flag = YES;
            break;
            
        case TerrainLand:
        case TerrainRocks:
            return MoveImpossible;
            break;
            
        default:
            break;
    }
    
    //move cost calculation
    if ([self calculateMPcostForShip: ship] > ship._MovePointsLeft)
    {
        return MoveImpossible;
    }
    
    //check for ships around target hex
    
    for (Hex * neigh in [newhex GetNeighbours])
    {
        if (neigh._ShipInHex != nil)
        {
            //ignore myself
            if (neigh._ShipInHex._ID == ship._ID) continue;
            
            if (neigh._ShipInHex._Side == ship._Side)
            {
                //can't move cause friendlies are in the way
                return MoveImpossible;
            }
            else
            {
                //boarding!
                if (beached_flag) return MoveBeachedAndBoarding;
                else return MoveBoarding;
            }
        }// ship in hex
    }//all neighbours
    
    //if we're here, there are no neighbouring ships, and move cost has been calculated and deemed ok
    if (beached_flag) return MoveBeached;
    else return MoveOk;
}

- (TurningAbility) canShipTurn:(Ship *) ship
{
    // *********** classic mode ***********
    if (! AppWideSettings._RealisticModeOn)
    {
        if (ship._TurnPointsLeft > 0 && ship._MovePointsLeft > 0)
        {
            //both stats are > 0, so the lower one limits the turns
            return MIN(ship._TurnPointsLeft, ship._MovePointsLeft);
        }
        else
        {
            if (ship._MovePointsLeft == ship._MovePoints && ship._MovePoints != 0) return TurnEmergency;
        }
    }
    else  // *********** realistic mode ***********
    {
        if (ship._TurnPointsLeft > 0 && ship._MovePointsLeft > 0)
        {
            if (ship._NTurnsMade >= ship._MaxNormalTurns) return TurnEmergency;
            else return MIN(ship._MaxNormalTurns - ship._NTurnsMade, MIN(ship._TurnPointsLeft, ship._MovePointsLeft));
        }
        else
        {
            if (ship._MovePointsLeft == ship._MovePoints && ship._MovePoints != 0) return TurnEmergency;
        }
    }
    
    return TurnImpossible;
}


/* returns what will be the result of moving a ship at specified hex */
- (MoveResult) CanMoveShipAtRow:(int) row
						 AndHex:(int) hrw
                   ignoreMPCost:(bool) no_mp_cost
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];
	
	bool boarding_flag = NO;
	bool beached_flag = NO;
	
	//get the start hex
	Hex * oldhex = [_HexArray objectAtIndex: hex_des];
	
	//get the pointer to ship in oldhex
	Ship * tempship = [oldhex _ShipInHex];
	
	//get the destitnation hex by checking neighbnour of oldhex on course of the ship
	Hex * newhex = [oldhex GetHexNeighbourAtDirection: [tempship _Course] ];
	
	//first check if hex on course even exists
	if (newhex == nil) return MoveImpossible;
	
	//check the terrain type
	if ([newhex _Terrain] == TerrainRocks || [newhex _Terrain] == TerrainLand)
		return MoveImpossible;
	
    //ERROR HERE ADD ROUTINE TO DISABLE MP_COST CHECKING
    
	//now check if we can move, due to wind
    int mp_cost;
	if (no_mp_cost) mp_cost = 0 ;
    else mp_cost = [self calculateMPcostForShip:tempship];
    
	if (mp_cost > tempship._MovePointsLeft)
	{
		NSLog(@"Movement impossible due to wind!");
		return MoveImpossible;
	}
	
	SideOfConflict tempside = [tempship _Side];
	
	//check if friendly ships present around newhex, but whatch out for tempship!
	//also check for enemy ships to be boarded!
	for (int i = 0; i < DIRECTION_MAX; i++)
	{
		Hex * temphex = [newhex GetHexNeighbourAtDirection: i];
		
		//check if temphex hex exists!
		if (temphex != nil)
		{
			//check if ship is present, and isn't tempship herself! Also, ignore forts.
			if ( temphex._ShipInHex != nil && temphex._ShipInHex._ID != tempship._ID && ! temphex._ShipInHex._IAmFort)
			{
				//if friendlies present, may not move!
				if ([[temphex _ShipInHex] _Side] == tempside) return MoveImpossible;
                //but if enemies present, boarding may ensue!
				else boarding_flag = YES;
			}
		}
	}
	
	//last thing - check for shallow water, but only for bigships
	if ([newhex _Terrain] == TerrainShallowWater && [tempship _BigShip])
		beached_flag = YES;
	
	if (boarding_flag && beached_flag) return MoveBeachedAndBoarding;
	if (boarding_flag) return MoveBoarding;
	if (beached_flag) return MoveBeached;
	return MoveOk;
}

/* get ship pointer at given row and hex */
- (Ship *) getShipAtRow:(int) row
			   HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];

	//called after cheking that ship is present, so just return the pointer
	return [[_HexArray objectAtIndex: hex_des] _ShipInHex];
}

- (TerrainType) getTerrainOfRow:(int) row
					   HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];
	
	return [[_HexArray objectAtIndex: hex_des] _Terrain];	
}

#ifdef MAPVIEW_MARKERS

- (bool) getObjectiveAtRow:(int)row 
                  HexInRow:(int)hex
{
	int hex_des = [self TranslateRowNum:row HexInRow:hex];
	
	return ([[_HexArray objectAtIndex: hex_des] _RedObjectiveHex] || [[_HexArray objectAtIndex: hex_des] _BlueObjectiveHex]);
}

- (bool) getStrategicAtRow:(int)row 
                  HexInRow:(int)hex
{
	int hex_des = [self TranslateRowNum:row HexInRow:hex];
	
	return [[_HexArray objectAtIndex: hex_des] _StrategicHex];
}

- (bool) getDefensiveAtRow:(int)row 
                  HexInRow:(int)hex
{
	int hex_des = [self TranslateRowNum:row HexInRow:hex];
	
	return [[_HexArray objectAtIndex: hex_des] _DefendThisHex];
}

#endif

/* getsnext ship that has not finished turn yet or nil if no such ship found */
- (Ship *) GetNextShipFrom:(Ship *) current_ship
                   ForSide:(SideOfConflict) sd
{	
	NSLog(@"Searching for next ship...\n");
	
    NSMutableArray * current_ships;
    
    if (sd == RedSide) current_ships = _RedSideShips;
    else current_ships = _BlueSideShips;
 
    if (current_ship == nil)
    {
        for (Ship * ship in current_ships)
        {
            if (! ship._FinishedMove) return ship;
        }
        
        //no active ships found
        return nil;
        
    }
    else
    {
        int index_of_current_ship = [current_ships indexOfObject:current_ship];
        
        for (int i = 1; i < [current_ships count]; i++)
        {
            int index_to_check = (i + index_of_current_ship) % [current_ships count];
            
            Ship * ship = [current_ships objectAtIndex:index_to_check];
            if (! ship._FinishedMove) return ship;
        }
        
        //no active ships found
        return nil;
    }
}

- (Ship *) GetMostImportantShipForSide:(SideOfConflict) sd
{
    Ship * p_cargoship = nil;
    Ship * p_flaghsip = nil;
    Ship * p_capital = nil;    
    
    NSLog(@"Searching for important ship...\n");
	
    NSMutableArray * current_ships;
    
    if (sd == RedSide) current_ships = _RedSideShips;
    else current_ships = _BlueSideShips;

    //try to find cargoship, flagship or just a capital ship
    for (Ship * ship in current_ships)
    {
        if (ship._IAmCargoShip) p_cargoship = ship;
        if (ship._IAmFlagship) p_flaghsip = ship;
        if (ship._Class == ClassCapital) p_capital = ship;
    }
    
    //return anything of value
    if (p_cargoship) return p_cargoship;
    if (p_flaghsip) return p_flaghsip;
    if (p_capital) return p_capital;
    
    NSLog(@"None found...");
    
    //no important ship found, just return the first one...
    return [self GetNextShipFrom:nil
                         ForSide:sd];
}

/* calls for retrieving damadge infos */
- (NSObject *) retrieveLastUIUpdate
{
	if ([_UIUpdates count] > 0)
	{
		NSObject * pRetval = [_UIUpdates objectAtIndex:0];
		
		[_UIUpdates removeObjectAtIndex:0];
		
		return pRetval;
	}
	else
	{
		NSLog(@"No updates to report!");
		return nil;
	}
}

- (FiringArc) checkFiringArcForShip:(Ship *) ship
							  ToRow:(int) target_row
						   HexInRow:(int) target_hir
{
    //assume that forts have all around firing arc
    //this arc is always the left arc
    if (ship._IAmFort) return ArcLeft;
    
	int orig_row = ship._CurrentHex._Row;
	int orig_hir = ship._CurrentHex._HexInRow;
	float course_degree = ship._Course * 60;
	
	bool on_the_right = [self isOnTheRightHexRow: target_row
										HexInRow: target_hir
										FromShip: ship];
		
	//if (on_the_right) NSLog(@"FIRING ARC SOLUTION: On the RIGHT\n");
	//else NSLog(@"FIRING ARC SOLUTION: On the LEFT\n");
	
	//for puropse of calculating angles, distance is not important, and we assume
	//a fictional coordinate system
	const float size = 10.0;
	
	float x0 = sqrt(3) * size * orig_hir;
	float y0 = 1.5 * size * orig_row;
	if (orig_row % 2 == 1) x0 += sqrt(3) * size / 2;
	
	float x1 = sqrt(3) * size * target_hir;
	float y1 = 1.5 * size * target_row;
	if (target_row % 2 == 1) x1 += sqrt(3) * size / 2;
	
	//NSLog(@"FIRING ARC SOLUTION: (x0, y0) = (%f, %f)", x0, y0);
	//NSLog(@"FIRING ARC SOLUTION: (x1, y1) = (%f, %f)\n", x1, y1);
	
	//we need to calculate real vector parameters for tested ship
	
	float vect1x = 10.0; 
	float vect1y = vect1x * tan(course_degree * M_PI / 180);
	
	float vect2x = x1 - x0;
	float vect2y = y1 - y0;
	
	//NSLog(@"FIRING ARC SOLUTION: Vector 1 coefficients: %f %f\n", vect1x, vect1y);
	//NSLog(@"FIRING ARC SOLUTION: Vector 2 coefficients: %f %f\n", vect2x, vect2y);
	
	//calculate scalar
	float scalar = vect1x * vect2x + vect1y * vect2y;
	
	//calculate magnitudes
	float vect1mag = sqrt( (vect1x * vect1x) + (vect1y * vect1y) );
	float vect2mag = sqrt( (vect2x * vect2x) + (vect2y * vect2y) );
	
	//NSLog(@"FIRING ARC SOLUTION: Vector 2 magnitude: %f\n", vect2mag);
	
	//scalar = mag 1 * mag 2 * cos ALPHA
	//cos ALPHA = scalar / (mag1 * mag2)
	
	float cosALPHA = scalar / (vect1mag * vect2mag);
	
	//NSLog(@"FIRING ARC SOLUTION: cos(ALPHA) = %f", cosALPHA);
	
	//and the winner is
	
	float angle = (acos(cosALPHA) * 180.0 / M_PI);// - course_degree;
	
	//NSLog(@"FIRING ARC SOLUTION: calculated angle: %f\n", angle);
	
	if (on_the_right && angle > 59.0 && angle < 121.0)
	{
		//NSLog(@"In the RIGHT arc!\n");		
		return ArcRight;
	}
	
	if (!on_the_right && angle > 59.0 && angle < 121.0)
	{
		//NSLog(@"In the LEFT arc!\n");
		return ArcLeft;		
	}
	
	//NSLog(@"In NEIGHTER arc!\n");
	return ArcNone;
}

- (int) fastHexDistanceForHexID:(int) hexidA
					   andHexID:(int) hexidB
{
	Hex * hexA = [_HexArray objectAtIndex:hexidA];
	Hex * hexB = [_HexArray objectAtIndex:hexidB];
	
	int x1 = hexA._CoordX;
	int y1 = hexA._CoordY;
	int z1 = - (x1 + y1);
	
	int x2 = hexB._CoordX;
	int y2 = hexB._CoordY;
	int z2 = - (x2 + y2);
	
	int dx = x2 - x1;
	int dy = y2 - y1;
	int dz = z2 - z1;
	
	//int temp = max( abs(dx), abs(dy) );
	//int winner = max( temp, abs(dz) );
	int winner = MAX(abs(dx), MAX(abs(dy), abs(dz)) );
	
	//NSLog(@"HEXB: (%3d %3d %3d)", x2, y2, z2);
	//NSLog(@"HEXA: (%3d %3d %3d)", x1, y1, z1);
	//NSLog(@"DIFF: (%3d %3d %3d)", dx, dy, dz);
	//NSLog(@"Distance between A(%d) and B(%d) is %d", hexidA, hexidB, winner);
	//NSLog(@"-----------------------------------------------");
	
	return winner;
}

- (int) checkDistanceAndLOSForShip:(Ship *) ship
						  ToHexRow:(int) target_row
						  HexInRow:(int) target_hir
{
	int origin_row = ship._CurrentHex._Row;
	int origin_hir = ship._CurrentHex._HexInRow;
	
	bool orig_row_odd = (origin_row % 2 != 0);
	bool targ_row_odd = (target_row % 2 != 0);
	
	int orig_x = origin_hir;
	int orig_y = origin_row;
	
	int targ_x = target_hir;
	int targ_y = target_row;
	
	int delta2X = 2 * (targ_x - orig_x);
	
	if (orig_row_odd != targ_row_odd)
	{
		if (!orig_row_odd) delta2X++;
		else delta2X--;
	}
	
	int deltaY = targ_y - orig_y;
	
	//int distance = 0;
	
	int Xsig, Ysig;
	
	if (delta2X >= 0) Xsig = 1;
	else Xsig = -1;
	
	if (deltaY >=0) Ysig = 1;
	else Ysig = -1;
	
	int ox = abs(delta2X);
	int oy = abs(deltaY);
	
	int eps = -2 * ox;
	
	Hex * cur_hex = [_HexArray objectAtIndex:[self TranslateRowNum:origin_row HexInRow: origin_hir]];
	Hex * targ_hex = [_HexArray objectAtIndex:[self TranslateRowNum:target_row HexInRow: target_hir]]; 
	
	//for the distance function
	int hexID_A = cur_hex._HexID;
	int hexID_B = targ_hex._HexID;
	
	//bool dirty_workaround = NO;
	//no side blocking in this one - we assume that this is enough to obscure LOS
	
	while (cur_hex._HexID != targ_hex._HexID)
	{
		//this does not work need to detect when we move along the hex edge
		//if (ox == 0 || ox == 3 * oy )
		//{
			//distance--;
		//	dirty_workaround = YES;
		//}
		
		if (eps >= 0)   //case A
		{
            //fix for firing along the LEFT EDGE OF THE WORLD!
            Hex * new_hex = [cur_hex GetHexNeighbourAtDirection: [self getDirI: -Xsig 
                                                                             J: Ysig]];
            //NSLog(@"Case A");
            
            if (new_hex == nil) //tried to get a hex BEYOND THE EDGE
            {
                if (origin_row > target_row)
                {
                    //firing UPWARDS
                    new_hex = [cur_hex GetHexNeighbourAtDirection: RIGHT_UP];
                }
                else
                {
                    //firing DOWNWARDS
                    new_hex = [cur_hex GetHexNeighbourAtDirection: RIGHT_DOWN];

                }
                
                //fix eps as if TWO steps happened, which boils down to
                eps = eps + 3 * (oy - ox);
            }
            else
            {
                //normal operation
                eps = eps - 3 * oy - 3 * ox;                
            }
            
            cur_hex = new_hex;
			//distance++;
		} //case A
		else {
			eps = eps + 3 * oy;
			if (eps > -ox) //case B
			{
                //NSLog(@"Case B");

				cur_hex = [cur_hex GetHexNeighbourAtDirection: [self getDirI: Xsig 
																		   J: Ysig]];
				eps = eps - 3 * ox;
				//distance++;
			} //case B
			else {
				if (eps < -3 * ox) //case C
				{
                    //NSLog(@"Case C");
                    
					cur_hex = [cur_hex GetHexNeighbourAtDirection: [self getDirI: Xsig 
																			   J: -Ysig]];
					eps = eps + 3 * ox;
					//distance++;
				} //case C
				else // case D
				{
                    //NSLog(@"Case D");
                    
                    //fir for firing along the RIGHT EDGE OF THE WORLD
                    Hex * new_hex = [cur_hex GetHexNeighbourAtDirection: [self getDirI: 0 J: Xsig]];

                    if (new_hex == nil) //tried to reach a hex that is NOT OF THIS WORLD
                    {
                        if (origin_row > target_row)
                        {
                            //firing UPWARDS
                            new_hex = [cur_hex GetHexNeighbourAtDirection: RIGHT_UP];
                        }
                        else
                        {
                            //firing DOWNWARDS
                            new_hex = [cur_hex GetHexNeighbourAtDirection: RIGHT_DOWN];
                            
                        }
                        
                        //fix eps as if TWO steps happened, which boils down to
                        eps = eps - 3 * ox;
                    }
                    else
                    {
                        //normal operation
                        eps = eps + 3 * oy;
                    }
                    
					cur_hex = new_hex;
					//distance++;
				}//case D
			}// not case B
		}// not case A
		
		if (cur_hex._Terrain == TerrainLand || cur_hex._ShipInHex != nil)
		{
			//NSLog(@"LOS blocked by hex %d (row: %d hir: %d)", cur_hex._HexID, cur_hex._Row, cur_hex._HexInRow);
			//but this might be the target hex!
			if (cur_hex._HexID == targ_hex._HexID)
			{
				//NSLog(@"But thats okay, cause this is the target.\n");
				return [self fastHexDistanceForHexID: hexID_A
											andHexID: hexID_B ];
			}
			else return 0;
		}
		//else
		//{
		//	NSLog(@"Passing through hex %d (row: %d hir: %d)", cur_hex._HexID, cur_hex._Row, cur_hex._HexInRow);
		//}
	}
	
    return [self fastHexDistanceForHexID: hexID_A
                                andHexID: hexID_B ];
}

/* gets tha array of AI hint values of a given hex */
- (NSArray *) getAIHintValuesForHexRow:(int) row
							  HexInRow:(int) hir
{
	int hex_des = [self TranslateRowNum:row HexInRow:hir];
	
	return [[[_HexArray objectAtIndex: hex_des] _AIValues] _AIHintValues];
}

- (VictoryResult) checkForVictory
{
    return [_VictoryConditions checkVictoryWithRedShips:_RedSideShips BlueShips:_BlueSideShips];
}

/*  This was a good idea, but there were more problems than improvements
- (NSArray *) getObjectiveHexes
{
    NSMutableArray * retval_arr = [NSMutableArray arrayWithCapacity: 3];
    
    for (Hex * hex in _HexArray)
        if (hex._RedObjectiveHex || hex._BlueObjectiveHex)
            [retval_arr addObject: hex];
    
    return retval_arr;
}
*/

					/******************
					 *	SHIP ACTIONS  *
					 ******************/

/* moves ship at given hex (ships can only move one hex in the direction they are facing) */
- (MoveResult) moveShipAtRow:(int) row
					HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];

	MoveResult retval = [self CanMoveShipAtRow: row AndHex: hrw ignoreMPCost: NO];
	
	//this function will only be called if the ship CAN move, 
	//so no need to check anything, just do the move
	
	//get the start hex
	Hex * oldhex = [_HexArray objectAtIndex: hex_des];
	
	//get the pointer to ship in oldhex
	Ship * tempship = [oldhex _ShipInHex];

    //sanity check
    NSAssert1((tempship._MovePointsLeft > 0), @"Moving ship (%@) that has 0 Move Points Left!!!", tempship);
    
	//get the destitnation hex by checking neighbour of oldhex on course of the ship
	Hex * newhex = [oldhex GetHexNeighbourAtDirection: [tempship _Course] ];
	
	//add ship at newhex
	[newhex set_ShipInHex: tempship];
	
	//remove ship at oldhex
	[oldhex set_ShipInHex: nil];
	
	//update ship data
	[tempship set_CurrentHex: newhex];
    tempship._NTurnsMade--;       //reset turning
	
	int mp_cost = [self calculateMPcostForShip:tempship];
	
	NSLog(@"Moves MP cost calculated as %d.", mp_cost);
	
	tempship._MovePointsLeft -= mp_cost;
	
	switch (retval)
	{
		case MoveOk:
			_CanUndoLastMove = YES;
			
			[_LastMove set_ship:tempship];
			[_LastMove set_originalHex:oldhex];
            [_LastMove set_MPCost:mp_cost];
            [_LastMove set_NTurns:tempship._NTurnsMade];
			break;
			
		case MoveBeached:
			_CanUndoLastMove = NO;
			[self BeachShip: tempship];
			break;
			
		case MoveBoarding:
			_CanUndoLastMove = NO;
			[self initiateBoardingWith:tempship];
			tempship._FinishedMove = YES;
			break;
			
		case MoveBeachedAndBoarding:
			_CanUndoLastMove = NO;
			[self BeachShip: tempship];
			[self initiateBoardingWith:tempship];
			tempship._FinishedMove = YES;
			break;
            
        case MoveImpossible:
        default:
            NSLog(@"WARNING: Ship moves to a hex it shouldn't be allowed to enter!!!");
            
            break;
	}
	
    if ( tempship._IAmCargoShip && ((tempship._Side == RedSide && newhex._RedObjectiveHex) || (tempship._Side == BlueSide && newhex._BlueObjectiveHex)) ) 
    {
        return MoveToVictory;   
    }
    
    
	return retval;
}


/* turns ship at given hex left or right */
- (void) TurnShipAtRow:(int) row
			  HexInRow:(int) hrw
		   InDirection:(TurnDirection) td
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];
		
	//get the start hex
	Hex * hex = [_HexArray objectAtIndex: hex_des];
	
	//get the pointer to ship in hex
	Ship * ship = [hex _ShipInHex];	

	//sanity checks
    NSAssert((ship != nil), @"Turning non-existen ship!");
    NSAssert(((ship._MovePointsLeft > 0 && ship._TurnPointsLeft > 0) || (ship._MovePointsLeft == ship._MovePoints && ship._TurnPointsLeft == 0)), @"Turning ship that has MPs or TPs at 0!!!");
    
	HexDirection course = [ship _Course];
	
	[_LastMove set_ship:ship];
	[_LastMove set_originalCourse:course];
	[_LastMove set_originalHex:hex];
    [_LastMove set_NTurns:ship._NTurnsMade];
	_CanUndoLastMove = YES;
	
	//NSLog(@"Current course of ship (%d, %d) is: %d\n", row, hrw, course);
	
	if (td == TurnLeft) course--;
	else course++;
	
	if (course == DIRECTION_MAX) course = 0;
	if (course == -1) course = 5;
	
	[ship set_Course: course];
    
	if (ship._TurnPointsLeft <= 0 || (AppWideSettings._RealisticModeOn && ship._NTurnsMade >= ship._MaxNormalTurns))
	{
		NSLog(@"Emergency turn!");
		ship._MovePointsLeft = 0;		
	}
	else {
		ship._MovePointsLeft--;
		ship._TurnPointsLeft--;
	}

    ship._NTurnsMade++;

	//NSLog(@"Changed to: %d\n", course);

}

- (void) setShipFinishedTo:(bool) fin_status
					   Row:(int) row 
				  HexInRow:(int) hrw
{
	int hex_des = [self TranslateRowNum:row HexInRow:hrw];
	
	[[[_HexArray objectAtIndex: hex_des] _ShipInHex] set_FinishedMove:fin_status];
	
	if (fin_status) NSLog(@"Ship at (%d, %d) finished move.\n", row, hrw);
	else NSLog(@"Ship at (%d, %d) activated!\n", row, hrw);
	
}

/* call when ship becomes beached */
- (void) BeachShip:(Ship *) ship
{
	//simple check the conditions
	if (ship._CurrentHex._Terrain != TerrainShallowWater || ! ship._BigShip )
	{
		NSLog(@"Beached called for a wrong ship!\n");
		return;
	}
	
	[ship set_Beached:YES];
	[ship set_MovePointsLeft:0];
	[ship set_TurnPointsLeft:0];
	
	//inflict some boarding damage
	DamadgeInfo * pdmg = [[DamadgeInfo alloc] applyDamadgeToShip:ship
															Type:DamadgeByBeaching
														Strength:0
                                                        AmmoType:AmmoRoundShot];

	
	[_UIUpdates addObject: pdmg];
	
	/* - MAKE ME A SPERATE FUNCTION */
}

/* call when initiating boarding */
- (void) initiateBoardingWith:(Ship *) ship
{
	//no check here?

	//ship._EngagedInBoarding = YES;
	//ship._BoardingsCount++;
	ship._MovePointsLeft = 0;
	ship._TurnPointsLeft = 0;
	
	Ship * other_ship;
	
	//find the remaining ships (there actually could be two of them)
	for (int dir = 0; dir < 6; dir++)
	{
		other_ship = [[ship _CurrentHex] GetHexNeighbourAtDirection:dir]._ShipInHex;
		if (other_ship != nil)
		{
			//other_ship._EngagedInBoarding = YES;
			other_ship._BoardingsCount++;
			ship._BoardingsCount++;
			other_ship._MovePointsLeft = 0;
			other_ship._TurnPointsLeft = 0;
			
			BoardingAction * ba = [[BoardingAction alloc] 
								   initWithShip: ship
								   andWithShip:  other_ship];
			
			UIBoardingNfo * bai = [[UIBoardingNfo alloc] initWithID: [ba _BoardingID]
															  shipA: ship
															  shipB: other_ship];
			
			[_UIUpdates addObject: bai];
			
			NSLog(@"Created BA between %d and %d\n", ship._ID, other_ship._ID);
			[_BoardingActions addObject: ba];
		}
	}
}

/* calls for undo of last move, and returns id of the ship that undoed */
- (Ship *) undoLastMove
{
	if ( ! _CanUndoLastMove ) return 0;
	
	_CanUndoLastMove = NO;
	
	return [_LastMove undoMove];
}

/* one ship fires at another, returns distance for the UI, reason will hold the 
 message to the ui about why the target cannot be reached*/
- (FiringSolutionInfo *) fireFrom:(Ship *) striker
                           atShip:(Ship *) target
{
	FiringSolutionInfo * retval = [[FiringSolutionInfo alloc] init];
    retval._StrikerID = striker._ID;
    retval._VictimID = target._ID;
    retval._FiringSuccesfull = NO;
    
	FiringArc which_side = [self checkFiringArcForShip: striker
												 ToRow: target._CurrentHex._Row
											  HexInRow: target._CurrentHex._HexInRow ];
	
	if (which_side == ArcNone)
	{
		retval._Reason = @"Target in neither firing arc!";
		return retval;
	}
    
	retval._FiringArc = which_side;
    
	int distance = [self checkDistanceAndLOSForShip: striker
										   ToHexRow: target._CurrentHex._Row
										   HexInRow: target._CurrentHex._HexInRow ];
	
    
    retval._Distance = distance;
    
	if (distance == 0)
	{
		retval._Reason = @"No LOS to target!";
        return retval;
	}
	
	if (distance > CANNON_RANGE)
	{
		retval._Reason = @"Target is too far!";
		return retval;
	}
	
	if (which_side == ArcLeft && striker._FiredLeft)
	{
		retval._Reason = @"Already fired left broadside!";
		return retval;
	}
	
	if (which_side == ArcRight && striker._FiredRight)
	{
		retval._Reason = @"Already fired right broadside!";
		return retval;
	}
	
	//okay, so target is in some firing arc, in range and we have LOS. good.
	NSLog(@"Firing...\n");

    retval._FiringSuccesfull = YES;
    
	//no undo after firing
	_CanUndoLastMove = NO;
	
	if (which_side == ArcLeft) striker._FiredLeft = YES;
	else striker._FiredRight = YES;
	
	int salvo_strength = normalizedFirePowerValue(striker._Guns, distance, striker._SelectedAmmoType);
	
	DamadgeInfo * pdmg = [[DamadgeInfo alloc] applyDamadgeToShip: target
															Type: DamadgeByShooting
														Strength: salvo_strength
                                                        AmmoType: striker._SelectedAmmoType ];
	[_UIUpdates addObject: pdmg];
    
    retval._DamageDealt = (pdmg._HPLoss > 0 || pdmg._MPLoss > 0 || pdmg._SoldierLoss > 0);
    
	//if the target was engaged in boarding, assign hits to other ships as well
	//but reduce the strength by half
	
	if (target._EngagedInBoarding)
	{
		NSLog(@"Firing at boarders!");
		
		for (BoardingAction * ba in _BoardingActions)
		{
			if ([ba retrieveShipFromSide:target._Side]._ID == target._ID)
			{
				Ship * collateral_victim = [ba retrieveShipFromSide:striker._Side];
				int coll_strength = salvo_strength * COLLATERAL_MODIFIER;
				
				NSLog(@"Collateral damage befalled ship %d, with strength %d!", 
					  collateral_victim._ID, coll_strength);
				
				DamadgeInfo * pdmg2 = [[DamadgeInfo alloc] applyDamadgeToShip: collateral_victim
                                                                         Type: DamadgeByShooting
                                                                     Strength: coll_strength
                                                                     AmmoType: striker._SelectedAmmoType ];
				[_UIUpdates addObject: pdmg2];
				
				//sink the ship if it suffered catastrophic damage
				if (pdmg2._IsFatal) [self sinkShip: collateral_victim];
			}
		}
	}
	
	//sink the ship if it suffered catastrophic damage
	if (pdmg._IsFatal) [self sinkShip: target];
	
	//return distance so the UI knows the length of the animation to play
	return retval;
}

/* sinks given ship - this is called from the mapview, because only it knows when exactly
 the ships information is no longer necessary (where to display animations) */
- (void) sinkShip:(Ship *) sunkee
{
	NSLog(@"Sending %@ to Davey Jones locker!\n", sunkee);
	
#ifdef MAPCREATOR
    //no mumbo jumbo, just remove the ship
    
	//remove ship from hex
	sunkee._CurrentHex._ShipInHex = nil;

    [Ship freeName: sunkee._ShipName];

    //remove the ship from arrays
    if (sunkee._Side == RedSide) [_RedSideShips removeObject: sunkee];
    else [_BlueSideShips removeObject: sunkee];
    
    
    return;
#endif
    
	//remove ship from hex
	sunkee._CurrentHex._ShipInHex = nil;
	
	//breakup boardings if she was involved in them
	[self breakupBoardingsForShip: sunkee];
	
	if (sunkee._Side == RedSide)
	{		
		NSLog(@"Checking if this was a flagship...");
		
		//check for flagship
		if (sunkee._IAmFlagship)
			for (Ship * sh in _RedSideShips)
				[sh set_FlagshipAfloat: NO];
		
		[_RemovedShips addObject:sunkee];
		[_RedSideShips removeObject:sunkee];
		
		if ([_RedSideShips count] == 0)
		{
			NSLog(@"Red side lost!");
		}
        
        if (sunkee._IAmCargoShip)
        {
            NSLog(@"Red Side Lost by loosing cargo ship!");
        }
	}
	else {
		NSLog(@"Checking if this was a flagship...");

		//check for flagship
		if (sunkee._IAmFlagship)
			for (Ship * sh in _BlueSideShips)
				[sh set_FlagshipAfloat: NO];
		
		[_RemovedShips addObject:sunkee];
		[_BlueSideShips removeObject:sunkee];

		if ([_BlueSideShips count] == 0)
		{
			NSLog(@"Blue side lost!");
		}
		
        if (sunkee._IAmCargoShip)
        {
            NSLog(@"Blue side lost by loosing cargo ship!");
        }

	}
}

					/*******************
					 *	TURN SEQUENCE  *
					 *******************/

/* called at turn finish */
- (void) resetShipsForSide:(SideOfConflict) sd
{
	_CanUndoLastMove = NO;
	
	if (sd == RedSide)
	{
		NSLog(@"Reseting red ships!\n");
		for (Ship * ship in _RedSideShips)
		{
			//check if ship is not boarding , because it may not do anything then, also ignore towns
			if (!ship._EngagedInBoarding && !(ship._Type == town))
			{
                //make it active again
                ship._FinishedMove = NO;					

				//if it is beached, we do not reset it's movepoints 
				//(which were brought to zero by beaching damadge)
				if ( !ship._Beached )
				{
					ship._MovePointsLeft = ship._MovePoints;
					ship._TurnPointsLeft = ship._TurnPoints;
				}

				//but we reset its firing indicators
				ship._FiredLeft = NO;
				ship._FiredRight = NO;
			}
		}
	}
	else 
	{
		NSLog(@"Reseting blue ships!\n");
		for (Ship * ship in _BlueSideShips)
		{
			//check if ship is not boarding , because it may not do anything then, also ignore towns
			if (!ship._EngagedInBoarding && !(ship._Type == town))
			{
                //make it active again
                ship._FinishedMove = NO;					
                
				//if it is beached, we do not reset it's movepoints 
				//(which were brought to zero by beaching damadge)
				if ( !ship._Beached )
				{
					ship._MovePointsLeft = ship._MovePoints;
					ship._TurnPointsLeft = ship._TurnPoints;
				}
                
				//but we reset its firing indicators
				ship._FiredLeft = NO;
				ship._FiredRight = NO;
			}
		}
	}
}

/* called at turn finish to resolve all boarding actions */
- (void) resolveBoardings
{
	bool sinkers = NO;
	
	NSMutableSet * ships_to_sink = [[NSMutableSet alloc] initWithCapacity:3];
	
	for (BoardingAction * ba in _BoardingActions)
	{
		sinkers = [ba processRoundOfFighting];
		
		DamadgeInfo * red_dmg = [ba retrieveDmgInfoForSide:RedSide];
		if (red_dmg != nil) [_UIUpdates addObject:red_dmg];
		
		DamadgeInfo * blue_dmg = [ba retrieveDmgInfoForSide:BlueSide];
		if (blue_dmg != nil) [_UIUpdates addObject:blue_dmg];
		
		if (red_dmg._IsFatal) [ships_to_sink addObject: [ba retrieveShipFromSide:RedSide]];
		if (blue_dmg._IsFatal) [ships_to_sink addObject: [ba retrieveShipFromSide:BlueSide]];
	}
	
	//sink those beyond hope
	for (Ship * sinker in ships_to_sink) [self sinkShip:sinker];
    [ships_to_sink release];
}

/* check if given side has any active ships left */
- (bool) allShipsDoneFor:(SideOfConflict) sd
{
	int x = 0;
	if (sd == RedSide)
	{
		while (x < [_RedSideShips count] && [[_RedSideShips objectAtIndex:x] _FinishedMove]) x++;
		if (x == [_RedSideShips count]) return YES;
	}
	else
	{
		while (x < [_BlueSideShips count] && [[_BlueSideShips objectAtIndex:x] _FinishedMove]) x++;
		if (x == [_BlueSideShips count]) return YES;
	}
	
	return NO;
}

/* called to get the new wind direction at turn ent*/
- (void) updateWindDirection
{
	int decision = (arc4random() % 5) + 1;
	
	switch (decision)
	{
		case 1:
			_WindDirection--;
			if (_WindDirection == -1) _WindDirection = 5;
			break;

		case 2:
		case 3:
		case 4:
			//no change
			break;
			
		case 5:
			_WindDirection++;
			if (_WindDirection == 6) _WindDirection = 0;
			break;
	}
	
	NSLog(@"Wind direction is now: %d", _WindDirection);
}

/* deals fire damage to all burning ships, with firefighting allowed for the current side */
- (void) resolveFiresWithSide:(SideOfConflict) sd
{
	//this is called at the end of turn for given side
	//so it is given opportunity to fight fires
	//before getting damaged.
	
    NSMutableArray * current_ships;
    if (sd == RedSide) current_ships = _RedSideShips;
    else current_ships = _BlueSideShips;
    
    for (Ship * ship in current_ships)
    {
        //check if there is a fire
        if (ship._FireOnBoard > FireNone)
        {
            bool fire_reduct;
            
            if (! ship._TookDmgThisTurn)
            {
                //ship took no damage, so fires will be reduced by one
                fire_reduct = YES;
            }
            else
            {
                //took dmg so 50% chance to quash some fires
                fire_reduct = ((arc4random() % 2) == 1);
            }
            
            //reduce fire strength, if applicable
            if (fire_reduct)
            {
                NSLog(@"Ship %d scceeded in firefighting!\n", ship._ID);
                
                //reduce fire strength
                DamadgeInfo * pdmg = [[DamadgeInfo alloc] applyDamadgeToShip: ship
                                                                        Type: DamadgeByFire
                                                                    Strength: -1
                                                                    AmmoType: AmmoRoundShot ];

                
                [_UIUpdates addObject: pdmg];
            }//fire_reduct
        }//if ship is on fire
        
        //reset damage marker
        ship._TookDmgThisTurn = NO;
        
    }//all ships in current ships
    
    //will hold those that sink
    NSMutableSet * shipsToSink = [[NSMutableSet alloc] initWithCapacity: 3];
    
	//deal damadge to all ships that are still burning
	for (Ship * rs in _RedSideShips)
	{
		if (rs._FireOnBoard > FireNone)
		{
			DamadgeInfo * pdmg = [[DamadgeInfo alloc] applyDamadgeToShip: rs
																	Type: DamadgeByFire
																Strength: rs._FireOnBoard
                                                                AmmoType: AmmoRoundShot ];
			
            if (pdmg._IsFatal) [shipsToSink addObject: rs];
			
			[_UIUpdates addObject: pdmg];
		}
	}
	
	for (Ship * bs in _BlueSideShips)
	{
		if (bs._FireOnBoard > FireNone)
		{
			DamadgeInfo * pdmg = [[DamadgeInfo alloc] applyDamadgeToShip: bs
																	Type: DamadgeByFire
																Strength: bs._FireOnBoard 
                                                                AmmoType: AmmoRoundShot ];

			
            if (pdmg._IsFatal) [shipsToSink addObject: bs];


			[_UIUpdates addObject: pdmg];
		}
	}
	
    //sink ships destined to die
    for (Ship * wreck in shipsToSink) [self sinkShip: wreck];
    [shipsToSink release];
    
}

/* wrapper for all functions that need to happen at the end of turn
 returns the new current side (the side that now has the turn) */
- (SideOfConflict) finishTurn
{
	SideOfConflict newSide, oldSide;
	if (_CurrentSide == RedSide)
	{
		oldSide = RedSide;
		newSide = BlueSide;
	}
	else
	{
		oldSide = BlueSide;
		newSide = RedSide;
	}
	
	//deal with things that happen at the end of turn

	//process boardings
	[self resolveBoardings];
	
	//process fires and firefightnig
	[self resolveFiresWithSide:oldSide];
	
	//reset ships for the side that is going to move
	[self resetShipsForSide:newSide];

	//update wind
	[self updateWindDirection];
	
	_CurrentSide = newSide;
	return _CurrentSide;
}

/* after UI finishes updates at the end of turn, we may finally remove all of the ships */
- (void) removeAllSunkShips
{
	NSMutableArray * ships_to_sink = [[NSMutableArray alloc] initWithCapacity:6];
	
	for (Ship * ship in _RedSideShips)
		if (ship._HitPointsLeft <= 0) [ships_to_sink addObject: ship];
	
	for (Ship * ship in _BlueSideShips)
		if (ship._HitPointsLeft <= 0) [ships_to_sink addObject: ship];

	for (Ship * ship in ships_to_sink)
		[self sinkShip: ship];

}


					/**********************
					 *	NSCoding SUPPORT  *
					 **********************/

- (id) initWithCoder:(NSCoder *) coder
{
	//************* DECODING *************
    
    float version = [coder decodeFloatForKey:@"Map_file_version"];
    NSLog(@"Map file version read as %f", version);
	
	//read HexBoard dimensions
	_RowCount = [coder decodeIntegerForKey:@"_RowCount"];
	_HexesPerRow = [coder decodeIntegerForKey:@"_HexesPerRow"];
		
	//recreate ships
	_RedSideShips = [[coder decodeObjectForKey:@"_RedSideShips"] retain];
	_BlueSideShips = [[coder decodeObjectForKey:@"_BlueSideShips"] retain];
	_RemovedShips = [[coder decodeObjectForKey:@"_RemovedShips"] retain];

	//restore wind
	_WindDirection = [coder decodeIntegerForKey:@"_WindDirection"];
	_WindIsOn = YES;
	
	//restore side
	_CurrentSide = [coder decodeIntForKey:@"_CurrentSide"];
    
    //restore victory conditions
    _VictoryConditions = [[coder decodeObjectForKey:@"_VictoryConditions"] retain];
	
    //restore scenario data
    _ScenarioName = [[coder decodeObjectForKey:@"_ScenarioName"] retain];
    _ScenarioDifficulty = [[coder decodeObjectForKey:@"_ScenarioDifficulty"] retain];    
    _MultiPlayer = [coder decodeBoolForKey:@"_MultiPlayer"];
    
	//************* PROCESS DECODED DATA *************
	
	//create empty hexboard
	[self createBoardWithRows: _RowCount
				  HexesPerRow: _HexesPerRow];	
	
	//************* DECODE HEX TERRAIN DATA *************
	
	//recreate hexboard terrain
	for (Hex * hex in _HexArray)
	{
		NSString * key = [NSString stringWithFormat:@"Terrain_of_hex_%d", hex._HexID];
        NSString * robkey = [NSString stringWithFormat:@"Red_Objective_at_hex_%d", hex._HexID];
        NSString * bobkey = [NSString stringWithFormat:@"Blue_Objective_at_hex_%d", hex._HexID];
        NSString * aikey = [NSString stringWithFormat:@"AIHints_of_hex_%d", hex._HexID];
        NSString * strkey = [NSString stringWithFormat:@"Strategic_point_at_hex_%d", hex._HexID];
        
		hex._Terrain = [coder decodeIntForKey:key];
        hex._RedObjectiveHex = [coder decodeBoolForKey: robkey];
        hex._BlueObjectiveHex = [coder decodeBoolForKey: bobkey];
        
        //make objective hexes strategic points automatically
        hex._StrategicHex = ( hex._RedObjectiveHex || hex._RedObjectiveHex || [coder decodeBoolForKey:strkey] );
        
        //if this is a strategic point, mark it and all neighbours for the AI
        if (hex._StrategicHex)
        {
            hex._DefendThisHex = YES;
            NSLog(@"Marking hex %d as defensive position for the AI", hex._HexID);
            
            for (Hex * neigh in [hex GetNeighbours])
            {
                neigh._DefendThisHex = YES;
                NSLog(@"Marking hex %d as defensive position for the AI", neigh._HexID);
            }
        }
        
        //decode hex ai hints
        [hex._AIValues._AIHintValues release];
        hex._AIValues._AIHintValues = [coder decodeObjectForKey: aikey];
        [hex._AIValues._AIHintValues retain];
	}
	
	//************* PROCESS DECODED DATA *************
	
	//add red ships to hexboard
	for (Ship * ship in _RedSideShips)
	{
		Hex * hex_to_place = (Hex *) [_HexArray objectAtIndex: ship._SavedHexID];
		
		ship._CurrentHex = hex_to_place;
		hex_to_place._ShipInHex = ship;

        NSLog(@"Loaded %@", ship);
	}

	//add blue ships to hexboard
	for (Ship * ship in _BlueSideShips)
	{		
		Hex * hex_to_place = (Hex *) [_HexArray objectAtIndex: ship._SavedHexID];

		ship._CurrentHex = hex_to_place;
		hex_to_place._ShipInHex = ship;

        NSLog(@"Loaded %@", ship);
    }
			
    //reload Boarding Actions
	_BoardingActions = [[coder decodeObjectForKey:@"_BoardingActions"] retain];
	
	_UIUpdates = [[NSMutableArray alloc] initWithCapacity: 20];

	//create update notifications for the UI to be read at startup
	for (BoardingAction * ba in _BoardingActions)
	{
		UIBoardingNfo * bai = [[UIBoardingNfo alloc] initWithID: ba._BoardingID
														  shipA: ba._RedShip
														  shipB: ba._BlueShip ];
				
		//[_BoardingActionInfos addObject: bai];
		[_UIUpdates addObject: bai];
		
		NSLog(@"BAI count now: %d", [_UIUpdates count]);
	}
	
	//************* REST OF THE SETUP *************
	
	//last move
	_LastMove = [[LastMove alloc] init];
	_CanUndoLastMove = NO;
        	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeFloat:MAP_FILE_VERSION forKey:@"Map_file_version"];
    
	[coder encodeInteger:_RowCount forKey:@"_RowCount"];
	[coder encodeInteger:_HexesPerRow forKey:@"_HexesPerRow"];
	
	[coder encodeObject:_RedSideShips forKey:@"_RedSideShips"];
	[coder encodeObject:_BlueSideShips forKey:@"_BlueSideShips"];
	[coder encodeObject:_RemovedShips forKey:@"_RemovedShips"];
	
	[coder encodeInteger:_WindDirection forKey:@"_WindDirection"];
	
	[coder encodeInt:_CurrentSide forKey:@"_CurrentSide"];
	
	[coder encodeObject:_BoardingActions forKey:@"_BoardingActions"];
	
    [coder encodeObject:_VictoryConditions forKey:@"_VictoryConditions"];
    
    [coder encodeObject:_ScenarioName forKey:@"_ScenarioName"];
    [coder encodeObject:_ScenarioDifficulty forKey:@"_ScenarioDifficulty"];
    [coder encodeBool:_MultiPlayer forKey:@"_MultiPlayer"];
    
	//save terrain
	for (Hex * hex in _HexArray)
	{
		NSString * key = [NSString stringWithFormat:@"Terrain_of_hex_%d", hex._HexID];
		[coder encodeInt: hex._Terrain forKey: key];
        
        if (hex._RedObjectiveHex || hex._BlueObjectiveHex)
        {
            NSString * robkey = [NSString stringWithFormat:@"Red_Objective_at_hex_%d", hex._HexID];
            NSString * bobkey = [NSString stringWithFormat:@"Blue_Objective_at_hex_%d", hex._HexID];
            [coder encodeBool: hex._RedObjectiveHex forKey: robkey];
            [coder encodeBool: hex._BlueObjectiveHex forKey: bobkey];
        }
        
		NSString * aikey = [NSString stringWithFormat:@"AIHints_of_hex_%d", hex._HexID];
		[coder encodeObject:hex._AIValues._AIHintValues forKey: aikey];
        
        if (hex._StrategicHex)
        {
            NSString * strkey = [NSString stringWithFormat:@"Strategic_point_at_hex_%d", hex._HexID];
            [coder encodeBool: YES forKey: strkey];
        }
	}
	
	NSLog(@"Done Encoding!");
	
	//all other information may be safely dropped
}

						/************************
						 *		 CLEANUP		*
						 ************************/

- (int) getXCoordForHex:(int) hexid
{
	return [((Hex *)[_HexArray objectAtIndex:hexid]) _CoordX];
}

- (int) getYCoordForHex:(int) hexid
{
	return [((Hex *)[_HexArray objectAtIndex:hexid]) _CoordY];
}

#ifdef NON_RELEASE
- (void) testPathFinding
{    
/*
    _WindDirection = LEFT;
    
    NSLog(@"Forced wind direction to %@, ignore what the compas shows!", courseToString(_WindDirection));
    
    [self getAStarPathFromHex: [_HexArray objectAtIndex:134]
                        toHex: [_HexArray objectAtIndex:130]
                      bigShip: YES
               courseAtOrigin: LEFT_DOWN ];
*/
}
#endif

/* Destructor */
- (void) dealloc
{
	NSLog(@"WARNING: HexBoard is being dealloc'd!");
        
    //drop the references
    for (Ship * sss in _RemovedShips) sss._CurrentHex = nil;
    for (Ship * sss in _RedSideShips) sss._CurrentHex = nil;
    for (Ship * sss in _BlueSideShips) sss._CurrentHex = nil;
        
    for (Hex * hx in _HexArray) [hx release];
	[_HexArray release];
	_HexArray = nil;
    
    NSLog(@"Hexes Dealloc'd!");
    //DONE DEALLOC'ING HEXES
    
    [_RemovedShips release];
	_RemovedShips = nil;

    [_RedSideShips release];
	_RedSideShips = nil;

	[_BlueSideShips release];
	_BlueSideShips = nil;

    NSLog(@"Ships dealloc'd!");
    
	[_LastMove release];
	
	[_BoardingActions release];

    NSLog(@"Boarding actions dealloc'd!");

	[_UIUpdates release];

    NSLog(@"UIUpdates dealloc'd!");

	[super dealloc];
	NSLog(@"HexBoard dealloc finishes ok!");
}

@end
