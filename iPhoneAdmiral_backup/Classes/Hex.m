//
//  Hex.m
//  ObjCHexboard
//
//  Created by Piotr Sarnowski on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Hex.h"
#import "HexAIHints.h"

static int id_used = 0;

@implementation Hex

@synthesize _HexID, _Row, _HexInRow, _ShipInHex, _Terrain, _AIValues;
@synthesize _RedObjectiveHex, _BlueObjectiveHex, _StrategicHex, _DefendThisHex;

//new coord system
@synthesize _CoordX, _CoordY;

- (Hex *) init
{
	self = [super init];
	
	_HexID = id_used++;
	//_HexIDObject = [NSNumber numberWithInt:_HexID];
	
	_Terrain = TerrainDeepWater;
	
	_AIValues = [[HexAIHints alloc] init];
	
    _RedObjectiveHex = NO;
    _BlueObjectiveHex = NO;
    
	return self;
}

+ (void) resetID
{
	id_used = 0;
}

- (void) SetRow:(int) rw
	   HexInRow:(int) hir
{
	_Row = rw;
	_HexInRow = hir;
}


- (void) ConnectToHex:(Hex *)hex 
		  inDirection:(HexDirection)dir
{
	ptNeighbours[dir] = hex;
	
	//calculate other direction
	HexDirection other_direction = dir + 3;
	if (other_direction >= DIRECTION_MAX) other_direction -= DIRECTION_MAX;
	
	hex->ptNeighbours[other_direction] = self;
}


+ (void) ConnectHexes:(Hex *)hexA 
				 With:(Hex *)hexB 
				 From:(HexDirection)fromAtoB
{
	hexA->ptNeighbours[fromAtoB] = hexB;
	
	//calculate other direction
	HexDirection fromBtoA = fromAtoB + 3;
	if (fromBtoA >= DIRECTION_MAX) fromBtoA -= DIRECTION_MAX;

	hexB->ptNeighbours[fromBtoA] = hexA;
}

- (Hex *) GetHexNeighbourAtDirection:(HexDirection) dir
{
	return ptNeighbours[dir];
}

- (NSArray *) GetNeighbours
{
	NSMutableArray * tempArr = [[NSMutableArray alloc] initWithCapacity: 6];
		
	for (int i = 0; i < DIRECTION_MAX; i++)
		if (ptNeighbours[i] != nil) 
			[tempArr addObject: ptNeighbours[i]];
	
	NSArray * retArr = [NSArray arrayWithArray:tempArr];
	[tempArr release];
	
	return retArr;
}

- (HexDirection) getDirectionOfNeighbourID: (int) nid
{
    for (HexDirection retval = LEFT; retval < DIRECTION_MAX; retval++)
    {
        if (ptNeighbours[retval] != nil && ptNeighbours[retval]._HexID == nid ) return retval;
    }
    
    return DIRECTION_MAX;
}


- (NSNumber *) _HexIDObject
{
	return [NSNumber numberWithInt:_HexID];
}

- (void) dealloc
{
	NSLog(@"WARNING: HEX %d is being dealloc'd!", _HexID);
	
	_ShipInHex = nil;
	
	[_AIValues release];
	
	[super dealloc];
}

@end
