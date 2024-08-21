//
//  DamadgeInfo.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//class that will store information about damadge
//hexboard will have a dynamical stack of these,
//they will be created by it, and mapview will query
//and retrieve them one by one

#import "Common.h"

@class Ship;

@interface DamadgeInfo : NSObject {
	//by the time the dmginfo gets to the ui, the ship may have been dealloced, so we pass only the shipID
	int _DamagedShipID;
	
	int _HPLoss;
	int _MPLoss;
	int _TPLoss;
	int _GunLoss;
	int _SoldierLoss;
	int _FireSpread;
	bool _IsFatal;
    
    FireSize _VictimFireNow;
    
    bool _TargetWasFort;
    bool _TargetWasTown;
		
	DamadgeType _DmgType;
	CriticalDamadgeType _CritDmgType;
	
	/*
	 damadge can be:
		from shooting:
			1) hp damadge - just an integer
			2) special damadge, one of these:
				sail damadge (-1MP), loosing mast (-1 MP, -1 TP) / rudder (-1TP),
				infantry taking a hit (-1 SOL), loosing guns (- integer guns)
		
		from boarding
			1) hp damadge (integer)
			2) soldier damadge (integer)
	 
		fire damadge
			1) hp damadge
	 */
}

@property (nonatomic, readonly) int _DamagedShipID;
@property (nonatomic, readonly) int _HPLoss;
@property (nonatomic, readonly) int _MPLoss;
@property (nonatomic, readonly) int _TPLoss;
@property (nonatomic, readonly) int _GunLoss;
@property (nonatomic, readonly) int _SoldierLoss;
@property (nonatomic, readonly) int _FireSpread;
@property (nonatomic, readonly) FireSize _VictimFireNow;

@property (nonatomic, readonly) bool _IsFatal;
@property (nonatomic, readonly) bool _TargetWasFort;
@property (nonatomic, readonly) bool _TargetWasTown;

@property (nonatomic, readonly) DamadgeType _DmgType;
@property (nonatomic, readonly) CriticalDamadgeType _CritDmgType;


/* apply damadge by type */
/* second parameter is strength, when revelant. irreveleant cases it can be anything */
- (id) applyDamadgeToShip:(Ship *) victim
					 Type:(DamadgeType) dmgtype
				 Strength:(int)dmgstr
                 AmmoType:(AmmunitionType) at;

- (void) processShipDamage:(int) damages
                  AmmoType:(AmmunitionType) at;

- (void) processFortDamage:(int) damages
                  AmmoType:(AmmunitionType) at;

- (void) processTownDamage:(int) damages
                  AmmoType:(AmmunitionType) at;


@end
