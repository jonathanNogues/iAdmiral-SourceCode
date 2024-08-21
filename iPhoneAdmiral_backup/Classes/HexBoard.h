//
//  HexBoard.h
//  ObjCHexboard
//
//  Created by Piotr Sarnowski on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hex.h"
#import "Common.h"

@class Ship;
@class DamadgeInfo;
@class LastMove;
@class UIBoardingNfo;
@class FiringSolutionInfo;
@class VictoryConditions;

@interface HexBoard : NSObject <NSCoding>
{
	//all hexes are stored here
	NSMutableArray *	_HexArray;
	
	//ships from one side get their own array
	NSMutableArray *	_RedSideShips;
	NSMutableArray *	_BlueSideShips;
	NSMutableArray *	_RemovedShips;			//ships that get sunk / escape are put here
	
	//hexboard dimensions
	NSInteger			_RowCount;
	NSInteger			_HexesPerRow;
	
	//all boarding actions
	NSMutableArray *	_BoardingActions;

	//array for storing info for the UI
	NSMutableArray *	_UIUpdates;				
	
	//last move (for undoing it)
	LastMove *			_LastMove;
	bool				_CanUndoLastMove;
	
	//wind
	HexDirection		_WindDirection;
	//for testing purposes, it may be good to disable the wind feature for now
	bool				_WindIsOn;
	
	//which side's turn it is
	SideOfConflict		_CurrentSide;
    
    //victory checking
    VictoryConditions * _VictoryConditions;
    
    //scenario data for autosaves
    NSString *          _ScenarioName;
    NSString *          _ScenarioDifficulty;
    
    BOOL                _MultiPlayer;      //if YES, blue player will NOT be taken over by AI
}

@property (nonatomic, readonly) NSInteger _HexesPerRow;
@property (nonatomic, readonly) NSInteger _RowCount;
@property (nonatomic, readonly) NSMutableArray * _RedSideShips;
@property (nonatomic, readonly) NSMutableArray * _BlueSideShips;
@property (nonatomic, readonly) NSMutableArray * _RemovedShips;
@property (nonatomic, assign)   BOOL _MultiPlayer;

#ifdef MAPCREATOR
@property (nonatomic, assign)   VictoryConditions * _VictoryConditions;
@property (nonatomic, assign)	HexDirection _WindDirection;
@property (nonatomic, assign)	SideOfConflict _CurrentSide;
@property (nonatomic, assign)   NSString * _ScenarioName;
@property (nonatomic, assign)   NSString * _ScenarioDifficulty;
#else
@property (nonatomic, readonly) HexDirection _WindDirection;
@property (nonatomic, readonly)	SideOfConflict _CurrentSide;
@property (nonatomic, readonly) NSString * _ScenarioName;
@property (nonatomic, readonly) NSString * _ScenarioDifficulty;
#endif

				/********************
				 *	INITIALIZATION	*
				 ********************/

/* Creates empty hexboard */
- (HexBoard *) initWithHexesPerRow:(int)hpr
						  RowCount:(int)rc;

/* create hexboard with specified dimensions and connect all the hexes to each other */
- (void) createBoardWithRows:(int) rc
				 HexesPerRow:(int) hpr;

/* initializes permanent AI values for all hexes */
- (void) initAI;

				/****************
				 *	AI RELATED	*
				 ****************/

/* called at the beggining of a turn to set hex AI values */
- (void) updateHexAIhints:(SideOfConflict) side;

/* Gets all hexes that can be reached by given ship */
- (NSSet *) getReachablePositionsSetForShip:(Ship *) ship;

/* gets path to target using AStar algorithm */
- (NSArray *) getAStarPathFromHex:(Hex *) origin
                            toHex:(Hex *) destination
                          bigShip:(BOOL) big_ship
                   courseAtOrigin:(HexDirection) course;

/* when supplied with list of hexes to traverse, hexboard converts them to aicommands
   returns YES if the given Warpath is optimal, and NO if way is blocked by friendly ships */
- (bool) transformAStarPath:(NSArray *) astarpath
                  toWarpath:(NSMutableArray *) warpath
                    forShip:(Ship *) ship;

				/****************
				 *	UTILITIES	*
				 ****************/

/* Translate cooridnates into hex designator */
- (int) TranslateRowNum:(int) rowno
			   HexInRow:(int) hrw;

/* called to break up boardings that the ship may be involved in */
- (void) breakupBoardingsForShip:(Ship *) ship;

/* checks if given hex is on the right side of the ship (if this returns no, it means
 the hex is on the left side of the ship)*/
- (bool) isOnTheRightHexRow:(int) row
				   HexInRow:(int) hir
				   FromShip:(Ship * )ship;

/* helper function for Distance and LOS checking	*/
- (HexDirection) getDirI:(int) i
					   J:(int) j;

/* actual calculating function for movement cost */
- (int) calculateMPcostForCourse:(HexDirection) course
						 bigShip:(bool) bship;

/* helper function that determines the movement cost in respect to wind
	returns 0 if move is impossible,
	1 for move with wind 
	2 for movement against (small ship only) */
- (int) calculateMPcostForShip:(Ship *) ship;

/* gets all hexes that are inside the given diameter of neighbours */
//- (NSSet *) getHexNeighbourhood:(Hex *) hex
//				 WithinDiameter:(int) diam;

/* gets all hexes that are inside given diameter and assigns them
 a value equal to distance from original hex */
- (NSDictionary *) getHexNeighbourhoodWithDistances:(Hex *) hex
									 withinDiameter:(int) diam;

				/***************************
				 *	HEXBOARD MANIPULATORS  *
				 ***************************/

/* Adds a ship to hexboard and to ships table for given side */
- (void) addShip:(Ship *) ship
		   AtRow:(int) row
		HexInRow:(int) hrw;

/* Removes a ship from a gven hex */
- (void) removeShipAtRow:(int) row
				HexInRow:(int) hrw;

/* set terrain at specified hex to specified value */
- (void) SetTerrainTo:(TerrainType) terrain
			   ForRow:(int) row
			 HexInRow:(int) hri;

				/****************************
				 *	INFORMATION RETRIEVERS  *
				 ****************************/

/* gets id of the ship at given hex (0 when empty!) */
- (int) getShipIdAtRow:(int) row
			  HexInRow:(int) hrw;

/* returns what will be the result of moving a ship at specified hex */
- (MoveResult) CanMoveShipAtRow:(int) row
						 AndHex:(int) hrw
                   ignoreMPCost:(bool) no_mp_cost;

/* returns what will be the result of moving a specified ship */
- (MoveResult) canMoveShip:(Ship *) ship;

/* retrieves information as to amount of turns a ship can make at this time */
- (TurningAbility) canShipTurn:(Ship *) ship;

/* get ship pointer at given row and hex */
- (Ship *) getShipAtRow:(int) row
			   HexInRow:(int) hrw;

/* Retrieves terrain type for terrain view */
- (TerrainType) getTerrainOfRow:(int) row
					   HexInRow:(int) hrw;

/* get list of hexes that are objectives */
//- (NSArray *) getObjectiveHexes;

#ifdef NON_RELEASE

- (bool) getObjectiveAtRow:(int)c_row 
                  HexInRow:(int)c_hex;

- (bool) getStrategicAtRow:(int)c_row 
                  HexInRow:(int)c_hex;

- (bool) getDefensiveAtRow:(int)c_row 
                  HexInRow:(int)c_hex;

#endif

/* gets next ship that has not finished turn yet or nil if no such ship found */
- (Ship *) GetNextShipFrom:(Ship *) current_ship
                   ForSide:(SideOfConflict) sd;

/* called at the start of the human turn, gets the most important ship of own side to zoom to it */
- (Ship *) GetMostImportantShipForSide:(SideOfConflict) sd;

/* calls for retrieving damadge infos */
- (NSObject *) retrieveLastUIUpdate;

/* returns in which (if any) firing arc the given hex is for the specified ship */
- (FiringArc) checkFiringArcForShip:(Ship *) ship
							  ToRow:(int) target_row
						   HexInRow:(int) target_hir;

/* fast function for checking distance between hexes */
- (int) fastHexDistanceForHexID:(int) hexidA
					   andHexID:(int) hexidB;

/* checks the distance between the ship and target hex (returns 0 if LOS blocked) */
- (int) checkDistanceAndLOSForShip:(Ship *) ship
						  ToHexRow:(int) row
						  HexInRow:(int) hir;

/* gets tha array of AI hint values of a given hex */
- (NSArray *) getAIHintValuesForHexRow:(int) row
							  HexInRow:(int) hir;

- (VictoryResult) checkForVictory;

				/******************
				 *	SHIP ACTIONS  *
				 ******************/

/* moves ship at given hex (ships can only move one hex in the direction they are facing) */
- (MoveResult) moveShipAtRow:(int) row
					HexInRow:(int) hrw;

/* turns ship at given hex left or right */
- (void) TurnShipAtRow:(int) row
			  HexInRow:(int) hrw
		   InDirection:(TurnDirection) td;

/* mark ship as finished moving */
- (void) setShipFinishedTo:(bool) fin_status
					   Row:(int) row 
				  HexInRow:(int) hrw;

/* call when ship becomes beached */
- (void) BeachShip:(Ship *) ship;

/* call when initiating boarding */
- (void) initiateBoardingWith:(Ship *) ship;

/* calls for undo of last move, and returns id of the ship that undoed */
- (Ship *) undoLastMove;

/* sinks given ship - this is called from the mapview, because only it knows when exactly
 the ships information is no longer necessary (where to display animations) */
- (void) sinkShip:(Ship *) sunkee;

/* one ship fires at another, returns distance for the UI, reason will hold the 
 message to the ui about why the target cannot be reached*/
- (FiringSolutionInfo *) fireFrom:(Ship *) striker
                           atShip:(Ship *) target;

				/*******************
				 *	TURN SEQUENCE  *
				 *******************/

/* check if given side has any active ships left */
- (bool) allShipsDoneFor:(SideOfConflict) sd;

/* called at turn finish */
- (void) resetShipsForSide:(SideOfConflict) sd;

/* called at turn finish to resolve all boarding actions */
- (void) resolveBoardings;

/* called to get the new wind direction at turn ent*/
- (void) updateWindDirection;

/* deals fire damage to all burning ships, with firefighting allowed for the current side */
- (void) resolveFiresWithSide:(SideOfConflict) sd;

/* wrapper for all functions that need to happen at the end of turn
   returns the new current side (the side that now has the turn) */
- (SideOfConflict) finishTurn;

/* after UI finishes updates at the end of turn, we may finally remove all of the ships */
- (void) removeAllSunkShips;

#ifdef NON_RELEASE
- (void) testPathFinding;
#endif

- (int) getXCoordForHex:(int) hexid;
- (int) getYCoordForHex:(int) hexid;

@end
