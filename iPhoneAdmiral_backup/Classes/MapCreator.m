//
//  MapCreator.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapCreator.h"
#import "MapView.h"

#ifdef MAPCREATOR

@implementation MapCreator

@synthesize _MyPlacer;
@synthesize _PlacerShipType, _PlacerSoC, _PlacerCourse, _PlacerTerrain, _PlacerShipFeature;
@synthesize _PlacerWindDirection, _PlacerCurrentSide;
@synthesize _pMapView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id) initWithDefaultFrame
{
	CGRect default_frame = CGRectMake(0, 0, 480, 30);
	self = [super initWithFrame:default_frame];
    if (self) {
		
		//initialize buttons
		_PlacerShipType = -1;
		_PlacerSoC = -1;
		_PlacerCourse = -1;
		_PlacerTerrain = -1;
        _PlacerShipFeature = -1;
		_MyPlacer = Erasor;
		
		//buttons
		CGRect buttons_rect = CGRectMake(5, 0, 60, 30);
		_PlacerTypeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_PlacerTypeButton setFrame:buttons_rect];
		[self addSubview:_PlacerTypeButton];
		[_PlacerTypeButton addTarget: self
							  action: @selector(handle_PlacerTypeButton:)
					forControlEvents: UIControlEventTouchUpInside ];
		
		
		buttons_rect = CGRectMake(70, 0, 100, 30);
		_ShipTypeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_ShipTypeButton setFrame:buttons_rect];
		[self addSubview:_ShipTypeButton];
		[_ShipTypeButton addTarget: self
							action: @selector(handle_ShipTypeButton)
				  forControlEvents: UIControlEventTouchUpInside ];

		
		buttons_rect = CGRectMake(175, 0, 40, 30);
		_SideOfConflictButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_SideOfConflictButton setFrame:buttons_rect];
		[self addSubview:_SideOfConflictButton];
		[_SideOfConflictButton addTarget: self
								  action: @selector(handle_SideOfConflictButton)
						forControlEvents: UIControlEventTouchUpInside ];

		
		buttons_rect = CGRectMake(220, 0, 30, 30);
		_HexDirectionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_HexDirectionButton setFrame:buttons_rect];
		[self addSubview:_HexDirectionButton];
		[_HexDirectionButton addTarget: self
							   action: @selector(handle_HexDirectionButton)
					 forControlEvents: UIControlEventTouchUpInside ];
		
		
		buttons_rect = CGRectMake(255, 0, 40, 30);
		_ShipFeatureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_ShipFeatureButton setFrame:buttons_rect];
		[self addSubview:_ShipFeatureButton];
		[_ShipFeatureButton addTarget: self
							   action: @selector(handle_ShipFeatureButton)
					 forControlEvents: UIControlEventTouchUpInside ];
		
		
		buttons_rect = CGRectMake(300, 0, 50, 30);
		_TerrainTypeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_TerrainTypeButton setFrame:buttons_rect];
		[self addSubview:_TerrainTypeButton];
		[_TerrainTypeButton addTarget: self
							   action: @selector(handle_TerrainTypeButton)
					 forControlEvents: UIControlEventTouchUpInside ];
		
		buttons_rect = CGRectMake(370, 0, 30, 30);
		_WindDirButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_WindDirButton setFrame:buttons_rect];
		[self addSubview:_WindDirButton];
		[_WindDirButton addTarget: self
							   action: @selector(handle_WindDirectionButton)
					 forControlEvents: UIControlEventTouchUpInside ];

		buttons_rect = CGRectMake(410, 0, 40, 30);
		_CurrentSideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_CurrentSideButton setFrame:buttons_rect];
		[self addSubview:_CurrentSideButton];
		[_CurrentSideButton addTarget: self
							   action: @selector(handle_CurrentSideButton)
					 forControlEvents: UIControlEventTouchUpInside ];
		
		buttons_rect = CGRectMake(460, 0, 20, 30);
		_CloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_CloseButton setFrame:buttons_rect];
		[_CloseButton setTitle: @"V" forState:UIControlStateNormal];	
		[self addSubview:_CloseButton];
		[_CloseButton addTarget: self
							   action: @selector(handle_CloseButton)
					 forControlEvents: UIControlEventTouchUpInside ];

		
		[self handle_PlacerTypeButton:nil];
		[self handle_ShipTypeButton];
		[self handle_SideOfConflictButton];
		[self handle_HexDirectionButton];
		[self handle_TerrainTypeButton];
		[self handle_ShipFeatureButton];
		[self handle_WindDirectionButton];
		[self handle_CurrentSideButton];
		
    }
    return self;
	
}

- (void) handle_PlacerTypeButton:(id) sender
{
	NSLog(@"MAPCREATOR: handle_PlacerTypeButton");
	
	_MyPlacer = (_MyPlacer + 1) % 4;
	
	switch (_MyPlacer)
	{
		case PlaceShips:
			[_PlacerTypeButton setTitle: @"Ships" forState:UIControlStateNormal];
			[_ShipTypeButton setEnabled:YES];
			[_SideOfConflictButton setEnabled:YES];
			[_HexDirectionButton setEnabled:YES];
			[_ShipFeatureButton setEnabled:YES];
			
			[_ShipTypeButton setAlpha:1.0];
			[_SideOfConflictButton setAlpha:1.0];
			[_HexDirectionButton setAlpha:1.0];
			[_ShipFeatureButton setAlpha:1.0];

			[_TerrainTypeButton setEnabled:NO];
			[_TerrainTypeButton setAlpha:0.5];			
			break;

		case PlaceTerrain:
			[_PlacerTypeButton setTitle: @"Terrain" forState:UIControlStateNormal];
			[_ShipTypeButton setEnabled:NO];
			[_SideOfConflictButton setEnabled:NO];
			[_HexDirectionButton setEnabled:NO];
			[_ShipFeatureButton setEnabled:NO];

			[_ShipTypeButton setAlpha:0.5];
			[_SideOfConflictButton setAlpha:0.5];
			[_HexDirectionButton setAlpha:0.5];
			[_ShipFeatureButton setAlpha:0.5];
			
			[_TerrainTypeButton setEnabled:YES];	
			[_TerrainTypeButton setAlpha:1.0];			
			break;
			
		case Erasor:
			[_PlacerTypeButton setTitle: @"DEL" forState:UIControlStateNormal];
			[_ShipTypeButton setEnabled:NO];
			[_SideOfConflictButton setEnabled:NO];
			[_HexDirectionButton setEnabled:NO];
			[_ShipFeatureButton setEnabled:NO];
			[_TerrainTypeButton setEnabled:NO];
			
			[_ShipTypeButton setAlpha:0.5];
			[_SideOfConflictButton setAlpha:0.5];
			[_HexDirectionButton setAlpha:0.5];
			[_ShipFeatureButton setAlpha:0.5];
			[_TerrainTypeButton setAlpha:0.5];			
			break;			

		case Info:
			[_PlacerTypeButton setTitle: @"INFO" forState:UIControlStateNormal];
			[_ShipTypeButton setEnabled:NO];
			[_SideOfConflictButton setEnabled:NO];
			[_HexDirectionButton setEnabled:NO];
			[_ShipFeatureButton setEnabled:NO];
			[_TerrainTypeButton setEnabled:NO];	

			[_ShipTypeButton setAlpha:0.5];
			[_SideOfConflictButton setAlpha:0.5];
			[_HexDirectionButton setAlpha:0.5];
			[_ShipFeatureButton setAlpha:0.5];
			[_TerrainTypeButton setAlpha:0.5];			
			break;			
	}
}

- (void) handle_ShipTypeButton
{
	NSLog(@"MAPCREATOR: handle_ShipTypeButton");

	_PlacerShipType = (_PlacerShipType + 1) % unitTypeMax;
    
    //ship type max is actually in the middle of enumeration
    if (_PlacerShipType == shipTypeMAX) _PlacerShipType++;
    if (_PlacerShipType == fortTypeMax) _PlacerShipType += 2;
    if (_PlacerShipType == town) _PlacerShipType++;
    
	
	switch (_PlacerShipType)
	{
		case brig:
			[_ShipTypeButton setTitle: @"War Brig" forState:UIControlStateNormal];
			break;
            
        case light_brig:
			[_ShipTypeButton setTitle: @"Light Brig" forState:UIControlStateNormal];
			break;            
			
		case schooner:
			[_ShipTypeButton setTitle: @"Schooner" forState:UIControlStateNormal];
			break;
			
		case frigate:
			[_ShipTypeButton setTitle: @"Frigate" forState:UIControlStateNormal];
			break;
			
        case heavy_frigate:
			[_ShipTypeButton setTitle: @"Hvy Frigate" forState:UIControlStateNormal];
			break;
            
		case galleon:
			[_ShipTypeButton setTitle: @"Galleon" forState:UIControlStateNormal];
			break;

        case war_galleon:
			[_ShipTypeButton setTitle: @"War Galleon" forState:UIControlStateNormal];
			break;

		case ship_of_the_line:
			[_ShipTypeButton setTitle: @"4th rate" forState:UIControlStateNormal];
			break;

		case ship_of_the_line_3rd_rate:
			[_ShipTypeButton setTitle: @"3rd rate" forState:UIControlStateNormal];
			break;
            
        case small_fort:
			[_ShipTypeButton setTitle: @"Sml fort" forState:UIControlStateNormal];
			break;
            
        case med_fort:
			[_ShipTypeButton setTitle: @"Med fort" forState:UIControlStateNormal];
			break;

        case big_fort:
			[_ShipTypeButton setTitle: @"Big fort" forState:UIControlStateNormal];
			break;
            
        case town_6HP:
            [_ShipTypeButton setTitle: @"Town 6" forState:UIControlStateNormal];            
            break;
            
        case town_8HP:
            [_ShipTypeButton setTitle: @"Town 8" forState:UIControlStateNormal];            
            break;
            
        case town_10HP:
            [_ShipTypeButton setTitle: @"Town 10" forState:UIControlStateNormal];            
            break;
            
        case pinnace:
            [_ShipTypeButton setTitle: @"Pinnace" forState:UIControlStateNormal];            
            break;

        case fluyt:
            [_ShipTypeButton setTitle: @"Fluyt" forState:UIControlStateNormal];            
            break;

        case armed_fluyt:
            [_ShipTypeButton setTitle: @"Armed Fluyt" forState:UIControlStateNormal];            
            break;

        case fast_galleon:
            [_ShipTypeButton setTitle: @"Fast Galleon" forState:UIControlStateNormal];            
            break;

        default:
            NSAssert(NO, @"Unrecognized shiptype!");
            break;
	}
}

- (void) handle_SideOfConflictButton
{
	NSLog(@"MAPCREATOR: handle_SideOfConflictButton");

	_PlacerSoC = (_PlacerSoC + 1) % 2;
	
	switch (_PlacerSoC)
	{
		case RedSide:
			[_SideOfConflictButton setTitle: @"RED" forState:UIControlStateNormal];
			[_SideOfConflictButton setBackgroundColor:[UIColor redColor]];
			break;
	
		case BlueSide:
			[_SideOfConflictButton setTitle: @"BLU" forState:UIControlStateNormal];
			[_SideOfConflictButton setBackgroundColor:[UIColor blueColor]];
			break;
            
        default:
            NSLog(@"MAPCREATOR: OOOOPS!");
            break;
	}
	
}

- (void) handle_HexDirectionButton
{
	NSLog(@"MAPCREATOR: handle_HexDirectionButton");

	_PlacerCourse = (_PlacerCourse + 1) % 6;
	
	[_HexDirectionButton setTitle: courseToString(_PlacerCourse) forState:UIControlStateNormal];
}

- (void) handle_TerrainTypeButton
{
	NSLog(@"MAPCREATOR: handle_TerrainTypeButton");

	_PlacerTerrain = (_PlacerTerrain + 1) % 7;
	
	switch (_PlacerTerrain)
	{
		case TerrainDeepWater:
			[_TerrainTypeButton setTitle: @"DEEP" forState:UIControlStateNormal];
			[_TerrainTypeButton setBackgroundColor:[UIColor colorWithRed: 0.0
																   green: 74.0/255.0
																	blue: 178.0/255.0
																   alpha: 1.0]];			
			break;

		case TerrainShallowWater:
			[_TerrainTypeButton setTitle: @"SHAL" forState:UIControlStateNormal];	
			[_TerrainTypeButton setBackgroundColor:[UIColor colorWithRed: 125.0/225.0
																   green: 167.0/255.0
																	blue: 217.0/255.0
																   alpha: 1.0]];			
			break;

		case TerrainRocks:
			[_TerrainTypeButton setTitle: @"ROCK" forState:UIControlStateNormal];	
			[_TerrainTypeButton setBackgroundColor:[UIColor colorWithRed: 83.0/255.0
																   green: 71.0/255.0
																	blue: 65.0/255.0
																   alpha: 1.0]];			
			break;

		case TerrainLand:
			[_TerrainTypeButton setTitle: @"LAND" forState:UIControlStateNormal];	
			[_TerrainTypeButton setBackgroundColor:[UIColor colorWithRed: 25.0/255.0
																   green: 123.0/255.0
																	blue: 48.0/255.0
																   alpha: 1.0]];			
			break;
            
        case TerrainOBJECTIVERED:
            [_TerrainTypeButton setTitle: @"OB:R" forState:UIControlStateNormal];	
            break;
            
        case TerrainOBJECTIVEBLUE:
            [_TerrainTypeButton setTitle: @"OB:B" forState:UIControlStateNormal];	
            break;
            
        case TerrainSTRATEGIC:
            [_TerrainTypeButton setTitle: @"STR" forState:UIControlStateNormal];	
            break;

	}
}

- (void) handle_ShipFeatureButton
{
	_PlacerShipFeature = (_PlacerShipFeature + 1) % SHIP_FEATURE_MAX;
	
    switch (_PlacerShipFeature)
    {
        case NormalShip:
            [_ShipFeatureButton setTitle:@"NRM" forState:UIControlStateNormal];		
            break;

        case FlagShip:
            [_ShipFeatureButton setTitle:@"FLG" forState:UIControlStateNormal];
            break;
        
        case CargoShip:
            [_ShipFeatureButton setTitle:@"CRG" forState:UIControlStateNormal];
            break;

        case Sentinel:
            [_ShipFeatureButton setTitle:@"SNT" forState:UIControlStateNormal];
            break;
            
        case HunterKiller:
            [_ShipFeatureButton setTitle:@"H_K" forState:UIControlStateNormal];
            break;
            
        case PriorityTarget:
            [_ShipFeatureButton setTitle:@"PRT" forState:UIControlStateNormal];
            break;
            
        default:
            NSLog(@"MAPCREATOR: OOOOPS");
            break;
	}
}

- (void) handle_WindDirectionButton
{
	_PlacerWindDirection = (_PlacerWindDirection + 1) % 6;
	[_WindDirButton setTitle: courseToString(_PlacerWindDirection) forState:UIControlStateNormal];
	
	[_pMapView setWindDirection:_PlacerWindDirection];
}

- (void) handle_CurrentSideButton
{
	_PlacerCurrentSide = (_PlacerCurrentSide + 1) % 2;

	switch (_PlacerCurrentSide)
	{
		case RedSide:
			[_CurrentSideButton setTitle: @"RED" forState:UIControlStateNormal];
            NSLog(@"Setting current side to RED!");
			break;
			
		case BlueSide:
			[_CurrentSideButton setTitle: @"BLU" forState:UIControlStateNormal];
            NSLog(@"Setting current side to BLUE!");
			break;
            
        default:
            NSLog(@"MAPCREATOR: OOOOPS!");
            break;
	}
	
	[_pMapView setSideOfConflict:_PlacerCurrentSide];
}



- (void) handle_CloseButton
{
	NSLog(@"MAPCREATOR: handle_CloseButton");

    [_pMapView switchDrawingMode];
}

- (void)dealloc {	
	[_PlacerTypeButton release];
	
	[_ShipTypeButton release];
	[_SideOfConflictButton release];
	[_HexDirectionButton release];
	[_TerrainTypeButton release];

	[_CloseButton release];	
	
	[super dealloc];

	NSLog(@"* * * MAP CREATOR IS GONE * * *");	
}

@end

#endif

