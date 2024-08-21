//
//  Common.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//common typefefs, defines etc

//to launch map creator interface uncomment next line
//#define MAPCREATOR 1

//to have mapcreator edit existing maps rather than generate new, uncomment next line
//#define MAPEDITOR  1

//comment out the next line in release mode
//#define NON_RELEASE 1

//map editor requires mapcreator
#ifdef MAPEDITOR
 #define MAPCREATOR 1
#endif

//mapcreator needs non release functions...
#ifdef MAPCREATOR
 #define NON_RELEASE 1
#endif

//non release means that we enable following functionalities
#ifdef NON_RELEASE
 #define SHIP_NAMING 1          //functions needed for ship name assigning
 #define MAPVIEW_MARKERS 1      //in terrain view, objective / strategic / defensive markers are visible
 #define SPECIAL_AI_MARKERS 1   //ships in sentinel/hunterkiller mode have graphical marker
#endif

//for easy passing of bools as NSNumbers
#define YES_NUM ([NSNumber numberWithBool: YES])
#define NO_NUM  ([NSNumber numberWithBool: NO])

//testing for non_release in distribution build
#ifdef NS_BLOCK_ASSERTIONS 
 #ifdef NON_RELEASE

#error Non release mode detected in release build!

 #endif
#endif

//testing
//#define LITE_ADMIRAL

#import "UICommon.h"


@class SettingsContainer;

//settings container, made global as an alternative to passing around pointer to application...
extern SettingsContainer * AppWideSettings;

typedef enum
{
	RedSide,
	BlueSide,
	SideMAX,
} SideOfConflict;

typedef enum
{
    ResultRedSideWon = RedSide,
    ResultBlueSideWon = BlueSide,
    ResultDraw,
    ResultUndecided,
} VictoryResult;

typedef enum
{
	LEFT,
	LEFT_UP,
	RIGHT_UP,
	RIGHT,
	RIGHT_DOWN,
	LEFT_DOWN,
	
	DIRECTION_MAX,
} HexDirection;

typedef enum
{
	TurnLeft,
	TurnRight,
} TurnDirection;

typedef enum
{
	MoveImpossible,				//may not move in
	MoveOk,						//normal movement
	MoveBeached,				//big ship moves to shallow water, gets immobilized!
	MoveBoarding,				//ship initiates boarding!
	MoveBeachedAndBoarding,		//beached while boarding... why not?
    MoveToVictory,              //cargo ship moves into objective hex
} MoveResult;

typedef enum
{
    TurnImpossible = -1,
    TurnEmergency = 0,
    TurnSingleOk = 1,
    TurnDoubleOk = 2,
    TurnTripleOk = 3,           //classic mode only
} TurningAbility;

typedef enum
{
	TerrainDeepWater,
	TerrainShallowWater,
	TerrainRocks,
	TerrainLand,
    TerrainOBJECTIVERED,            //special value, reserved for objective markers
    TerrainOBJECTIVEBLUE,           //special value, reserved for objective markers
    TerrainSTRATEGIC,               //special value, reserved for hints for ai that this place is worth holding
} TerrainType;

typedef enum
{
	DamadgeByBeaching,
	DamadgeByShooting,
	DamadgeByBoarding,
	DamadgeByFire,
} DamadgeType;

typedef enum
{
    AmmoRoundShot,
    AmmoChainShot,
    AmmoGrapeShot,
    AmmoHotShot,
} AmmunitionType;

typedef enum
{
	FireNone,
	FireSmall,
	FireLarge,
	FireAblaze,
} FireSize;

typedef enum
{
	ArcNone,
	ArcLeft,
	ArcRight,
} FiringArc;


typedef enum
{
	CritNone,
	CritSailDmg,
	CritRudderDmg,
	CritMastDmg,
	CritGunDeckDmg,
	CritInfDmg,
	CritFireDmg,
    
    CritFortBatteryDmg,
    CritFortFireDmg,
    CritFortGarrisonDmg,
    CritFortMagazineDmg,
    
    CritRiggingDmg,
    CritMassInfDmg,
    
} CriticalDamadgeType;

//typedef for animation completion blocks
typedef void (^CompletionBlock_t)(BOOL); 

//typedef for animation blocks
typedef void (^AnimationBlock_t)(void);

//function that translates the filename to path to documents/filename
NSString * translateFilePath(NSString * filename);

//function that translates hexDirection to string (for printing)
NSString * courseToString(HexDirection dir);

/* calculate normalized (rounded to tens) firepower value */
int normalizedFirepowerValue(int firepower_value);

int normalizedFirePowerValue(int gun_count, int distance, AmmunitionType ammo_type);

@class Ship;

/* calculate normalized ship boarding strength */
int normalizedBoardingStrength(Ship * ship);