//
//  UIDmgNfo.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIDmgNfo.h"
#import "DamadgeInfo.h"
#import "Ship.h"

@implementation UIDmgNfo

@synthesize _MSGs, _DamadgedShipID;
@synthesize _fireUpdateNeeded, _VictimFireNow;
@synthesize _HPLoss;
@synthesize _FatalDamage;

- (id) initWithDamadgeInfo:(DamadgeInfo *) dmg
{
	self = [super init];
	_MSGs = [[NSMutableArray alloc] initWithCapacity:5 ];
	_DamadgedShipID = dmg._DamagedShipID;

	_fireUpdateNeeded = (dmg._FireSpread != 0);
	_VictimFireNow = dmg._VictimFireNow;
    
    _FatalDamage = dmg._IsFatal;
    
    _HPLoss = dmg._HPLoss;
	
	//process the damadgeinfo
	switch (dmg._CritDmgType)
	{
		case CritSailDmg:
			[_MSGs addObject: @"Sail damage!"];
			break;
			
		case CritMastDmg:
			[_MSGs addObject: @"Lost a mast!"];
			break;
			
		case CritRudderDmg:
			[_MSGs addObject: @"Rudder damaged!"];
			break;
			
		case CritGunDeckDmg:
			[_MSGs addObject: @"Gun deck hit!"];
			break;
			
		case CritInfDmg:
			[_MSGs addObject: @"Crew casualties!"];
			break;
			
		case CritFireDmg:
			[_MSGs addObject: @"Fire on board!"];
			break;
            
        case CritRiggingDmg:
			[_MSGs addObject: @"Rigging damage!"];
            break;
            
        case CritMassInfDmg:
			[_MSGs addObject: @"Mass casualties!"];
            break;
            
        case CritFortBatteryDmg:
			[_MSGs addObject: @"Battery hit!"];
            break;
            
        case CritFortFireDmg:
			[_MSGs addObject: @"Fire!"];
            break;
            
        case CritFortGarrisonDmg:
			[_MSGs addObject: @"Garrison losses!"];
            break;
            
        case CritFortMagazineDmg:
			[_MSGs addObject: @"Magazine hit!"];
            break;
            
        case CritNone:
            break;
	}
	
    if (dmg._DmgType == DamadgeByFire)
    {
        if (dmg._TargetWasTown) [_MSGs addObject: [NSString stringWithFormat:@"Town Burns!"]];
        else
        {
            if (dmg._TargetWasFort) [_MSGs addObject: [NSString stringWithFormat:@"Fort Burns!"]];
            else [_MSGs addObject: [NSString stringWithFormat:@"Ship Burns!"]];
        }
    }
    
	if (dmg._HPLoss > 0) 
		[_MSGs addObject: [NSString stringWithFormat:@"-%dHP", dmg._HPLoss]];
	
	if (dmg._TPLoss > 0) 
		[_MSGs addObject: [NSString stringWithFormat:@"-%dTP", dmg._TPLoss]];
	
	if (dmg._MPLoss > 0)
		[_MSGs addObject: [NSString stringWithFormat:@"-%dMP", dmg._MPLoss]];
	
	if (dmg._GunLoss > 0)
		[_MSGs addObject: [NSString stringWithFormat:@"-%dGNS", dmg._GunLoss]];
	
	if (dmg._SoldierLoss > 0)
		[_MSGs addObject: [NSString stringWithFormat:@"-%dSOL", dmg._SoldierLoss]];
	
	if (dmg._FireSpread > 0)
	{
		if (dmg._CritDmgType != CritFireDmg) [_MSGs addObject: @"Fire Spreads!"];
		[_MSGs addObject: [NSString stringWithFormat:@"+%dFIRE", dmg._FireSpread]];
	}
	
	if (dmg._FireSpread < 0)
	{
		[_MSGs addObject: @"Fire Weakens!"];
		[_MSGs addObject: [NSString stringWithFormat:@"-%dFIRE", -dmg._FireSpread]];
	}
	
    //if not messages and damage by shooting - select apropriate msg
	if ([_MSGs count] == 0 && dmg._DmgType == DamadgeByShooting) 
    {
        if (dmg._TargetWasFort) [_MSGs addObject: @"No Damage!"];
        else [_MSGs addObject: @"Missed!"];
    }
	if ([_MSGs count] == 0 && dmg._DmgType == DamadgeByBoarding) [_MSGs addObject: @"No Damage!"];
	
    //add apropriate K.O. msg
	if (dmg._IsFatal == YES)
    {
        if (dmg._TargetWasTown) [_MSGs addObject: [NSString stringWithFormat:@"Town Subdued!"]];
        else
        {
            if (dmg._TargetWasFort) [_MSGs addObject: [NSString stringWithFormat:@"Fort Destroyed!"]];
            else [_MSGs addObject: [NSString stringWithFormat:@"Ship Sunk!"]];
        }
    }
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
	[_MSGs release];
}

@end
