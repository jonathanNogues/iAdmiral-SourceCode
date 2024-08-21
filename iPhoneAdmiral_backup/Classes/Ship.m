//
//  Ship.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ship.h"
#import "Hex.h"

static int sShipID = 0;

@implementation Ship

@synthesize _Type, _ID, _Name, _ShipName, _HitPoints, _HitPointsLeft, _MovePoints, _TurnPoints, 
			_Guns, _Soldiers, _Side, _BigShip, _Course, _FireOnBoard, 
			_Class, _TookDmgThisTurn, _MovePointsLeft, _TurnPointsLeft, _NTurnsMade, _FiredLeft,
			_FiredRight, _FinishedMove, _SelectedAmmoType, _CurrentHex, _Beached, _FlagshipAfloat, 
			_IAmFlagship, _SavedHexID, _IAmCargoShip, _Sentinel;

@synthesize _HunterKiller;
@synthesize _IAmPriorityTarget;
@synthesize _IAmFort;
@synthesize _Dummy;

@synthesize _BoardingsCount;


- (Ship *) initAsType:(ShipType) type
{
	[super init];
	    
    _ID = sShipID++;
	
	switch (type)
	{
		case pinnace:
			_Type = pinnace;
			_Name = @"Pinnace";
			_HitPoints = 3;
			_MovePoints = 4;
			_TurnPoints = 3;
			_Guns = 6;
			_Soldiers = 0;
			_BigShip = NO;
			_Class = ClassPicket;
			break;
            
		case brig:
			_Type = brig;
			_Name = @"War Brig";
			_HitPoints = 4;
			_MovePoints = 4;
			_TurnPoints = 3;
			_Guns = 14;
			_Soldiers = 1;
			_BigShip = NO;
			_Class = ClassPicket;
			break;
            
        case light_brig:
			_Type = brig;
			_Name = @"Brig";
			_HitPoints = 4;
			_MovePoints = 4;
			_TurnPoints = 3;
			_Guns = 8;
			_Soldiers = 0;
			_BigShip = NO;
			_Class = ClassPicket;
            break;
			
		case schooner:
			_Type = schooner;
			_Name = @"Schooner";
			_HitPoints = 5;
			_MovePoints = 4;
			_TurnPoints = 2;
			_Guns = 8;
			_Soldiers = 3;			
			_BigShip = NO;
			_Class = ClassPicket;
			break;
            
		case fluyt:
			_Type = fluyt;
			_Name = @"Fluyt";
			_HitPoints = 7;
			_MovePoints = 3;
			_TurnPoints = 2;
			_Guns = 12;
			_Soldiers = 1;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;

        case armed_fluyt:
			_Type = fluyt;
			_Name = @"Armed Fluyt";
			_HitPoints = 7;
			_MovePoints = 3;
			_TurnPoints = 2;
			_Guns = 18;
			_Soldiers = 2;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;

		case galleon:
			_Type = galleon;
			_Name = @"Galleon";
			_HitPoints = 10;
			_MovePoints = 3;
			_TurnPoints = 1;
			_Guns = 20;
			_Soldiers = 6;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;
            
        case war_galleon:
			_Type = galleon;
			_Name = @"War Galleon";
			_HitPoints = 10;
			_MovePoints = 3;
			_TurnPoints = 1;
			_Guns = 26;
			_Soldiers = 4;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;
            
        case fast_galleon:
			_Type = fast_galleon;
			_Name = @"Fast Galleon";
			_HitPoints = 10;
			_MovePoints = 4;
			_TurnPoints = 1;
			_Guns = 20;
			_Soldiers = 4;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;

		case frigate:
			_Type = frigate;
			_Name = @"Frigate";
			_HitPoints = 8;
			_MovePoints = 4;
			_TurnPoints = 2;
			_Guns = 24;
			_Soldiers = 2;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;
            
        case heavy_frigate:
			_Type = frigate;
			_Name = @"Large Frigate";
			_HitPoints = 9;
			_MovePoints = 4;
			_TurnPoints = 2;
			_Guns = 28;
			_Soldiers = 2;			
			_BigShip = YES;
			_Class = ClassEscort;
			break;

		case ship_of_the_line:
			_Type = ship_of_the_line;
			_Name = @"Fourth rate";
			_HitPoints = 12;
			_MovePoints = 3;
			_TurnPoints = 1;
			_Guns = 36;
			_Soldiers = 4;			
			_BigShip = YES;
			_Class = ClassCapital;
			break;			

        case ship_of_the_line_3rd_rate:
			_Type = ship_of_the_line;
			_Name = @"Third rate";
			_HitPoints = 14;
			_MovePoints = 3;
			_TurnPoints = 1;
			_Guns = 42;
			_Soldiers = 4;			
			_BigShip = YES;
			_Class = ClassCapital;
			break;	
            
        case small_fort:
            _Type = small_fort;
            _Name = @"Small Fort";
            _HitPoints = 6;
            _MovePoints = 0;
            _TurnPoints = 0;
            _Guns = 12;
            _Soldiers = 2;
            _BigShip = NO;
            _Class = ClassPicket;
            _IAmFort = YES;
            break;
            
        case med_fort:
            _Type = med_fort;
            _Name = @"Medium Fort";
            _HitPoints = 12;
            _MovePoints = 0;
            _TurnPoints = 0;
            _Guns = 24;
            _Soldiers = 4;
            _BigShip = YES;
            _Class = ClassEscort;
            _IAmFort = YES;
            break;

        case big_fort:
            _Type = big_fort;
            _Name = @"Large Fort";
            _HitPoints = 16;
            _MovePoints = 0;
            _TurnPoints = 0;
            _Guns = 30;
            _Soldiers = 8;
            _BigShip = YES;
            _Class = ClassCapital;
            _IAmFort = YES;
            break;
            
        case town_6HP:
            _Type = town;
            _Name = @"Town";
            _HitPoints = 6;
            _MovePoints = 0;
            _TurnPoints = 0;
            _Guns = 0;
            _Soldiers = 0;
            _BigShip = YES;
            _Class = ClassPicket;
            _IAmFort = YES;            
            break;
        
        case town_8HP:
            _Type = town;
            _Name = @"Town";
            _HitPoints = 8;
            _MovePoints = 0;
            _TurnPoints = 0;
            _Guns = 0;
            _Soldiers = 0;
            _BigShip = YES;
            _Class = ClassEscort;
            _IAmFort = YES;            
            break;

        case town_10HP:
            _Type = town;
            _Name = @"Town";
            _HitPoints = 10;
            _MovePoints = 0;
            _TurnPoints = 0;
            _Guns = 0;
            _Soldiers = 0;
            _BigShip = YES;
            _Class = ClassEscort;
            _IAmFort = YES;            
            break;
            
        default:
            NSAssert(NO, @"Unrecognized ship type!");
            break;
    }
	
	_Side = RedSide;
	
	_Course = LEFT;

	_BoardingsCount = 0;
	_Beached = NO;
	
	_FireOnBoard = FireNone;
	_TookDmgThisTurn = NO;
	
	_MovePointsLeft = _MovePoints;
	_TurnPointsLeft = _TurnPoints;
	_HitPointsLeft = _HitPoints;
	
	_NTurnsMade = 0;
	
	_FiredLeft = NO;
	_FiredRight = NO;
	
	_FlagshipAfloat = YES;
	_IAmFlagship = NO;
    
    _IAmCargoShip = NO;
    
    _Sentinel = NO;
    
    _HunterKiller = NO;
    
    _IAmPriorityTarget = NO;
	
    _Dummy = NO;
    
	return self;
}	

/* deserialization */
- (id) initWithCoder:(NSCoder *) coder
{
	self = [super init];
	
	_Type = [coder decodeIntegerForKey:@"_Type"];
	_ID = [coder decodeIntegerForKey: @"_ID"];
	
	_Name = [[coder decodeObjectForKey: @"_Name"] retain];
	_ShipName = [[coder decodeObjectForKey: @"_ShipName"] retain];
	
#ifdef MAPEDITOR
    //make sure new ships have id higher than highest here
    if (sShipID <= _ID) sShipID = _ID + 1;
    
    //remember that max is is 100!
    if (sShipID > 100) NSLog(@"WARNING: ID pool depleted!");
    
    //mark name as used
    [Ship markNameAsUsed: _ShipName];
#endif
    
	_HitPoints = [coder decodeIntegerForKey: @"_HitPoints"];
	_MovePoints =[coder decodeIntegerForKey: @"_MovePoints"];
	_TurnPoints = [coder decodeIntegerForKey: @"_TurnPoints"];
	_Guns = [coder decodeIntegerForKey: @"_Guns"];
	_Soldiers = [coder decodeIntegerForKey: @"_Soldiers"];
	_Side = [coder decodeIntegerForKey: @"_Side"];
	_BigShip = [coder decodeBoolForKey: @"_BigShip"];
	_Class = [coder decodeIntegerForKey: @"_Class"];
	
	_Course = [coder decodeIntegerForKey: @"_Course"];
	_Beached = [coder decodeBoolForKey: @"_Beached"];
	
	_FireOnBoard = [coder decodeIntegerForKey: @"_FireOnBoard"];
	_TookDmgThisTurn = [coder decodeBoolForKey: @"_TookDmgThisTurn"];
	
	_MovePointsLeft = [coder decodeIntegerForKey: @"_MovePointsLeft"];
	_HitPointsLeft = [coder decodeIntegerForKey: @"_HitPointsLeft"];
	_TurnPointsLeft = [coder decodeIntegerForKey: @"_TurnPointsLeft"];
	_NTurnsMade = [coder decodeIntegerForKey: @"_NTurnsMade"];
	_BoardingsCount = [coder decodeIntegerForKey: @"_BoardingsCount"];
	
	_FiredLeft = [coder decodeBoolForKey: @"_FiredLeft"];
	_FiredRight = [coder decodeBoolForKey: @"_FiredRight"];
	_FinishedMove = [coder decodeBoolForKey: @"_FinishedMove"];
	
	_SavedHexID = [coder decodeIntegerForKey: @"_SavedHexID"];
	
	_FlagshipAfloat = [coder decodeBoolForKey: @"_FlagshipAfloat"];
	_IAmFlagship = [coder decodeBoolForKey: @"_IAmFlagship"];
	
    _IAmCargoShip = [coder decodeBoolForKey: @"_IAmCargoShip"];

    _Sentinel = [coder decodeBoolForKey: @"_Sentinel"];

    _HunterKiller = [coder decodeBoolForKey: @"_HunterKiller"];

    _IAmPriorityTarget = [coder decodeBoolForKey: @"_IAmPriorityTarget"];

    _IAmFort = [coder decodeBoolForKey: @"_IAmFort"];
    
    //towns should get no action at all
    if (_Type == town) _FinishedMove = YES;
    
    _Dummy = NO;
    
	return self;
}

/* serialization */
- (void) encodeWithCoder:(NSCoder *) coder
{
	[coder encodeInteger:_Type forKey: @"_Type"];
	[coder encodeInteger:_ID forKey: @"_ID"];
	
	[coder encodeObject:_Name forKey: @"_Name"];
    [coder encodeObject:_ShipName forKey:@"_ShipName"];
	
	[coder encodeInteger:_HitPoints forKey: @"_HitPoints"];
	[coder encodeInteger:_MovePoints forKey: @"_MovePoints"];
	[coder encodeInteger:_TurnPoints forKey: @"_TurnPoints"];
	[coder encodeInteger:_Guns forKey: @"_Guns"];
	[coder encodeInteger:_Soldiers forKey: @"_Soldiers"];
	[coder encodeInteger:_Side forKey: @"_Side"];
	[coder encodeBool:_BigShip forKey: @"_BigShip"];
	[coder encodeInteger:_Class forKey: @"_Class"];

	[coder encodeInteger:_Course forKey: @"_Course"];
	[coder encodeBool:_Beached forKey: @"_Beached"];

	[coder encodeInteger:_FireOnBoard forKey: @"_FireOnBoard"];
	[coder encodeBool:_TookDmgThisTurn forKey: @"_TookDmgThisTurn"];

	[coder encodeInteger:_MovePointsLeft forKey: @"_MovePointsLeft"];
	[coder encodeInteger:_HitPointsLeft forKey: @"_HitPointsLeft"];
	[coder encodeInteger:_TurnPointsLeft forKey: @"_TurnPointsLeft"];
	[coder encodeInteger:_NTurnsMade forKey: @"_NTurnsMade"];
	[coder encodeInteger:_BoardingsCount forKey: @"_BoardingsCount"];
	
	[coder encodeBool:_FiredLeft forKey: @"_FiredLeft"];
	[coder encodeBool:_FiredRight forKey: @"_FiredRight"];
	[coder encodeBool:_FinishedMove forKey: @"_FinishedMove"];
	
	[coder encodeInteger:_CurrentHex._HexID forKey: @"_SavedHexID"];
		
	[coder encodeBool:_FlagshipAfloat forKey: @"_FlagshipAfloat"];
	[coder encodeBool:_IAmFlagship forKey: @"_IAmFlagship"];

	[coder encodeBool:_IAmCargoShip forKey: @"_IAmCargoShip"];
    
	[coder encodeBool:_Sentinel forKey: @"_Sentinel"];

	[coder encodeBool:_HunterKiller forKey: @"_HunterKiller"];
	
    [coder encodeBool:_IAmPriorityTarget forKey: @"_IAmPriorityTarget"];

    [coder encodeBool:_IAmFort forKey: @"_IAmFort"];

}

/* fake boarding property */
- (bool) _EngagedInBoarding
{
	return (_BoardingsCount > 0);
}

- (void) increaseBoardingCount
{
	_BoardingsCount++;	
}

- (void) decreaseBoardingCount
{
	_BoardingsCount--;
}

/* fake max normal turns property */
- (int) _MaxNormalTurns
{
    if (_BigShip) return 1;
    else return 2;
}

- (void) set_NTurnsMade:(NSInteger) newNTM
{
    _NTurnsMade = newNTM;
    if (_NTurnsMade < 0) _NTurnsMade = 0;
    if (_NTurnsMade > [self _MaxNormalTurns]) _NTurnsMade = [self _MaxNormalTurns];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"Ship %d (%@), \"%@\"", _ID, _Name, _ShipName];
}

#ifdef SHIP_NAMING

//************************** SHIP NAMING **************************

static NSArray * RedMerchantNames;
static NSArray * RedWarshipNames;
static NSArray * RedCapitalNames;

static NSArray * BlueMerchantNames;
static NSArray * BlueWarshipNames;
static NSArray * BlueCapitalNames;

static NSMutableSet * UsedNames;

+ (void) initialize
{
    RedMerchantNames = [NSArray arrayWithObjects: @"Mule", @"Beagle", @"Lion", @"Hound", @"Stallion",
                                                  @"Capricorn", @"Hind", @"Fox", @"Flurry", @"Thunder",
                                                  nil];
    
    RedWarshipNames = [NSArray arrayWithObjects: @"Surprise", @"Defense", @"Sirius", @"Warrior", @"Valorous",
                                                 @"Swift", @"Revenge", @"Vigilance", @"Helena", @"Rose",
                                                 nil];
    
    RedCapitalNames = [NSArray arrayWithObjects: @"Agamemnon", @"Ajax", @"Orion", @"Achilles", @"Neptune",
                                                 @"Leviathan", @"Colossus", @"Mars", @"Bellerophon", @"Minotaur",
                                                 nil];

    BlueMerchantNames = [NSArray arrayWithObjects: @"San Felipe", @"Santa Ana", @"La Juliana", @"Santiago", @"Manuela",
                                                   @"Magdalena", @"San Pedro", @"San Juan", @"Maria Juan", @"La Lavia",
                                                   nil];
    
    BlueWarshipNames = [NSArray arrayWithObjects: @"Iris", @"Juno", @"Tigre", @"Victoria", @"Peregrina",
                                                  @"Fidela", @"Gusana", @"Flora", @"Aurora", @"Soledad",
                                                  nil];
    
    BlueCapitalNames = [NSArray arrayWithObjects: @"Aquiles", @"Arrogante", @"Glorioso", @"Guerrero", @"Hector",
                                                  @"Soberan", @"Monarca", @"Victorioso", @"Triunfante", @"Campeon",
                                                  nil];
    
    [RedMerchantNames retain];
    [RedWarshipNames retain];
    [RedCapitalNames retain];
    
    [BlueMerchantNames retain];
    [BlueWarshipNames retain];
    [BlueCapitalNames retain];

    UsedNames = [[NSMutableSet alloc] init];
}

+ (void) resetNames
{
    [UsedNames removeAllObjects];
}

+ (NSString *) getNameFor:(ShipType) type
                     side:(SideOfConflict) sd
{
    int random = arc4random() % 10;
    NSArray * possible_names_array;
    
	switch (type)
	{
        case pinnace:
        case fluyt:
        case light_brig:
		case schooner:
		case galleon:
            if (sd == RedSide) possible_names_array = [NSArray arrayWithArray: RedMerchantNames];
            else possible_names_array = [NSArray arrayWithArray: BlueMerchantNames];
            
			break;

        case brig:
		case frigate:
        case heavy_frigate:
        case armed_fluyt:
            if (sd == RedSide) possible_names_array = [NSArray arrayWithArray: RedWarshipNames];
            else possible_names_array = [NSArray arrayWithArray: BlueWarshipNames];
			break;
            
        case fast_galleon:
        case war_galleon:
		case ship_of_the_line:
        case ship_of_the_line_3rd_rate:
            if (sd == RedSide) possible_names_array = [NSArray arrayWithArray: RedCapitalNames];
            else possible_names_array = [NSArray arrayWithArray: BlueCapitalNames];
			break;	
            
        case small_fort:
        case med_fort:
        case big_fort:
            return @"Barbella";
            break;
            
        default:
            NSAssert(NO, @"Unrecognized shiptype!");
            break;
    }
    
    NSString * potential_name = [possible_names_array objectAtIndex: random];
    
    while ([UsedNames containsObject: potential_name])
    {
        random = arc4random() % 10;
        potential_name = [possible_names_array objectAtIndex: random];
    }
    
    NSLog(@"Chosen name: %@", potential_name);
    
    [UsedNames addObject:potential_name];
    
    possible_names_array = nil;
    
    //return new string
    return [NSString stringWithString:potential_name];
}

+ (void) markNameAsUsed:(NSString *) name
{
    if (name != nil) [UsedNames addObject: name];
}

+ (void) freeName:(NSString *) name
{
    if (name != nil) [UsedNames removeObject: name];
}


#endif  //SHIP_NAMING

- (void) dealloc
{
	if (_ID != SHIP_DUMMY_ID && ! _Dummy) NSLog(@"WARNING: %@ is being DEALLOCed", self);
	
	_CurrentHex = nil;
	[_Name release];
    
    [super dealloc];
}

@end
