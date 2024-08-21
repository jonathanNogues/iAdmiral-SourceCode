//
//  Ship.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

#define SHIP_DUMMY_ID 666

@class Hex;

typedef enum
{
	ClassPicket,		//small ships
	ClassEscort,		//frigates and galleons
	ClassCapital,		//SoLs
	ClassMAX,
} ShipClass;

typedef enum
{
	brig,
	schooner,
	galleon,
	frigate,
	ship_of_the_line,                   //4th rate
    
    //the following types are VARIANTS of the previous
    //these are only used during init, later on, only 
    //the previous types are used
    
    light_brig,
    war_galleon,
    heavy_frigate,
    ship_of_the_line_3rd_rate,
    
    shipTypeMAX,        //guard for easy discerning between forts and ships

    //the following types are FORTS
    
    small_fort,
    med_fort,
    big_fort,
    
    fortTypeMax,        //guard for forts
    
    //following types are towns / cities
    //this type are for shore bombardment missions
    
    town,               //this is the type that will be used in game
    
    //following types are variants for the mapcreator
    
    town_6HP,           
    town_8HP,
    town_10HP,

    //this are the additional types that will be introduced in iAdmiral 1.3
    pinnace,
    fluyt,
    fast_galleon,
    armed_fluyt,

    
    unitTypeMax,
    
} ShipType;

@interface Ship : NSObject <NSCoding>
{
	ShipType _Type;
	NSInteger _ID;
	
	//ship stats
	NSString  * _Name;			//name of class
	NSString  * _ShipName;		//ship names are to be randomly assigned during scenario creation
	NSInteger _HitPoints;
	NSInteger _MovePoints;
	NSInteger _TurnPoints;
	NSInteger _Guns;
	NSInteger _Soldiers;
	SideOfConflict _Side;
	bool _BigShip;
	ShipClass _Class;
	
	HexDirection _Course;
	bool _Beached;
	
	//fire related
	FireSize _FireOnBoard;
	bool _TookDmgThisTurn;
	
	//turn progress stats
	NSInteger _MovePointsLeft;
	NSInteger _TurnPointsLeft;
    NSInteger _NTurnsMade;
	NSInteger _Speed;
	
	NSInteger _HitPointsLeft;
	NSInteger _BoardingsCount;		//number of boardings ship is engaged in
	
	bool _FiredLeft;
	bool _FiredRight;
	bool _FinishedMove;
	
    AmmunitionType _SelectedAmmoType;
    
	//ship position
	Hex * _CurrentHex;
	
	NSInteger _SavedHexID;
	
	//flagship data
	bool _FlagshipAfloat;
	bool _IAmFlagship;
    
    //cargoship
    bool _IAmCargoShip;
    
    //hint for ai that this ship is in defensive mode
    bool _Sentinel;
    
    //hint for ai that this ship is supposed to hunt cago ships
    bool _HunterKiller;
    
    //priority target
    bool _IAmPriorityTarget;
    
    //is this really a ship?
    bool _IAmFort;
    
    //am i a dummy?
    bool _Dummy;
}

//practically everything here needs to be acsessible to HexBoard so...
@property (nonatomic, assign) ShipType _Type;
@property (nonatomic, assign) NSInteger _ID;
@property (nonatomic, assign) NSString  * _Name;
@property (nonatomic, assign) NSString  * _ShipName;
@property (nonatomic, assign) NSInteger _HitPointsLeft;
@property (nonatomic, assign) NSInteger _HitPoints;
@property (nonatomic, assign) NSInteger _MovePoints;
@property (nonatomic, assign) NSInteger _TurnPoints;
@property (nonatomic, assign) NSInteger _Guns;
@property (nonatomic, assign) NSInteger _Soldiers;
@property (nonatomic, assign) SideOfConflict _Side;
@property (nonatomic, assign) bool _BigShip;
@property (nonatomic, assign) ShipClass _Class;
@property (nonatomic, assign) HexDirection _Course;
@property (nonatomic, assign) NSInteger _BoardingsCount;
@property (nonatomic, assign) bool _Beached;
@property (nonatomic, assign) FireSize _FireOnBoard;
@property (nonatomic, assign) bool _TookDmgThisTurn;
@property (nonatomic, assign) NSInteger _MovePointsLeft;
@property (nonatomic, assign) NSInteger _TurnPointsLeft;
@property (nonatomic, assign) NSInteger _NTurnsMade;
@property (nonatomic, assign) bool _FiredLeft;
@property (nonatomic, assign) bool _FiredRight;
@property (nonatomic, assign) bool _FinishedMove;
@property (nonatomic, assign) AmmunitionType _SelectedAmmoType;
@property (nonatomic, assign) Hex * _CurrentHex;
@property (nonatomic, assign) bool _FlagshipAfloat;
@property (nonatomic, assign) bool _IAmFlagship;
@property (nonatomic, assign) bool _IAmCargoShip;
@property (nonatomic, assign) bool _Sentinel;
@property (nonatomic, assign) bool _HunterKiller;
@property (nonatomic, assign) bool _IAmPriorityTarget;
@property (nonatomic, assign) bool _IAmFort;
@property (nonatomic, assign) bool _Dummy;

@property (nonatomic, readonly) int _MaxNormalTurns;
@property (nonatomic, readonly) NSInteger _SavedHexID;

- (Ship *) initAsType:(ShipType) type;

//fake property
- (bool) _EngagedInBoarding;

- (void) increaseBoardingCount;

- (void) decreaseBoardingCount;

#ifdef SHIP_NAMING
+ (void) resetNames;

+ (NSString *) getNameFor:(ShipType) type
                     side:(SideOfConflict) sd;

+ (void) markNameAsUsed:(NSString *) name;

+ (void) freeName:(NSString *) name;

#endif

@end
