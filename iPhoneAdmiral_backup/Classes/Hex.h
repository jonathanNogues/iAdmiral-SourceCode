//
//  Hex.h
//  ObjCHexboard
//
//  Created by Piotr Sarnowski on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class Ship;
@class HexAIHints;

@interface Hex : NSObject {
	Hex * ptNeighbours[DIRECTION_MAX];
		
	int _HexID;
	//NSNumber * _HexIDObject;
	int _Row;
	int _HexInRow;
	
	int _CoordX;			//new coordinates system for fast distance calculation
	int _CoordY;
	
	TerrainType _Terrain;	///<terrain type of hex
	
	Ship * _ShipInHex;		///<Pointer to ship present in hex
	
	HexAIHints * _AIValues;	///<Pointer to ai hint values of a given hex
 
    //if this hex is scenario objective, this is true
    bool _RedObjectiveHex;
    bool _BlueObjectiveHex;
    
    //if this hex has strategic value, this is true (objective hexes are strategic hexes by def.)
    bool _StrategicHex;
    
    //hint for ai that this hex is, or is next to hex with strategic value
    bool _DefendThisHex;
}

@property (nonatomic, assign) int _CoordX;
@property (nonatomic, assign) int _CoordY;

@property (nonatomic, readonly) int _HexID;
@property (nonatomic, readonly) int _Row;
@property (nonatomic, readonly)	int _HexInRow;
@property (nonatomic, readonly)	NSNumber * _HexIDObject;

@property (nonatomic, assign) Ship * _ShipInHex;
@property (nonatomic, assign) TerrainType _Terrain;

@property (nonatomic, assign) HexAIHints * _AIValues;

@property (nonatomic, assign) bool _RedObjectiveHex;
@property (nonatomic, assign) bool _BlueObjectiveHex;
@property (nonatomic, assign) bool _StrategicHex;
@property (nonatomic, assign) bool _DefendThisHex;

/* function that resets the IDs granted to newly created hexes... */
+ (void) resetID;

/* set coordinates in hexboard */
- (void) SetRow:(int) rw
	   HexInRow:(int) hir;

/* adds specified hex as neighbour in specified direction and vice versa */
- (void) ConnectToHex:(Hex *)hex 
		  inDirection:(HexDirection)dir;

/* sets two hexes as neighbours with specifed data */
+ (void) ConnectHexes:(Hex *)hexA 
				 With:(Hex *)hexB 
				 From:(HexDirection)fromAtoB;

/* returns a hex neighbour at supplied direction. Result can be nil */
- (Hex *) GetHexNeighbourAtDirection:(HexDirection) dir;

/* returns array of neighbours */
- (NSArray *) GetNeighbours;

/* checks for direction of given neighbour id. returns DIRECTION_MAX when non adjacent hex id is supplied */
- (HexDirection) getDirectionOfNeighbourID:(int) nid;

@end
