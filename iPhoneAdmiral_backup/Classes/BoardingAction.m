//
//  BoardingAction.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BoardingAction.h"
#import "Ship.h"
#import "DamadgeInfo.h"

@implementation BoardingAction

@synthesize _BoardingID, _RedShip, _BlueShip;

- (id) initWithShip:(Ship *) shipA
		andWithShip:(Ship *) shipB
{
	static int id_to_assign = 0;
	_BoardingID = id_to_assign;
	id_to_assign++;
	if (id_to_assign == 50) id_to_assign = 0;
	
	if (shipA._Side == RedSide)
	{
		_RedShip = shipA;
		_BlueShip = shipB;
	}
	else
	{
		_BlueShip = shipA;
		_RedShip = shipB;
	}
	
	return self;
}

- (void) addShip:(Ship *) ship
{
	if (ship._Side == RedSide) _RedShip = ship;
	else _BlueShip = ship;
}

/* return true if something sinks */
- (bool) processRoundOfFighting
{	
	//formula:
	//side strength = (class - 1) + soldiers + flagshipalive
	//then, ONE side gets a (-3 +3) bonus
	//side strength is then divided by number of boardings the ship is engaged in	
	//loosing side gets - 1
	//winning side gets + 1
	
	int RedStrength = (_RedShip._Class - 1) + _RedShip._Soldiers;
	int BlueStrength = (_BlueShip._Class - 1) + _BlueShip._Soldiers;
		
	//take flagships into account
	if (_RedShip._FlagshipAfloat) RedStrength++;
	if (_BlueShip._FlagshipAfloat) BlueStrength++;
	
	//add random factor <-3 +3>
	int randomfactor = (arc4random() % 7) - 3;
	
	//choose whic side gets it
	if (arc4random() % 2 == 1) RedStrength += randomfactor;
	else BlueStrength += randomfactor;
	
	if (_RedShip._BoardingsCount > 1) RedStrength = RedStrength / _RedShip._BoardingsCount;
	if (_BlueShip._BoardingsCount > 1) BlueStrength = BlueStrength / _BlueShip._BoardingsCount;
	
	if (RedStrength > BlueStrength)	//winners advantage
	{
		RedStrength++;
		BlueStrength--;
	}
	else
	{
		RedStrength--;
		BlueStrength++;
	}
	
	NSLog(@"Outcome calculated! Red strength: %d, Blue strength: %d\n", RedStrength, BlueStrength);
	
	bool fatal_damage_dealt = NO;
	
	if (BlueStrength > 0) 
	{
		_RedDamadge = [[DamadgeInfo alloc] applyDamadgeToShip:_RedShip
														 Type:DamadgeByBoarding
													 Strength:BlueStrength
                                                     AmmoType:AmmoRoundShot];
		if (_RedDamadge._IsFatal) fatal_damage_dealt = YES;
	}
	else _RedDamadge = nil;

	if (RedStrength > 0)
	{
		_BlueDamadge =[[DamadgeInfo alloc] applyDamadgeToShip:_BlueShip
														 Type:DamadgeByBoarding
													 Strength:RedStrength
                                                     AmmoType:AmmoRoundShot];
		if (_BlueDamadge._IsFatal) fatal_damage_dealt = YES;
	}
	else _BlueDamadge = nil;
	
	return fatal_damage_dealt;
}

/* returns damadge info for given side */
- (DamadgeInfo *) retrieveDmgInfoForSide:(SideOfConflict) sd
{
	if (sd == RedSide) return _RedDamadge;
	else return _BlueDamadge;
}

/* returns ship info for given side */
- (Ship *) retrieveShipFromSide:(SideOfConflict) sd
{
	if (sd == RedSide) return _RedShip;
	else return _BlueShip;
}

/* init via nscoding */
- (id) initWithCoder:(NSCoder *) coder
{
	Ship * rShip = [[coder decodeObjectForKey:@"_RedShip"] retain];
	Ship * bShip = [[coder decodeObjectForKey:@"_BlueShip"] retain];

	self = [self initWithShip: rShip
				  andWithShip: bShip ];
		
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	//we may drop all other info and have it reset automatically on init, but we need this:
	[coder encodeObject:_RedShip forKey:@"_RedShip"];
	[coder encodeObject:_BlueShip forKey:@"_BlueShip"];
}

- (void) dealloc
{	
	//the are released elsewhere
	_RedShip = nil;
	_BlueShip = nil;
	
	//this will be released when mapview consumes them
	_RedDamadge = nil;
	_BlueDamadge = nil;

	[super dealloc];
}

@end
