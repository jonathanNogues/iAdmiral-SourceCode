//
//  DamadgeInfo.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DamadgeInfo.h"
#import "Ship.h"

@implementation DamadgeInfo

@synthesize _HPLoss, _MPLoss, _TPLoss, _GunLoss, _SoldierLoss,
			_IsFatal, _DmgType, _CritDmgType, _FireSpread, _DamagedShipID;

@synthesize _VictimFireNow, _TargetWasFort, _TargetWasTown;

/* second parameter is strength, when revelant. irreveleant cases it can be anything */
- (id) applyDamadgeToShip:(Ship *) victim
					 Type:(DamadgeType) dmgtype
				 Strength:(int)dmgstr
                 AmmoType:(AmmunitionType) at
{
	//we set them first, will modify 'em later
	_DamagedShipID = victim._ID;
	_CritDmgType = CritNone;
	
	_HPLoss = 0;
	_MPLoss = 0;
	_TPLoss = 0;
	_GunLoss = 0;
	_SoldierLoss = 0;
	_FireSpread = 0;
	_IsFatal = NO;
	_DmgType = dmgtype;
    
    _TargetWasFort = victim._IAmFort;
    _TargetWasTown = (victim._Type == town);

	//remember to alloc first and then release this!
	switch (dmgtype)
	{
		case DamadgeByBeaching:
			//strength plays no part here, just deal 1-3 hp damadge
			_HPLoss = (arc4random() % 3) + 1;
			break;
			
		case DamadgeByBoarding:
			//deal one hp damadge
			//then 
			// kill soldier for two damadge
			//deal up to 2 hp damadge
			//repeat

			if (dmgstr > 0)
			{
				_HPLoss++;
				dmgstr--;
			}
			
			while (dmgstr > 0)
			{
				if (victim._Soldiers > _SoldierLoss)
				{
					_SoldierLoss++;
					dmgstr -= 2;
				}
				
				if (dmgstr > 0)
				{
					_HPLoss++;
					dmgstr--;
				}
	
				if (dmgstr > 0)
				{
					_HPLoss++;
					dmgstr--;
				}
			}
			
			break;
			
		case DamadgeByFire:
			//deal 1 hp per fire size
			if (dmgstr > 0) _HPLoss = dmgstr;
			
			//or reduce the fire size
			if (dmgstr < 0) _FireSpread = dmgstr;
			
			break;
			
		case DamadgeByShooting:
			//strength is the number of guns, basically each 10 guns give you additional
			//chance at damadgeing someone (strength may be doubled at close range)
		{	
            int rounds = dmgstr / 10;
            
			int damages = 0;
            
            for (int i = 0; i < rounds; i++)
                if (arc4random() % 2 == 1) damages++;
			
            NSLog(@"Shooting stats: firepower: %d, rounds: %d, damages: %d", dmgstr, rounds, damages);
			
            if (victim._IAmFort) 
            {
                if (victim._Type == town) [self processTownDamage:damages AmmoType:at];
                else [self processFortDamage:damages AmmoType:at];
            }
            else [self processShipDamage:damages AmmoType:at];
                        
			//if the ship took dmg, it may not conduct firefighting
			if (_HPLoss > 0) [victim set_TookDmgThisTurn:YES];
			
			//idea: if ship is beached, it should be more difficult to sink:
			//so, if _HPLoss is only 1, there will be 50% to shrug it off.
			if (_HPLoss == 1 && [victim _Beached])
			{
				int red = arc4random() % 2;
				
				if (red)
				{
					NSLog(@"Beached ship shrugs off damadge!");
					_HPLoss--;
				}
			}
			
			//if the ship is on fire, additional damage may help spread it
			if (_HPLoss > 0 && victim._FireOnBoard != FireNone)
			{
				int fire = arc4random() % 2;
				
				if (fire)
				{
					NSLog(@"Additional fire spread!");
					_FireSpread++;
				}
			}
        }
            break;
            
		default:
			NSLog(@"WTH?\n");
			break;
	}//switch dmg.type
	
             
	//check for fatal damadge
	if (_HPLoss >= [victim _HitPointsLeft])
	{
		NSLog(@"Ship sunk!\n");
		_HPLoss = [victim _HitPointsLeft];
		_IsFatal = YES;
	}
    
    //normalize damage so we do not venture into negative soldiers or cannons
    if (_MPLoss > victim._MovePoints) _MPLoss = victim._MovePoints;
    if (_TPLoss > victim._TurnPoints) _TPLoss = victim._TurnPoints;
    if (_GunLoss > victim._Guns) _GunLoss = victim._Guns;
    if (_SoldierLoss > victim._Soldiers) _SoldierLoss = victim._Soldiers;
    
	//apply all the nasty stuff to the victim
	victim._HitPointsLeft -= _HPLoss;
	victim._MovePoints -= _MPLoss;
	victim._TurnPoints -= _TPLoss;
	victim._Guns -= _GunLoss;	
	victim._Soldiers -= _SoldierLoss;

    //fire handling
    victim._FireOnBoard += _FireSpread;
	if (victim._FireOnBoard > FireAblaze) victim._FireOnBoard = FireAblaze;
    _VictimFireNow = victim._FireOnBoard;
    
	return self;
}

- (void) processShipDamage:(int) damages
                AmmoType:(AmmunitionType) at
{
    switch (at)
    {
        case AmmoRoundShot:
            _HPLoss = damages;
            NSLog(@"Round Shot inflicts %d HP Loss upon this ship.", damages);
            break;
            
        case AmmoChainShot:
            _MPLoss = damages;
            NSLog(@"Chain Shot inflicts %d MP Loss upon this ship.", damages);
            break;
            
        case AmmoGrapeShot:
            _SoldierLoss = damages;
            NSLog(@"Grape Shot inflicts %d Soldier Loss upon this ship.", damages);
            break;
            
        case AmmoHotShot:
            break;
    }
    
    bool critical_hit = ((arc4random() % 9) < damages);
    
    //no critical = our work is done
    if (!critical_hit) return;
    
    NSLog(@"Critical hit!");

    switch (at)
    {
        case AmmoRoundShot:
        {
            int critical_dmg = arc4random() % 6;
            
            switch (critical_dmg)
            {
                case 0:
                    NSLog(@"Sail damadge!\n");
                    
                    _CritDmgType = CritSailDmg;
                    _MPLoss++;
                    _HPLoss--;		//a ship might loose all its sails, but still
                    break;
                    
                case 1:
                    NSLog(@"Rudder damadge!\n");
                    
                    _TPLoss++;
                    _CritDmgType = CritRudderDmg;
                    break;
                    
                case 2:
                    NSLog(@"Lost a mast!\n");
                    
                    //serious hit
                    _HPLoss++;
                    _CritDmgType = CritMastDmg;
                    _TPLoss++;
                    _MPLoss++;
                    break;
                    
                case 3:
                    NSLog(@"Gun Deck Hit!\n");

                    _CritDmgType = CritGunDeckDmg;                    
                    _GunLoss += (arc4random() % 6) + 5;
                    break;
                    
                case 4:
                    NSLog(@"Shrapnel! Infantry losses!\n");
                    
                    _CritDmgType = CritInfDmg;
                    _SoldierLoss++;
                    break;
                    
                case 5:
                    NSLog(@"Fire on board!\n");
                    
                    _CritDmgType = CritFireDmg;
                    _FireSpread++;
                    break;
            }
        }//case AmmoRoundShot
            break;
            
        case AmmoChainShot:
        {
            int critdmgtype = arc4random() % 2;
            
            switch (critdmgtype) {
                case 0:
                    NSLog(@"Rigging Damaged!");
                    _TPLoss++;
                    _CritDmgType = CritRiggingDmg;
                    break;
                    
                case 1:
                    NSLog(@"Demasting Hit!");
                    _TPLoss++;
                    _HPLoss += 2;
                    _CritDmgType = CritMastDmg;
                    break;
            }
        }
            break;
            
        case AmmoGrapeShot:
            NSLog(@"Massive crew casualties!");
            _SoldierLoss += 2;
            _CritDmgType = CritMassInfDmg;
            break;
            
        case AmmoHotShot:
            break;
    }
}

- (void) processFortDamage:(int) damages
                  AmmoType:(AmmunitionType) at
{
    if (at == AmmoChainShot)
    {
        NSLog(@"Chain shot has no effect on forts!");
        return;
    }
    
    switch (at)
    {
        case AmmoRoundShot:
            _HPLoss = damages;
            NSLog(@"Round Shot inflicts %d HP Loss upon this fort.", damages);
            break;
                        
        case AmmoGrapeShot:
            _SoldierLoss = damages;
            NSLog(@"Grape Shot inflicts %d Soldier Loss upon this fort.", damages);
            break;
            
        case AmmoChainShot:
        case AmmoHotShot:
            break;
    }
    
    bool critical_hit = ((arc4random() % 9) < damages);
    
    //no critical = our work is done
    if (!critical_hit) return;
    
    NSLog(@"Critical hit!");
    
    switch (at)
    {
        case AmmoRoundShot:
        {
            int critical_dmg = arc4random() % 3;
            
            switch (critical_dmg)
            {
                case 0:
                    NSLog(@"Battery hit!");
                    
                    _CritDmgType = CritFortBatteryDmg;
                    _GunLoss += (arc4random() % 6) + 5;
                    break;
                    
                case 1:
                    NSLog(@"Magazine hit!");

                    _CritDmgType = CritFortMagazineDmg;
                    _HPLoss += 3;
                    break;
                    
                case 2:
                    NSLog(@"Garrison hit!");
                    
                    _CritDmgType = CritFortGarrisonDmg;
                    _SoldierLoss++;
                    break;
                    
                case 3:
                    NSLog(@"Fort Catches Fire!\n");
                    
                    _CritDmgType = CritFortFireDmg;
                    _FireSpread++;
                    break;
            }
        }//case AmmoRoundShot
            break;
                        
        case AmmoGrapeShot:
            NSLog(@"Massive crew casualties!");
            _SoldierLoss += 2;
            _CritDmgType = CritMassInfDmg;
            break;
            
        case AmmoChainShot:
        case AmmoHotShot:
            break;
    }
}

- (void) processTownDamage:(int) damages
                  AmmoType:(AmmunitionType) at
{
    if (at != AmmoRoundShot)
    {
        NSLog(@"Special ammo has no effect on towns!");
        return;
    }
    
    //apply damage
    _HPLoss = damages;
}


@end
