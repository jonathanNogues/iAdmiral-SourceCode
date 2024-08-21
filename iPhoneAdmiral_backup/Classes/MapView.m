//
//  MapView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "HexBoard.h"
#import "Ship.h"
#import "Common.h"
#import "InterfaceView.h"
#import "OptionsView.h"

#import "DamadgeInfo.h"
#import "UIDmgNfo.h"
#import "UIBoardingNfo.h"
#import "FiringSolutionInfo.h"

#import "BIAlertView.h"

#import "AIPlayer.h"
#import "Commands.h"
#import "HexAIHints.h"		//for displaying hints

#import "StatisticsContainer.h"
#import "SettingsContainer.h"

#import "ShipSelectorView.h"

#import "IntegratedShipView.h"

#import "HitAnimSubview.h"
#import "ShootingAnimSubview.h"
#import "SplashAnimSubview.h"

//uncomment next line to force multiplayer
//#define MULTIPLAYER 1

#ifdef MAPCREATOR
#import "MapCreator.h"
#endif

//test sound
#import "SoundCenter.h"

//if you want the terrain view or the AIview, uncomment the appropriate of the following lines:
//#define TERRAIN_VIEW
//#define AIVALUES_VIEW

//when launching map creator, we want the terrain view
#ifdef MAPCREATOR
 #define TERRAIN_VIEW
 #undef AIVALUES_VIEW
#endif

//no tools on release version
#ifndef NON_RELEASE
 #undef TERRAIN_VIEW
 #undef AIVALUES_VIEW
#endif

#define SCROLLVIEW_HEIGHT	320.0
#define SCROLLVIEW_WIDTH	480.0

#define HEXSIZE 25.0

//actual cordnates of the center of hex (0, 0)
#define XOFFSET 22.0
#define YOFFSET 25.0

//map bracketing
#define TOP_BRACKET		30.0
#define BOTTOM_BRACKET	60.0		//so big because the InterfaceView hovers over mapview
#define SIDE_BRACKET	30.0

//how long does it take for the options menu to slide in/out
#define OPTIONS_VIEW_ANIM_TIME			1.0  

//time that notification view is visible
#define NOTIFICATION_TIME				2.5
#define UNTIL_CLICKED					0.0

//this is multiplied by distance the cannonballs have to fly through
#define CANNONBALL_FLIGHT_TIME			0.25

//size of navigation icons
#define NAVICON_DIM						40

#define AI_DELAY_MOVECOMMAND			1.0
#define AI_DELAY_FIGHTCOMMAND			3.5

//subview tags
#define SHIPSELECTORTAG			200
#define ROUNDSHOTTAG			201
#define CHAINSHOTTAG            202
#define GRAPESHOTTAG            203
#define CANNON_SALVO_ANIM_TAG   204
#define SALVO_HIT_ANIM_TAG      205
#define SALVO_MISS_ANIM_TAG     206

//this MUST MATCH those in RootView.m
#define OPTIONS_VIEW_TAG		1500
#define NOTIFICATION_TAG		1600
#define MAX_ZOOM_IN_SCALE		2.0
//end of those that MUST MATCH

//THIS MUST MATCH THE VALUE IN INTEGRATEDSHIPVIEW!
#define SHIPVIEW_TAG_PREFIX		3000
//this can extend up to ship number!

#define BOARDINGPREFIX			500
//this can extend upt to number of boardings

#define BOARDING_ICON_FADE_TIME 0.5

//animation IDs
#define STEERING_WHEEL_IN_ANIM_ID               102
#define STEERING_WHEEL_OUT_ANIM_ID              103
#define STEERING_WHEEL_OUT_BY_UNDO_ANIM_ID      104

//helper function for current date and time
NSString * getCurrentDateAndTime();

@implementation MapView

@synthesize _pOptionsView, _pEncapsulatingScrollView, _pInterfaceView, _CurrentSide, _zoomScale;
@synthesize _SelectedShip;

#ifdef MAPCREATOR
@synthesize _pMapCreator;
#endif

				/********************************************
				 *		CREATORS AND CREATOR UTILITIES		*
				 ********************************************/

- (id) initWithHexBoard:(HexBoard *) hb
		BGImageFileName:(NSString *) imageFileName
{
#ifdef LITE_ADMIRAL

    NSLog(@"Lite Admiral");
    
#endif
    
	//initialize the image with specified background
	_BGImageName = imageFileName;
	_BGImage = [UIImage imageNamed:_BGImageName];
    [_BGImage retain];
	
	//set hexboard for map view
	_HexBoard = hb;
		
	//initialize grid
	_HexesPerRow = [hb _HexesPerRow];
	_RowCount = [hb _RowCount];
		
#ifdef MAPCREATOR
	//define the image name, or she will crash when reading the .map file
	if (_BGImageName == nil) _BGImageName = @"rescue_map_bg.png";
	
	//create map dimensions
	float hex_width = HEXSIZE * sqrt(3);
	float board_width = hex_width * _HexBoard._HexesPerRow;

	int rc = _HexBoard._RowCount;
	int odd_rows = rc / 2 + 1;
	int even_rows = rc / 2;
	float board_height = (2 * HEXSIZE * odd_rows) + (HEXSIZE * even_rows);
	
	//bracketing
	board_width = board_width + SIDE_BRACKET * 2;
	board_height = board_height + TOP_BRACKET + BOTTOM_BRACKET;
	
	CGRect rect = CGRectMake(0.0, 0.0, board_width, board_height);
	
    NSLog(@"Map dimensions: %d x %d hexes.", _HexesPerRow, _RowCount);
	NSLog(@"Prepare image file with name: [%@] and dimensions %f x %f", _BGImageName, board_width, board_height);
    NSLog(@"Hex area size: %f x %f hexes.", board_width - 2 * SIDE_BRACKET, board_height - (TOP_BRACKET + BOTTOM_BRACKET));
    NSLog(@"Multipliy by 2 for @2x sizes.");
#else

	//get the dimensions
	CGRect rect = CGRectMake(0.0, 0.0, _BGImage.size.width, _BGImage.size.height);

#endif
	
	//initialize the view with specified frame
	[self initWithFrame:rect];
	
	//calculate zoom factor necessary for image to fit as a whole
	float wscale = _BGImage.size.width / SCROLLVIEW_WIDTH;
	float hscale = _BGImage.size.height / SCROLLVIEW_HEIGHT;
	
	if (hscale < wscale) _zoomScale = hscale;
	else _zoomScale = _zoomScale = wscale;
	_zoomScale = 1/_zoomScale;
		
	//we start in normal mode
	_inFiringMode = NO;
	_OptionsViewVisible = NO;
	
	//read which side is to play from hexboard
	_CurrentSide = _HexBoard._CurrentSide;
	
	//no ship selected yet
	_SelectedShip = nil;
	
	//create subviews for utilities (firing arcs, selector, cannonballs, etc)
	[self loadUtilSubviews];
	
	//create subviews for all the ships
	[self loadShipSubviews];
			
	//create and prepare animations
	[self loadAnimSubviews];
	
	//PREPARE AIs

#ifdef MULTIPLAYER    
    NSLog(@"Multiplayer FORCED");
    _RedPlayerAI = nil;		//red is human
    _BluePlayerAI = nil;
    _HexBoard._MultiPlayer = YES;
#else    
    
    if (_HexBoard._MultiPlayer)
    {
        NSLog(@"Multiplayer enabled, no AI");
        _RedPlayerAI = nil;		//red is human
        _BluePlayerAI = nil;
    }
    else
    {
        NSLog(@"Single Player mode, enabling blue AI");
        _BluePlayerAI = [[AIPlayer alloc] initWithBoard: _HexBoard
                                                forSide: BlueSide
                                               pMapView: self];
    }
#endif

	_GameOverDetected = NO;
		
    //DRAWING MODE
    _DrawingMode = drawBG;
    
#ifdef TERRAIN_VIEW
    _DrawingMode = drawTerrain;
#undef AIVALUES_VIEW
#endif
    
#ifdef AIVALUES_VIEW
    _DrawingMode = drawAI;
#endif
    
    //handling pause and quit
    _BattlePaused = NO;
    _NeedsDamageUpdateAfterRestart = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_PAUSE_BI
                                               object:nil];	

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_UNPAUSE_BI
                                               object:nil];	
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_QUIT_BI
                                               object:nil];	    

	return self;
}

///creates and loads all utilities subviews
- (void) loadUtilSubviews
{
	//ship selector
	_ShipSelectorSubview = [[ShipSelectorView alloc] initWithMapViewPointer: self];
	[_ShipSelectorSubview setTag: SHIPSELECTORTAG];
	[self addSubview:_ShipSelectorSubview];
    [_ShipSelectorSubview release];
	
	//create canonballs
	UIImageView * cannonballview = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"cannonballs.png"]]; 
	[cannonballview setAlpha:0.0];			//hide it initially
	[cannonballview setTag: ROUNDSHOTTAG];	//add a tag
	[self addSubview:cannonballview];		//add as subview
    [cannonballview release];               //set for autoremove later
    
	UIImageView * chainshotview = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"chainshot.png"]]; 
	[chainshotview setAlpha:0.0];			//hide it initially
	[chainshotview setTag: CHAINSHOTTAG];	//add a tag
	[self addSubview:chainshotview];		//add as subview
    [chainshotview release];                //set for autoremove later

	UIImageView * grapeshotview = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"grapeshot.png"]]; 
	[grapeshotview setAlpha:0.0];			//hide it initially
	[grapeshotview setTag: GRAPESHOTTAG];	//add a tag
	[self addSubview:grapeshotview];		//add as subview
    [grapeshotview release];                //set for autoremove later
}

///creates and loads all ship subviews
- (void) loadShipSubviews
{
	NSLog(@"Creating ship image views...\n");
	
	//first create array of all ships by merging separate sides
	NSMutableArray * allships = [[NSMutableArray alloc] initWithCapacity:100];
	
	[allships addObjectsFromArray: [_HexBoard _BlueSideShips]];
	[allships addObjectsFromArray: [_HexBoard _RedSideShips]];
	
	for (Ship * ship in allships)
    {
        IntegratedShipView * isv = [[IntegratedShipView alloc] initWithShip: ship];
        [self addSubview:isv];
        [isv release];
        
        [isv setCenter: [self calculateCenterForRow: ship._CurrentHex._Row HexInRow:ship._CurrentHex._HexInRow]];   
    }
        
	//get rid of ships
	[allships release];
}

///creates and loads animation subviews
- (void) loadAnimSubviews
{
    //the new firing animation subview
    _ShootAnimView = [[ShootingAnimSubview alloc] initWithDefaultFrame];
    [_ShootAnimView setTag:CANNON_SALVO_ANIM_TAG];
    [self addSubview: _ShootAnimView];
    [_ShootAnimView release];

    _HitAnimView = [[HitAnimSubview alloc] initWithDefaultFrame];
    [_HitAnimView setTag:SALVO_HIT_ANIM_TAG];
    [self addSubview: _HitAnimView];
    [_HitAnimView release];
    	
    _MissAnimView = [[SplashAnimSubview alloc] initWithDefaultFrame];
    [_MissAnimView setTag:SALVO_MISS_ANIM_TAG];
    [self addSubview: _MissAnimView];
    [_MissAnimView release];
    
}

							/************************
							 *		 UTILITIES		*
							 ************************/

- (void) drawHexInContext:(CGContextRef) context
			   withCenter:(CGPoint) hexCenter 
					 size:(CGFloat) hexsize
{
	CGContextMoveToPoint(context, hexCenter.x, hexCenter.y + hexsize);
	for(int i = 1; i <= 6; ++i)
	{
		CGFloat x = hexsize * sinf(i * 2.0 * M_PI / 6.0);
		CGFloat y = hexsize * cosf(i * 2.0 * M_PI / 6.0);
		CGContextAddLineToPoint(context, hexCenter.x + x, hexCenter.y + y);
	}
	
}

- (void) drawHexInContext:(CGContextRef) context
			   withCenter:(CGPoint) hexCenter 
					 size:(CGFloat) hexsize
			  TerrainType:(TerrainType) ter
             terrainAlpha:(CGFloat) ter_alpha
{
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGColorRef hex_color;
	
	switch (ter)
	{
		case TerrainDeepWater:
		{
			CGFloat components[] = {0.0, 74.0/255.0, 178.0/255.0, ter_alpha};
			hex_color = CGColorCreate( colorspace, components );
			CGContextSetFillColorWithColor (context, hex_color);
		}
			break;
			
		case TerrainShallowWater:
		{
			CGFloat components[] = {125.0/225.0, 167.0/255.0, 217.0/255.0, ter_alpha};
			hex_color = CGColorCreate( colorspace, components );
			CGContextSetFillColorWithColor (context, hex_color);
		}
			break;
			
		case TerrainRocks:
		{	
			CGFloat components[] = {83.0/255.0, 71.0/255.0, 65.0/255.0, ter_alpha};
			hex_color = CGColorCreate( colorspace, components );
			CGContextSetFillColorWithColor (context, hex_color);
		}
			break;
			
		case TerrainLand:
		{
			CGFloat components[] = {25.0/255.0, 123.0/255.0, 48.0/255.0, ter_alpha};
			hex_color = CGColorCreate( colorspace, components );
			CGContextSetFillColorWithColor (context, hex_color);
			break;
		}
            
        default:
            NSLog(@"WARNING, unrecognized terrain!");
            break;
			
	}
	
	CGContextMoveToPoint(context, hexCenter.x, hexCenter.y + hexsize);
	for(int i = 1; i < 6; ++i)
	{
		CGFloat x = hexsize * sinf(i * 2.0 * M_PI / 6.0);
		CGFloat y = hexsize * cosf(i * 2.0 * M_PI / 6.0);
		CGContextAddLineToPoint(context, hexCenter.x + x, hexCenter.y + y);
	}
	
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGColorSpaceRelease(colorspace);
	CGColorRelease(hex_color);
}

#ifdef MAPVIEW_MARKERS

- (void) drawObjectiveMarkerAt:(CGPoint) center
                     inContext:(CGContextRef) context
{
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {160/255.0, 32.0/255.0, 240/255.0, 1.0};
    CGColorRef hex_color = CGColorCreate( colorspace, components );
    CGContextSetFillColorWithColor (context, hex_color);
    
    CGFloat radius  = 10.0;
    
    CGRect marker_rect = CGRectMake(center.x - radius, center.y - radius, 2 * radius, 2 * radius);
    CGContextAddEllipseInRect(context, marker_rect);
    
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGColorSpaceRelease(colorspace);
	CGColorRelease(hex_color);
}

- (void) drawStrategicMarkerAt:(CGPoint) center
                     inContext:(CGContextRef) context
{
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 0.84, 0.0, 1.0};
    CGColorRef hex_color = CGColorCreate( colorspace, components );
    CGContextSetFillColorWithColor (context, hex_color);
    
    CGFloat radius  = 13.0;
    
    CGRect marker_rect = CGRectMake(center.x - radius, center.y - radius, 2 * radius, 2 * radius);
    CGContextAddEllipseInRect(context, marker_rect);
    
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGColorSpaceRelease(colorspace);
	CGColorRelease(hex_color);
}

- (void) drawDefensiveMarkerAt:(CGPoint) center
                     inContext:(CGContextRef) context
{
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 0.0, 0.0, 1.0};
    CGColorRef hex_color = CGColorCreate( colorspace, components );
    CGContextSetFillColorWithColor (context, hex_color);
    
    CGFloat radius  = 16.0;
    
    CGRect marker_rect = CGRectMake(center.x - radius, center.y - radius, 2 * radius, 2 * radius);
    CGContextAddEllipseInRect(context, marker_rect);
    
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGColorSpaceRelease(colorspace);
	CGColorRelease(hex_color);
}


#endif

- (void) drawHexInContext:(CGContextRef) context
			   withCenter:(CGPoint) hexCenter 
					 size:(CGFloat) hexsize
			  TerrainType:(TerrainType) ter
				 AIValues:(NSArray *) aiv
					HexID:(int) hid
{
	//first draw the terrain
	[self drawHexInContext:context
				withCenter:hexCenter
					  size:hexsize
			   TerrainType:ter
              terrainAlpha:1.0 ];

	//set font
	UIFont * fnt = [UIFont fontWithName:@"Futura-CondensedExtraBold"
								   size:9.0];
	
	//prepare colors
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGFloat white_components[] = {1.0, 1.0, 1.0, 1.0};
	CGFloat yellow_components[] = {1.0, 1.0, 0.0, 1.0};	
	CGFloat red_components[] = {1.0, 0.0, 0.0, 1.0};
	CGFloat green_components[] = {0.0, 1.0, 0.0, 1.0};
	
	CGColorRef white_color = CGColorCreate( colorspace, white_components );
	CGColorRef yellow_color = CGColorCreate( colorspace, yellow_components );
	CGColorRef red_color = CGColorCreate( colorspace, red_components );
	CGColorRef green_color = CGColorCreate( colorspace, green_components );
	
	//draw hexID
	NSString * hex_id_str = [NSString stringWithFormat:@"%d", hid];
	CGContextSetFillColorWithColor (context, yellow_color);
	CGPoint hex_id_point = CGPointMake(hexCenter.x - (hexsize / 5), hexCenter.y - hexsize);
	[hex_id_str drawAtPoint:hex_id_point
				   withFont:fnt];
		
	//prepare AI hints and positions
	NSString * str1 = [NSString stringWithFormat:@"%@", [aiv objectAtIndex: AIHint_FreedomOfManeuver]];	
	NSString * str2 = [NSString stringWithFormat:@"%@", [aiv objectAtIndex: AIHint_FreedomOfManeuver_BigShip]];	
	NSString * str3 = [NSString stringWithFormat:@"%@", [aiv objectAtIndex: AIHint_EnemyFirepower]];
	NSString * str4 = [NSString stringWithFormat:@"%@", [aiv objectAtIndex: AIHint_EnemyBoardingStrength]];

	CGPoint str1_point = CGPointMake(hexCenter.x - 20, hexCenter.y - 10);
	CGPoint str2_point = CGPointMake(hexCenter.x - 20, hexCenter.y);
	CGPoint str3_point = CGPointMake(hexCenter.x - 5, hexCenter.y - 10);
	CGPoint str4_point = CGPointMake(hexCenter.x - 5, hexCenter.y);
	
	//set color to white
	CGContextSetFillColorWithColor (context, white_color);

	//draw ai maneuverability hints
	[str1 drawAtPoint:str1_point withFont:fnt];
	[str2 drawAtPoint:str2_point withFont:fnt];

	//set color to red
	CGContextSetFillColorWithColor (context, red_color);
	//draw firepower hint
	[str3 drawAtPoint:str3_point withFont:fnt];

	//set color to green
	CGContextSetFillColorWithColor (context, green_color);
	//draw boarding hint
	[str4 drawAtPoint:str4_point withFont:fnt];
	
	CGColorSpaceRelease(colorspace);
	CGColorRelease(white_color);
	CGColorRelease(yellow_color);
	CGColorRelease(red_color);
	CGColorRelease(green_color);
}


- (void) drawHexes
{
	//Houston, we've got a context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//s.e.
	CGContextSetLineWidth(context, 1.0);
	
	//colorspace rgb
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	
	//kolor w rgb + opacity
	CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
	CGColorRef hex_color = CGColorCreate( colorspace, components );
	
	//s.e.
	CGContextSetStrokeColorWithColor(context, hex_color);
	
	//DRAWING
	
	//consecutive hexes center
	//CGPoint hexCenter = CGPointMake(XOFFSET, YOFFSET);
	//CGPoint originalHexCenter = CGPointMake(XOFFSET, YOFFSET);
	//bracketing
	CGPoint hexCenter = CGPointMake(XOFFSET + SIDE_BRACKET, YOFFSET + TOP_BRACKET);
	CGPoint originalHexCenter = CGPointMake(XOFFSET + SIDE_BRACKET, YOFFSET + TOP_BRACKET);	
	
	//hexboard dimensions
	int hexes_per_row = _HexesPerRow;
	int row_count = _RowCount;
	int hexes_this_row;
	CGFloat side_switch = 1.0;
	
	//hexsize
	CGFloat hexsize = HEXSIZE;
	
	for (int c_row = 0; c_row < row_count; c_row++)
	{
		if ( c_row %2 == 0 )
		{
			hexes_this_row = hexes_per_row;
			side_switch = 1.0;
		}
		else 
		{
			hexes_this_row = hexes_per_row - 1;
			side_switch = 0.0;
		}
		
		for (int c_hex = 0; c_hex < hexes_this_row; c_hex++)
		{
			//draw single hex around center
			[self drawHexInContext:context withCenter:hexCenter size:hexsize];
			hexCenter.x += hexsize * sqrt(3);
		}
		
		hexCenter.x = originalHexCenter.x + (side_switch * (hexsize * sqrt(3) / 2));
		hexCenter.y += hexsize * 1.5;
	}
	
	//draw path
	CGContextStrokePath(context);
	
	//release
	CGColorSpaceRelease(colorspace);
	CGColorRelease(hex_color);
}

/// Used to draw terrain
- (void) drawTerrain:(CGFloat) terrainAlpha
{
	//Houston, we've got a context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//s.e.
	CGContextSetLineWidth(context, 1.0);
		
	//DRAWING
	
	//consecutive hexes center
	//CGPoint hexCenter = CGPointMake(XOFFSET, YOFFSET);
	//CGPoint originalHexCenter = CGPointMake(XOFFSET, YOFFSET);
	//bracketing
	CGPoint hexCenter = CGPointMake(XOFFSET + SIDE_BRACKET, YOFFSET + TOP_BRACKET);
	CGPoint originalHexCenter = CGPointMake(XOFFSET + SIDE_BRACKET, YOFFSET + TOP_BRACKET);	
	
	//hexboard dimensions
	int hexes_per_row = _HexesPerRow;
	int row_count = _RowCount;
	int hexes_this_row;
	CGFloat side_switch = 1.0;
	
	//hexsize
	CGFloat hexsize = HEXSIZE;
	
	for (int c_row = 0; c_row < row_count; c_row++)
	{
		if ( c_row %2 == 0 )
		{
			hexes_this_row = hexes_per_row;
			side_switch = 1.0;
		}
		else 
		{
			hexes_this_row = hexes_per_row - 1;
			side_switch = 0.0;
		}
		
		for (int c_hex = 0; c_hex < hexes_this_row; c_hex++)
		{
			//draw single hex around center
			//[self drawHexInContext:context withCenter:hexCenter size:hexsize];
			
			[self drawHexInContext:context 
						withCenter:hexCenter 
							  size:hexsize - 1
					   TerrainType:[_HexBoard getTerrainOfRow:c_row HexInRow:c_hex]
                      terrainAlpha:terrainAlpha ];

#ifdef MAPVIEW_MARKERS			
            
            if ( [_HexBoard getDefensiveAtRow:c_row HexInRow:c_hex] )[self drawDefensiveMarkerAt:hexCenter inContext:context];
            if ( [_HexBoard getStrategicAtRow:c_row HexInRow:c_hex] )[self drawStrategicMarkerAt:hexCenter inContext:context];
            if ( [_HexBoard getObjectiveAtRow:c_row HexInRow:c_hex] )[self drawObjectiveMarkerAt:hexCenter inContext:context];
                
#endif
            hexCenter.x += hexsize * sqrt(3);
		}
		
		hexCenter.x = originalHexCenter.x + (side_switch * (hexsize * sqrt(3) / 2));
		hexCenter.y += hexsize * 1.5;
	}
	
	//draw path
	CGContextStrokePath(context);
}

/// Used to draw AI values
- (void) drawAIValues
{
	//Houston, we've got a context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//s.e.
	CGContextSetLineWidth(context, 1.0);
	
	//DRAWING
	
	//consecutive hexes center
	//CGPoint hexCenter = CGPointMake(XOFFSET, YOFFSET);
	//CGPoint originalHexCenter = CGPointMake(XOFFSET, YOFFSET);
	//bracketing
	CGPoint hexCenter = CGPointMake(XOFFSET + SIDE_BRACKET, YOFFSET + TOP_BRACKET);
	CGPoint originalHexCenter = CGPointMake(XOFFSET + SIDE_BRACKET, YOFFSET + TOP_BRACKET);	
	
	//hexboard dimensions
	int hexes_per_row = _HexesPerRow;
	int row_count = _RowCount;
	int hexes_this_row;
	CGFloat side_switch = 1.0;
	
	//hexsize
	CGFloat hexsize = HEXSIZE;
	
	for (int c_row = 0; c_row < row_count; c_row++)
	{
		if ( c_row %2 == 0 )
		{
			hexes_this_row = hexes_per_row;
			side_switch = 1.0;
		}
		else 
		{
			hexes_this_row = hexes_per_row - 1;
			side_switch = 0.0;
		}
		
		for (int c_hex = 0; c_hex < hexes_this_row; c_hex++)
		{
			//draw single hex around center
			[self drawHexInContext:context
						withCenter:hexCenter
							  size:hexsize - 2
					   TerrainType:[_HexBoard getTerrainOfRow:c_row HexInRow:c_hex]
						  AIValues:[_HexBoard getAIHintValuesForHexRow:c_row HexInRow:c_hex]
							 HexID:(c_row * hexes_per_row) - (c_row / 2) + c_hex];
			
			hexCenter.x += hexsize * sqrt(3);
		}
		
		hexCenter.x = originalHexCenter.x + (side_switch * (hexsize * sqrt(3) / 2));
		hexCenter.y += hexsize * 1.5;
	}
	
	//draw path
	CGContextStrokePath(context);
	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    switch (_DrawingMode)
    {
        case drawAI:
            [self drawAIValues];
            break;
            
        case drawTerrain:
            [self drawTerrain: 1.0];
            break;
            
        case drawTerrainOverBG: //superimpose terrain view over the bg view
            [_BGImage drawAtPoint: CGPointMake(0, 0)];
            [self drawTerrain: 0.3];
            break;

        case drawBG:
            [_BGImage drawAtPoint: CGPointMake(0, 0)];
            break;
    }
}

/* centers the view at given coordinates */
- (void) zoomToX:(CGFloat) x
			   Y:(CGFloat) y
{
	CGRect zoomRect;
	
	zoomRect.size.width = _pEncapsulatingScrollView.bounds.size.width;
	zoomRect.size.height = _pEncapsulatingScrollView.bounds.size.height;
	
	zoomRect.origin.x = x - (zoomRect.size.width  / 2.0);
	zoomRect.origin.y = y - (zoomRect.size.height / 2.0);
	
	[_pEncapsulatingScrollView zoomToRect:zoomRect animated:YES];
}

/* zooms to coordinates of given ship */
- (void) zoomToShip:(Ship *) ship
{
	CGPoint zoom_target = [self calculateCenterForRow: ship._CurrentHex._Row
											 HexInRow: ship._CurrentHex._HexInRow ];
	
	[self zoomToX: zoom_target.x
				Y: zoom_target.y ];
}
					/******************
					 *	Calculations  *
					 ******************/

- (CGPoint) calculateCenterForRow:(int) row
						 HexInRow:(int) hir
{
	CGFloat x = XOFFSET + (sqrt(3) * HEXSIZE * hir);
	CGFloat y = YOFFSET + (1.5 * HEXSIZE * row);
	
	if (row % 2 == 1) x += sqrt(3) * HEXSIZE / 2;
	
	//taking into account the new map layout with bracketing of mapview
	x = x + SIDE_BRACKET;
	y = y + TOP_BRACKET;
	
	return CGPointMake(x, y);
}

- (CGPoint) calculateCenterOfVisibleRect
{
	CGRect visibleRect;
	visibleRect.origin = _pEncapsulatingScrollView.contentOffset;
	visibleRect.size = _pEncapsulatingScrollView.bounds.size;
	
	//calculate teh scale
	CGFloat scale = (CGFloat) _pEncapsulatingScrollView.zoomScale;
	
	//NSLog(@"Currently visible rect before scaling: %@", NSStringFromCGRect(visibleRect));
	//NSLog(@"Current zoomscale: %f", scale);
	
	if (scale != 1.0)	//adjust for zooming
	{
		float theScale = 1.0 / scale;			//performance optimallization 
		visibleRect.origin.x *= theScale;
		visibleRect.origin.y *= theScale;
		visibleRect.size.width *= theScale;
		visibleRect.size.height *= theScale;
	}
	
	//NSLog(@"Currently visible rect after scaling: %@", NSStringFromCGRect(visibleRect));
	
	float x = visibleRect.origin.x + visibleRect.size.width / 2;
	float y = visibleRect.origin.y + visibleRect.size.height / 2;
	
	//NSLog(@"Calculated center as: %f, %f", x, y);
	
	return CGPointMake(x, y);
	
}

					/***********************
					 *	Animation Related  *
					 ***********************/

/* a function to deal with different animation finishing, to avoid functions with meaningless parameters */
- (void) animationCentral:(NSString *)animationID
				 finished:(NSNumber *)finished
				  context:(void *)context
{
	int animID = atoi( [animationID UTF8String] );
	
	NSLog(@"Animation central - animation with id %d finished!", animID);
	
	switch (animID)
	{
		case STEERING_WHEEL_IN_ANIM_ID:
			NSLog(@"AnimationCentral: steering wheel is in!");
			[_pInterfaceView resetWindButton];
			break;
			
		case STEERING_WHEEL_OUT_ANIM_ID:
        case STEERING_WHEEL_OUT_BY_UNDO_ANIM_ID:
			NSLog(@"AnimationCentral: steering wheel is out!");
			
			[_pEncapsulatingScrollView sendSubviewToBack: [_pEncapsulatingScrollView viewWithTag:OPTIONS_VIEW_TAG]];
			[[_pEncapsulatingScrollView viewWithTag:OPTIONS_VIEW_TAG] setAlpha:0.0];
			[[_pEncapsulatingScrollView viewWithTag:OPTIONS_VIEW_TAG] setUserInteractionEnabled:NO];
			
			//re-enable user interaction with the game board
			[self setUserInteractionEnabled:YES];
			[_pEncapsulatingScrollView setScrollEnabled:YES];
			[_pEncapsulatingScrollView setMinimumZoomScale:_zoomScale];
			[_pEncapsulatingScrollView setMaximumZoomScale:MAX_ZOOM_IN_SCALE];
			
			//reenable optiosn (wind) button and other buttons of the interface
			[_pInterfaceView resetWindButton];
			[_pInterfaceView resetOtherButtons];
			
            if (animID == STEERING_WHEEL_OUT_BY_UNDO_ANIM_ID) [self performUndo:(Ship *)context];
            
            //autohiding
            [_pInterfaceView launchAutoHideTimer];
            
			break;
			
		default:
			NSLog(@"Animation central does not have a plan for this one!");
			
	}
}

/* perform scroll sequence */
- (void) performScrollSequence:(NSTimer *) timer
{
	NSMutableArray * zoom_points = (NSMutableArray *) [timer userInfo];
	
	if ([zoom_points count] == 0)
	{
		[timer invalidate];
	}
	else
	{
		NSValue * pval = [zoom_points objectAtIndex: 0];
		CGPoint next_point = [pval CGPointValue];
		[zoom_points removeObjectAtIndex: 0];
		
		[self zoomToX: next_point.x
					Y: next_point.y ];
	}
}
					/****************************
					 *	UI Elements Visibility  *
					 ****************************/

/* set navigational items visibility */
- (void) setNavAidVisibilitySelector:(bool) sel_vis
								move:(bool) m_vis
								turn:(bool) t_vis
							  anchor:(bool) a_vis
{
	int course = _SelectedShip._Course;
	
	CGPoint SelectorCenter = [self calculateCenterForRow:_SelectedShip._CurrentHex._Row
												HexInRow:_SelectedShip._CurrentHex._HexInRow ];
	
	_ShipSelectorSubview.center = SelectorCenter;
	
	_ShipSelectorSubview.transform = CGAffineTransformMakeRotation(course * 60 * M_PI / 180);
	
    //adjust selector size
    [_ShipSelectorSubview adjustIconPositionForShip: _SelectedShip];
    
	[_ShipSelectorSubview setVisibilityForSelector: sel_vis
										  goButton: m_vis
										  tlButton: t_vis
										  trButton: t_vis
									  anchorButton: a_vis ];
	
    if (sel_vis) 
    {
        //bring it over other ships
        [self bringSubviewToFront:_ShipSelectorSubview];
        //but not over the selected one - if it ain't boarding
        if (_SelectedShip._BoardingsCount == 0)
            [self bringSubviewToFront:[self viewWithTag:SHIPVIEW_TAG_PREFIX + _SelectedShip._ID]];
    }
}

/* set combat aid items visibility */
- (void) setCombatAidVisibilitySelector:(bool) sel_vis
						  leftFiringArc:(bool) l_vis
						 rightFiringArc:(bool) r_vis
                          fortFiringArc:(bool) f_vis
                          ammoChoiceBox:(bool) ammo_vis
{
	int course = _SelectedShip._Course;
	
	CGPoint SelectorCenter = [self calculateCenterForRow:_SelectedShip._CurrentHex._Row
												HexInRow:_SelectedShip._CurrentHex._HexInRow ];
	
	_ShipSelectorSubview.center = SelectorCenter;
	
	_ShipSelectorSubview.transform = CGAffineTransformMakeRotation(course * 60 * M_PI / 180);

	[_ShipSelectorSubview setVisibilityForSelector: sel_vis
									 leftFiringArc: l_vis
									rightFiringArc: r_vis 
                                     fortFiringArc:f_vis];
    
    //fire arcs should appear BELOW other ships
    [self sendSubviewToBack: _ShipSelectorSubview];
    
    if (ammo_vis)
    {
        [_pInterfaceView setAmmoChooserStateTo: StateVisible];
        [_pInterfaceView setSelectedAmmoTypeTo: _SelectedShip._SelectedAmmoType];
    }
    else [_pInterfaceView setAmmoChooserStateTo: StateHidden];
}


/* shows / hides the options menu */
- (void) setOptionsMenuVisibile:(bool) vis
               byUndoMoveButton:(bool) umb
                    undoingShip:(Ship *) undoed_ship
{
    CGPoint center_in_screen;
    CGPoint center_out_screen = CGPointMake(240.0, 410.0);
    
    //check if interface is hidden or not
    if (_pInterfaceView._isHidden)
        center_in_screen = CGPointMake(240.0, 220.0);
    else
        center_in_screen = CGPointMake(240.0, 200.0);        
    
    if (vis)
    {
		//prepare optionsview for animation (position and visibility)
		[_pOptionsView setCenter:center_out_screen];
		[_pOptionsView setAlpha:1.0];
        
		//roll em in
		[UIView beginAnimations:[NSString stringWithFormat:@"%d", STEERING_WHEEL_IN_ANIM_ID] context:nil];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector:@selector(animationCentral:finished:context:)];
		[UIView setAnimationDuration: OPTIONS_VIEW_ANIM_TIME];
		[_pOptionsView setCenter:center_in_screen];
		[UIView commitAnimations];
        
        //if this shows up, disable clicking on the board for the moment
		[self setUserInteractionEnabled:NO];
		//disabling zooming and scrolling as well
		[_pEncapsulatingScrollView setScrollEnabled:NO];
		[_pEncapsulatingScrollView setMinimumZoomScale:1.0];
		[_pEncapsulatingScrollView setMaximumZoomScale:1.0];
		
		//but interaction with the options view is by all means welcome
		[_pOptionsView setUserInteractionEnabled:YES];
    }
    else
    {
        //check if this was done by undo move button
        NSString * animID;
        Ship * ship_to_undo;
        if (umb)
        {
            animID = [NSString stringWithFormat:@"%d", STEERING_WHEEL_OUT_BY_UNDO_ANIM_ID];
            ship_to_undo = undoed_ship;
        }
        else 
        {
            animID = [NSString stringWithFormat:@"%d", STEERING_WHEEL_OUT_ANIM_ID];
            ship_to_undo = nil;
        }
        
		[UIView beginAnimations:animID context:ship_to_undo];
        [UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector:@selector(animationCentral:finished:context:)];
		[UIView setAnimationDuration: OPTIONS_VIEW_ANIM_TIME];
		[_pOptionsView setCenter:center_out_screen];
		[UIView commitAnimations];	
    }
}

//animate single boarding update
- (void) animateBoarding:(UIBoardingNfo *) bai
{
	if (bai._BoardingState == BoardingCreated)
	{
		NSLog(@"Creating new boarding icon!");
		
		CGPoint pointa = [self calculateCenterForRow: bai.shipA_row
											HexInRow: bai.shipA_hrw];
		CGPoint pointb = [self calculateCenterForRow: bai.shipB_row
											HexInRow: bai.shipB_hrw];
		CGPoint center = CGPointMake( (pointa.x + pointb.x) / 2, (pointa.y + pointb.y) / 2);
		
		UIImageView * board_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boarding.png"]];
		[board_icon setCenter:center];
		[board_icon setTag: BOARDINGPREFIX + bai._BoardingID];
		[board_icon setAlpha:0.0];
		[self addSubview:board_icon];
		[self bringSubviewToFront:board_icon];
		
		//animate (fade in)
        AnimationBlock_t anim_block = 
        ^{
            [board_icon setAlpha: 1.0];
        };

        [UIView animateWithDuration: BOARDING_ICON_FADE_TIME
                         animations: anim_block
                         completion: nil ];
		
	}
	
	if (bai._BoardingState == BoardingFinished || bai._BoardingState == BoardingContinues)
	{
		NSLog(@"Removing boarding icon with ID: %d!", bai._BoardingID);
		UIView * uiv = [self viewWithTag:BOARDINGPREFIX + bai._BoardingID];
		
		//animate (fade out) then remove
        AnimationBlock_t anim_block = 
        ^{
            [uiv setAlpha:0.0];
        };
        
        CompletionBlock_t comp_block = 
        ^(BOOL fin){
            [uiv removeFromSuperview];
            [uiv release];
            
            [self handleDamage];
        };

        [UIView animateWithDuration: BOARDING_ICON_FADE_TIME
                         animations: anim_block
                         completion: comp_block ];
	}
}
						/********************************
						 *		 TOUCH RESPONDERS		*
						 ********************************/

- (void) touchesEnded:(NSSet *)touches 
			withEvent:(UIEvent *)event
{	
	
	UITouch *touch = [touches anyObject];
	_LastTapLocation = [touch locationInView:self];

	
	if ([touch tapCount] == 1)
	{
		[self handleSingleTap];			//single tap = perform actions
	} 
	else if([touch tapCount] == 2)		//double tap = zoom on touched place (but actions get performed as well)
	{
		[self handleDoubleTap];
	}
}

- (void) handleSingleTap
{
	CGFloat x = _LastTapLocation.x;
	CGFloat y = _LastTapLocation.y;
	
	//basically works, needs refining of theese values
	NSInteger yoffset = YOFFSET - (HEXSIZE);
	NSInteger xoffset = XOFFSET - (HEXSIZE * sqrt(3) / 2);
	
	//bracketing
	yoffset += TOP_BRACKET;
	xoffset += SIDE_BRACKET;
	
	NSInteger RowNo = (y - yoffset) / (HEXSIZE * 1.5);
	
	if (RowNo % 2 == 1) xoffset += HEXSIZE * sqrt(3) / 2;
	
	NSInteger HexInRow = (x - xoffset) / (sqrt(3) * HEXSIZE);
	
    //guard for clicking below the botton of the map, which could cause a crash
    if (RowNo >= _RowCount) return;
        
	//after last modifications, we no longer select hexes.
	//we check if there is a ship on hex that got clicked,
	//and select it if true
		
	Ship * ship = [_HexBoard getShipAtRow:RowNo HexInRow:HexInRow];
	
	if (ship != nil)
	{
		//decision making time - if we are in firing mode and the ship is an enemy vessel
		//in range - we should fire!
		
		if (_inFiringMode && ship._Side != _CurrentSide)
		{
			NSLog(@"Fire Fire Fire!\n");
			[ self handleShipToShipFire:ship ];
			return;
		}
		
		_SelectedShip = ship;

        [globalSoundCenter playEffect:SOUND_CLICK];
        
		[self handleShipSelected];
	}
	
#ifdef MAPCREATOR
	
	//check if it was not dealloced
	if (_pMapCreator == nil) return;
	
	switch(_pMapCreator._MyPlacer)
	{
		case PlaceShips:
		{
			//add new ship
			Ship * new_ship = [[Ship alloc] initAsType:_pMapCreator._PlacerShipType];

            //all forts are facing LEFT by design
            if (new_ship._IAmFort)
                new_ship._Course = LEFT;
            else 
                new_ship._Course = _pMapCreator._PlacerCourse;
            
			new_ship._Side = _pMapCreator._PlacerSoC;
			
            if (_pMapCreator._PlacerShipFeature == FlagShip) new_ship._IAmFlagship = YES;
            if (_pMapCreator._PlacerShipFeature == CargoShip) new_ship._IAmCargoShip = YES;
            if (_pMapCreator._PlacerShipFeature == Sentinel) new_ship._Sentinel = YES;
            if (_pMapCreator._PlacerShipFeature == HunterKiller) new_ship._HunterKiller = YES;
            if (_pMapCreator._PlacerShipFeature == PriorityTarget) new_ship._IAmPriorityTarget = YES;
            
            //generate name for all but towns
            if (new_ship._Type != town)
                new_ship._ShipName = [[Ship getNameFor:_pMapCreator._PlacerShipType         //placer ship type gives more detailed ship type!
                                                  side:_pMapCreator._PlacerSoC] retain];
            
			[_HexBoard addShip: new_ship
						 AtRow: RowNo
					  HexInRow: HexInRow ];
					
			//create subview for it...
            IntegratedShipView * isv = [[IntegratedShipView alloc] initWithShip: new_ship];
            [self addSubview:isv];
            [isv setCenter: [self calculateCenterForRow: new_ship._CurrentHex._Row HexInRow:new_ship._CurrentHex._HexInRow]];    
		}
			break;
			
		case PlaceTerrain:
            [_HexBoard SetTerrainTo: _pMapCreator._PlacerTerrain
							 ForRow: RowNo
						   HexInRow: HexInRow ];
			break;
			
		case Erasor:
		{
            IntegratedShipView * isv = (IntegratedShipView *)[self viewWithTag:_SelectedShip._ID + SHIPVIEW_TAG_PREFIX];
			[isv removeFromSuperview];
			
			[_HexBoard sinkShip:_SelectedShip];
            _SelectedShip = nil;

            [self setNavAidVisibilitySelector: NO
                                         move: NO
                                         turn: NO
                                       anchor: NO ];            
		}
			break;
			
		case Info:
			break;
	}
	
	[self setNeedsDisplay];
	
#endif
	
}

- (void) handleDoubleTap
{
	CGFloat x = _LastTapLocation.x;
	CGFloat y = _LastTapLocation.y;
	
	//zoooooom!
	[self zoomToX:x Y:y];
}

					/************************************
					 *		 CONTROLLER FUNCTIONS		*
					 ************************************/
- (void) handleShipSelected
{	
    
    NSLog(@"Selected %@", _SelectedShip);
    
	int row = _SelectedShip._CurrentHex._Row;
	int hir = _SelectedShip._CurrentHex._HexInRow;
	
	int mp = _SelectedShip._MovePointsLeft;
	int tp = _SelectedShip._TurnPointsLeft;
    
    //interface autohiding
    if (!_AIsTurn)      //no interface on ai turn
    {
        [_pInterfaceView set_isHidden: NO];
        [_pInterfaceView launchAutoHideTimer];
    }
    
	[_pInterfaceView setShipDataHP:_SelectedShip._HitPointsLeft
							  Guns:_SelectedShip._Guns 
						  Soldiers:_SelectedShip._Soldiers ];
		
	//if this ship was not on current side, this is as far as we go
	if (_SelectedShip._Side != _CurrentSide)
	{
		//if this is the enemy ship, display general data, not points left!
		[_pInterfaceView updateShipDataMP:_SelectedShip._MovePoints 
									   TP:_SelectedShip._TurnPoints
									Turns:[_HexBoard canShipTurn: _SelectedShip] ];
		
		
		NSLog(@"She ain't ours yarr!\n");
		[self setNavAidVisibilitySelector: NO
									 move: NO
									 turn: NO
								   anchor: NO ];
                
		return;
	}
    
	//set the second part of the interface with current ship data
	[_pInterfaceView updateShipDataMP: mp
								   TP: tp
                                Turns:[_HexBoard canShipTurn: _SelectedShip] ];
	
	if (_AIsTurn)
	{
		[self zoomToShip:_SelectedShip];
		
		[self setNavAidVisibilitySelector: NO
									 move: NO
									 turn: NO
								   anchor: NO ];
	
		[self setCombatAidVisibilitySelector: NO
							   leftFiringArc: NO
							  rightFiringArc: NO
                               fortFiringArc: NO
                               ammoChoiceBox: NO];
		
		return;
	}
	
	[self setCombatAidVisibilitySelector: NO
						   leftFiringArc: NO
						  rightFiringArc: NO 
                           fortFiringArc: NO
                           ammoChoiceBox: NO];
	_inFiringMode = NO;
	
	//check if it is not engaged in boarding or immobilized
	bool ok_to_move = !(_SelectedShip._Beached || _SelectedShip._BoardingsCount > 0);
	
	//check whether to display move icon
	MoveResult mr = [_HexBoard CanMoveShipAtRow:row AndHex:hir ignoreMPCost:NO];
	bool ship_can_move = (ok_to_move && mp > 0 && mr != MoveImpossible);
	
	//check whether to display turn icon
    bool ship_can_turn = ([_HexBoard canShipTurn:_SelectedShip] != TurnImpossible);
    
	//check whether to display anchor icon
	bool ship_can_finish_turn = !(_SelectedShip._BoardingsCount > 0);
	    
	//set icon visivility
	[self setNavAidVisibilitySelector: YES
								 move: ship_can_move
								 turn: ship_can_turn
							   anchor: ship_can_finish_turn ];
}

/* selected ship fires at given target */
- (void) handleShipToShipFire:(Ship *) target
{	
	//find the firer and target centers, because passing command to the hexboard can dealloc the ship if it sinks
	
	//find the firing ship center
	CGPoint shooter_center = [self calculateCenterForRow: _SelectedShip._CurrentHex._Row 
												HexInRow: _SelectedShip._CurrentHex._HexInRow ];
	
	CGPoint target_center = [self calculateCenterForRow: target._CurrentHex._Row 
											   HexInRow: target._CurrentHex._HexInRow ];
	
    //prepare hit and miss animations
    [_HitAnimView setCenter: target_center];
    [_HitAnimView prepareWithShip:target];
    
    [_MissAnimView setCenter: target_center];
    [_MissAnimView prepareWithShip: target
                      andFirepower: _SelectedShip._Guns];
    
    FiringSolutionInfo * fsi = [_HexBoard fireFrom:_SelectedShip
                                            atShip:target ];
    
	//if fire was impossible, tell the user why
	if (! fsi._FiringSuccesfull )
	{
		NSLog(@"Fire impossible, reason recieved: %@", fsi._Reason);
				
        _CurrentBIAlert = [[BIAlertView alloc] initWithAlertType: AlertTypeShootingFail
                                                         message: fsi._Reason
                                                        delegate: self
                                                     cancelDelay: NOTIFICATION_TIME ];
        
        [_CurrentBIAlert show];
		return;
	}
        
    //disable the ui until the animation is finished
    [self setUserInteractionEnabled: NO];
    [_pInterfaceView setUserInteractionEnabled: NO];
    
            //	FIRING ANIMATION
    [self bringSubviewToFront:_ShootAnimView];
    [_ShootAnimView setCenter: shooter_center];
    [_ShootAnimView prepareWithShip: _SelectedShip
                          firingArc: fsi._FiringArc];
    [_ShootAnimView performAnimation];
    
            //  FIRING SOUND
    
    [globalSoundCenter playEffect:SOUND_CANNON_SALVO];
    
			//	SHOT ANIMATIONS
	
    //find appropriate view
    UIView * shot_view;
    
    switch (_SelectedShip._SelectedAmmoType)
    {
        case AmmoRoundShot:
            shot_view = [self viewWithTag:ROUNDSHOTTAG];
            break;
            
        case AmmoChainShot:
            shot_view = [self viewWithTag:CHAINSHOTTAG];
            break;
            
        case AmmoGrapeShot:
            shot_view = [self viewWithTag:GRAPESHOTTAG];
            break;
            
        case AmmoHotShot:
            break;
    }
    
	//first move the cannonballs to firing ship
	shot_view.center =  shooter_center;
	
	//and make them visible
	shot_view.alpha = 1.0;	
	[self bringSubviewToFront: shot_view];
	
    AnimationBlock_t anim_block =
    ^{
        shot_view.center =  target_center;
    };
    
    CompletionBlock_t comp_block = 
    ^(BOOL fin){
        //hide the cannonballs
        shot_view.alpha = 0.0;
        
        //check whether to launch hit or miss animation
        if (fsi._DamageDealt) 
        {
            [_HitAnimView performAnimation];
            [self bringSubviewToFront: _HitAnimView];
        }
        else 
        {
            [_MissAnimView performAnimation];
            [self bringSubviewToFront:_MissAnimView];
        }
        
        //handle damage    
        [self handleDamage];
    };
    
	//reset firing arcs
	if (_AIsTurn)
	{
		[self setCombatAidVisibilitySelector: NO
							   leftFiringArc: NO
							  rightFiringArc: NO 
                               fortFiringArc: NO
                               ammoChoiceBox: NO];	
		
		if (_AIsTurn)
		{
			//as ai does not need the screen, it may fire upon targets that are not visible
			//this is something annoying to the user, who does not know what damage his ships
			//have or have not suffered. therefore, whenever AI fires, we zoom to the point
			//exactly in the middle of firing ships.
			
			//calculate middle point between firing ship and the target
			CGFloat middle_x = (shooter_center.x + target_center.x) / 2.0;
			CGFloat middle_y = (shooter_center.y + target_center.y) / 2.0;

			//zoom to the point
			[self zoomToX: middle_x
						Y: middle_y ];
		}
		
	}
	else 
    {
        if (!_SelectedShip._IAmFort) //not a fort
            [self setCombatAidVisibilitySelector: YES
                                   leftFiringArc: ! _SelectedShip._FiredLeft
                                  rightFiringArc: ! _SelectedShip._FiredRight
                                   fortFiringArc: NO
                                   ammoChoiceBox: YES];
        else //fort
            [self setCombatAidVisibilitySelector: YES
                                   leftFiringArc: NO
                                  rightFiringArc: NO
                                   fortFiringArc: NO
                                   ammoChoiceBox: YES];
    }   
	
	//prepare damage display type
	if (_AIsTurn) _DDT = DDT_AI_Turn_Firing;
	else _DDT = DDT_Normal;
    
    //launch animations
    [UIView animateWithDuration: fsi._Distance * CANNONBALL_FLIGHT_TIME
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: anim_block
                     completion: comp_block ];
    
    [fsi release];
}

- (void) handleGoButton
{
    //first test if this wouldn't beach the ship
    MoveResult beaching_check = [_HexBoard CanMoveShipAtRow:_SelectedShip._CurrentHex._Row 
                                                     AndHex:_SelectedShip._CurrentHex._HexInRow
                                               ignoreMPCost:NO];
    
    //beaching requires confirmation. AI should never beach, but should it want to, let it - rather than freeze the ui
    if ((beaching_check == MoveBeached || beaching_check == MoveBeachedAndBoarding) && ! _AIsTurn)
    {        
        _CurrentBIAlert = [[BIAlertView alloc] initWithAlertType: AlertTypeShallowWater
                                                         message: @"Shallow water ahead! Shall we beach the ship Admiral?"
                                                        delegate: self
                                                     cancelDelay: 0.0 ];
        
        [_CurrentBIAlert show];
    }
    else [self performMove];
}

- (void) performMove
{
	MoveResult mr = [_HexBoard moveShipAtRow:_SelectedShip._CurrentHex._Row
									HexInRow:_SelectedShip._CurrentHex._HexInRow];
	
	//handle damage from boarding or boarding action update
	if (mr != MoveOk)
	{
		if (_AIsTurn) _DDT = DDT_AI_Turn_Moving;
		else _DDT = DDT_Normal;
		[self handleDamage];
	}

	//maybe a cargo ship just reached the objective?
    if (mr == MoveToVictory) NSLog(@"Hexboard reports game over by entering objective hex!");

	//		ANIMATION PART
	
	//these are the new coordinates, because the ship was already moved in hexboard!
	CGPoint destination = [self calculateCenterForRow: _SelectedShip._CurrentHex._Row 
                                             HexInRow: _SelectedShip._CurrentHex._HexInRow ];
    
    //check AI
    AIPlayer * currentAI = nil;
    if (_AIsTurn)
    {   
        if (_CurrentSide == RedSide) currentAI = _RedPlayerAI;
        else currentAI = _BluePlayerAI;
    }
     
    //create completion block for isv to use after animation finishes
    CompletionBlock_t comp_block = ^(BOOL fin)
    {
        [self handleShipSelected];
        
        if (mr == MoveToVictory) [self checkAndHandleVictory];
        else [currentAI navigationFinished];
    };
    
    //perform animation
    IntegratedShipView * isv = (IntegratedShipView *)[self viewWithTag:SHIPVIEW_TAG_PREFIX + _SelectedShip._ID];
    [isv animateMoveTo:destination completionBlock: comp_block];
    
    //play a sound
    [globalSoundCenter playEffect:SOUND_SHIP_MOVE];
    
	//update the interface
	[_pInterfaceView updateShipDataMP:_SelectedShip._MovePointsLeft
								   TP:_SelectedShip._TurnPointsLeft
                                Turns:[_HexBoard canShipTurn: _SelectedShip] ];
}

- (void) handleTurnButton:(TurnDirection) td
{
    //make the change in the data
	[_HexBoard TurnShipAtRow:_SelectedShip._CurrentHex._Row
					HexInRow:_SelectedShip._CurrentHex._HexInRow 
				 InDirection:td];
    
    //check AI
    AIPlayer * currentAI = nil;
    if (_AIsTurn)
    {   
        if (_CurrentSide == RedSide) currentAI = _RedPlayerAI;
        else currentAI = _BluePlayerAI;
    }
    
    //create completion block for isv to use after animation finishes
    CompletionBlock_t comp_block = ^(BOOL fin)
    {
        [self handleShipSelected];
        
        [currentAI navigationFinished];
    };
    
    //perform animation
    IntegratedShipView * isv = (IntegratedShipView *)[self viewWithTag:SHIPVIEW_TAG_PREFIX + _SelectedShip._ID];
    [isv animateTurn:td completionBlock:comp_block];
    
    //play a sound
    [globalSoundCenter playEffect:SOUND_SHIP_MOVE];
    
	//update the interface
	[_pInterfaceView updateShipDataMP:_SelectedShip._MovePointsLeft
								   TP:_SelectedShip._TurnPointsLeft
                                Turns:[_HexBoard canShipTurn: _SelectedShip] ];

}

- (void) handleTurnLeftButton
{
	NSLog(@"Turning LEFT!\n");
	
    [self handleTurnButton: TurnLeft];
}

- (void) handleTurnRightButton
{
	NSLog(@"Turning RIGHT!\n");
    
    [self handleTurnButton: TurnRight];
}

- (void) handleAnchorButton
{
	NSLog(@"Ship FINISHES TURN!\n");

	[_HexBoard setShipFinishedTo:YES 
							 Row:_SelectedShip._CurrentHex._Row 
						HexInRow:_SelectedShip._CurrentHex._HexInRow];
	
	[self setNavAidVisibilitySelector: NO
								 move: NO
								 turn: NO
							   anchor: NO ];
	_SelectedShip = nil;
	
    [globalSoundCenter playEffect:SOUND_CLICK];
    
	//that may be the last active ship so
	if ([_HexBoard allShipsDoneFor:_CurrentSide])
	{
		NSLog(@"That was the last active ship for this side.\n");
		[_pInterfaceView setTurnEnd:YES];
	}
}

- (void) handleUndoButton
{	
	NSLog(@"Undo running\n");
    	
	Ship * undoed_ship = [_HexBoard undoLastMove];
	
	if (undoed_ship != nil)
	{
        //hide optionsview
        _OptionsViewVisible = NO;
        
        [self setOptionsMenuVisibile: NO
                    byUndoMoveButton: YES 
                         undoingShip: undoed_ship];

	}
}

- (void) performUndo:(Ship *) undoed_ship
{
    NSLog(@"Interface needs to undo!\n");
    
    //get the ship and place it in appropriate place on the hexboard
    CGPoint undo_center = [self calculateCenterForRow: undoed_ship._CurrentHex._Row
                                             HexInRow:undoed_ship._CurrentHex._HexInRow];
    
    IntegratedShipView * isv = (IntegratedShipView *)[self viewWithTag:SHIPVIEW_TAG_PREFIX + undoed_ship._ID];
    [isv setCenter: undo_center];

    [isv undoShipCourseTo:undoed_ship._Course];
    
    //select the undoed ship and zoom to its location
    _SelectedShip = undoed_ship;
    CGPoint cnt = [self calculateCenterForRow:_SelectedShip._CurrentHex._Row
                                     HexInRow:_SelectedShip._CurrentHex._HexInRow];
    [self zoomToX:cnt.x Y:cnt.y];
        
    [self handleShipSelected];
}

- (void) handleDamage
{
	static bool LastAIDMGWasFatal = NO;
    
    //check for battleinterface pausing
    if (_DDT == DDT_BOT_Update && _BattlePaused)
    {
        NSLog(@"Beggining of Turn Damage Updates PAUSED");
        _NeedsDamageUpdateAfterRestart = YES;
        return;
    }
    
    if (_GameOverDetected)
    {
        NSLog(@"HandleDamage called when victory was achieved!");
    }
    
	NSObject * obj = [_HexBoard retrieveLastUIUpdate];
    
	//************* CLEANUP *************
	if (obj == nil)
	{
		NSLog(@"handleDamage: no more updates, continues normal operation");
		
		if (_GameOverDetected)
		{
			NSLog(@"Game Over Detected - no more actions!");
			return;
		}
		
		switch (_DDT)
		{
			case DDT_Normal:
                //reenable the user interfaced disabled for shooting time

                [self setUserInteractionEnabled: YES];
                [_pInterfaceView setUserInteractionEnabled: YES];

				break;
				
			case DDT_BOT_Update:
				//reenable the ui, start the turn
				[self startTurn];
				break;
				
            case DDT_AI_Turn_Moving:
				//nothing special here
				break;
                
			case DDT_AI_Turn_Firing:
				//continue warpath if nothing sunk
				//if something sunk, reset the AI
                
                if (_CurrentSide == RedSide) [_RedPlayerAI shootingFinished: LastAIDMGWasFatal];
                else [_BluePlayerAI shootingFinished: LastAIDMGWasFatal];
                				
				break;
		}
				
		return;
	}	
	
	//************* BOARDING *************
	if ([obj isKindOfClass:[UIBoardingNfo class]])
	{
		NSLog(@"handleDamage: Boarding Update");		
		
		//handle boarding;
		UIBoardingNfo * bai = (UIBoardingNfo *) obj;
		
		[self animateBoarding:bai];
	}
	
	//************* DAMAGE *************
	if ([obj isKindOfClass:[DamadgeInfo class]])
	{
		NSLog(@"handleDamage: Damage Update");		
		//handle damage according to damagedisplaytype
		
		DamadgeInfo * dmg = (DamadgeInfo *) obj;
		UIDmgNfo * uidmg = [[UIDmgNfo alloc] initWithDamadgeInfo: dmg ];
		
        //the brave new way - let ship subview handle the display and animations
        IntegratedShipView * isv = (IntegratedShipView *) [self viewWithTag:SHIPVIEW_TAG_PREFIX + dmg._DamagedShipID];
        [isv animateDamageWithUiDmgNfo: uidmg];
        		
		switch (_DDT)
		{
			case DDT_Normal:
				//nothing special here
				break;
				
			case DDT_BOT_Update:
				//zoom to dmg if not on screen?
				[self zoomToX: isv.center.x
							Y: isv.center.y ];
				break;
				
            case DDT_AI_Turn_Moving:
                //nothing special here
				break;
                
			case DDT_AI_Turn_Firing:
				//store fatality
				LastAIDMGWasFatal = dmg._IsFatal;
				
				//zoom to target
				//may be handled in handleShipToShipFire
				break;
		}
		
        [dmg release];
	}
	
}

//called when something finishes sinking
- (void) checkForVictoryThenHandleDamage
{
    [self checkAndHandleVictory];
    
    //if no victory detected, proceed with handling damage
    if (! _GameOverDetected) [self handleDamage];
}


- (void) checkAndHandleVictory
{
    if (_GameOverDetected)
    {
        NSLog(@"CheckAndHandleVictory called after victory has been detected - averting!");
        return;
    }
	
    VictoryResult vic = [_HexBoard checkForVictory];
    
    if (vic != ResultUndecided)
	{
		NSLog(@"Game Over!");
		
		_GameOverDetected = YES;

        //prevent execution of any outstanding selectors
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
        		
		//zap the autosave
		[AppWideSettings set_AutoSaveAvailable:NO];
		
		//create the stats
		StatisticsContainer * sc = [[StatisticsContainer alloc] initWithHexBoard:_HexBoard];
		        
		//instruct the main menu to destroy this view and start statistics screen
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_SWITCH_TO_STATS object:sc];
	}
}

						/************************************
						 *		 INTERFACE RESPONDERS		*
						 ************************************/

- (void) handleNextShip
{
	NSLog(@"Selecting next ship.\n");
	//Ship * cur_ship = [_HexBoard getShipAtRow:_SelectedShipRow HexInRow:_SelectedShipHexInRow];
	Ship * ship;
	
	//search for ship in hexboard
    if (_SelectedShip == nil || _SelectedShip._Side != _CurrentSide) 
        ship = [_HexBoard GetNextShipFrom:nil ForSide:_CurrentSide];
    else
        ship = [_HexBoard GetNextShipFrom:_SelectedShip ForSide:_CurrentSide];
	
	if (ship == nil)
	{
		NSLog(@"No more ships!\n");
		
		//if all ships for redside are done, we may end turn
		if ([_HexBoard allShipsDoneFor:_CurrentSide]) [_pInterfaceView setTurnEnd:YES];
	}
	else
	{
		_SelectedShip = ship;
		
		[self handleShipSelected];
		
		//cool thing to do: zoom on selected hex!
		CGPoint cnt = [self calculateCenterForRow:_SelectedShip._CurrentHex._Row
										 HexInRow:_SelectedShip._CurrentHex._HexInRow];
		[self zoomToX:cnt.x Y:cnt.y];
	}
}

- (void) handleEndTurn
{
	NSLog(@"Ending turn.\n");

	//no ship selection at the beggining of the turn
	_SelectedShip = nil;
	_inFiringMode = NO;
	
	//hide all ui elements
	[self setNavAidVisibilitySelector: NO
								 move: NO
								 turn: NO
							   anchor: NO ];

	[self setCombatAidVisibilitySelector: NO
						   leftFiringArc: NO
						  rightFiringArc: NO 
                           fortFiringArc: NO
                           ammoChoiceBox: NO];
		
	//instruct the board to process its data
	_CurrentSide = [_HexBoard finishTurn];
	
	//handle damadge and boarding updates with user interactions disabled
	[self setUserInteractionEnabled:NO];
	[_pInterfaceView setUserInteractionEnabled:NO];
	
	_DDT = DDT_BOT_Update;
	[self handleDamage];
		
	//pass the new wind direction to interface
	[_pInterfaceView setWindDirection: [_HexBoard _WindDirection] 
							 animated: YES];
	
	//check if the side has ships that can move
	if (! [_HexBoard allShipsDoneFor:_CurrentSide] ) 
		[_pInterfaceView setTurnEnd: NO];
	
	//redraw if showing the AI
#ifdef AIVALUES_VIEW
    [self setNeedsDisplay];
#endif
    
	//autosaving
	[self saveMap:nil];

	//the turn will start when startTurn is called;
}

- (void) startTurn
{
#ifdef NON_RELEASE
    [_HexBoard testPathFinding];
#endif
    
	//only start turn if both sides have ships!
	if ([_HexBoard._RedSideShips count] == 0 || [_HexBoard._BlueSideShips count] == 0)
	{
		//if there ain't already some checking into if one side won, this will hang the game...
		NSLog(@"WARNING: One side has no ships at start of the turn!");
		
		//as a safeguard, i could run a timer with 5 seconds delay for checkAndHandle victory...
		
		return;
	}
	
	NSString * new_turn_msg;
	AIPlayer * current_AI;
	
 	if (_CurrentSide == RedSide)
	{
		current_AI = _RedPlayerAI;
        if (_HexBoard._MultiPlayer) new_turn_msg = @"English Admiral\'s Turn";
        else new_turn_msg = @"Your turn Admiral";
	}
	else
	{
		current_AI = _BluePlayerAI;		
        if (_HexBoard._MultiPlayer) new_turn_msg = @"Spanish Admiral\'s Turn";
        else new_turn_msg = @"Your turn Admiral";
	}
    
	if (current_AI == nil)
	{
		NSLog(@"Human turn begins...");
		_AIsTurn = NO;
		
		//enable interface
		[self setUserInteractionEnabled:YES];
		[_pInterfaceView setUserInteractionEnabled:YES];
		                
        _CurrentBIAlert = [[BIAlertView alloc] initWithAlertType: AlertTypeTurnBegins
                                                         message: new_turn_msg
                                                        delegate: self
                                                     cancelDelay: UNTIL_CLICKED ];
        
        [_CurrentBIAlert show];
	}
	else
	{
		NSLog(@"AI turn begins...");
		_AIsTurn = YES;
    
        //show alert
        _CurrentBIAlert = [[BIAlertView alloc] initWithAlertType: AlertTypeTurnBegins
                                                         message: @"AI Player\'s Turn"
                                                        delegate: self
                                                     cancelDelay: NOTIFICATION_TIME ];
        
        [_CurrentBIAlert show];

		//disable interface
		[self setUserInteractionEnabled:NO];
		[_pInterfaceView setUserInteractionEnabled:NO];
    }
	
    //interface autohiding
    [_pInterfaceView launchAutoHideTimer];
    
	current_AI = nil;
}

- (void) handleFire
{
	NSLog(@"MapView prepares combat aids...\n");
	//only display something where there is a ship selected!
	if (_SelectedShip == nil) return;

	//if selected ship is engaged in boarding, nothing should happen
    if (_SelectedShip._BoardingsCount > 0) return;
    
	//only display fire archs if selected ship is ours
	if ( _SelectedShip._Side != _CurrentSide) return;
    
    //the ship may have lost all it's cannons
    if (_SelectedShip._Guns <= 0)
    {
        _CurrentBIAlert = [[BIAlertView alloc] initWithAlertType: AlertTypeShootingFail
                                                         message: @"We have no cannons Admiral!"
                                                        delegate: self
                                                     cancelDelay: NOTIFICATION_TIME ];
        
        [_CurrentBIAlert show];
        return;
    }
	
    //flip _inFiringMode an display combat aids accordingly
    if (_inFiringMode)
    {
        _inFiringMode = NO;
        [self setCombatAidVisibilitySelector: YES
                               leftFiringArc: NO
                              rightFiringArc: NO 
                               fortFiringArc: NO
                               ammoChoiceBox: NO ];
        
        [self handleShipSelected];
    }
    else
    {
        //check if we can enter the firing mode
        if ( !_SelectedShip._FiredLeft || ( !_SelectedShip._FiredRight && !_SelectedShip._IAmFort ) )
        {
            _inFiringMode = YES;
            [self setNavAidVisibilitySelector: NO
                                         move: NO
                                         turn: NO
                                       anchor: NO ];
            
            
            if (!_SelectedShip._IAmFort) //not a fort
                [self setCombatAidVisibilitySelector: YES
                                       leftFiringArc: ! _SelectedShip._FiredLeft
                                      rightFiringArc: ! _SelectedShip._FiredRight
                                       fortFiringArc: NO
                                       ammoChoiceBox: YES];
            else //fort
                [self setCombatAidVisibilitySelector: YES
                                       leftFiringArc: NO
                                      rightFiringArc: NO
                                       fortFiringArc: YES
                                       ammoChoiceBox: YES];
        }
        else
        {
            //fired both broadsides
            _CurrentBIAlert = [[BIAlertView alloc] initWithAlertType: AlertTypeShootingFail
                                                             message: @"Already fired all guns Admiral!"
                                                            delegate: self
                                                         cancelDelay: NOTIFICATION_TIME ];
            
            [_CurrentBIAlert show];
            return;

        }
	}
}

- (void) handleOptions		//wind button!
{
	//flip visibility
	_OptionsViewVisible = !_OptionsViewVisible;
	
	//show/hide
	[self setOptionsMenuVisibile: _OptionsViewVisible
                byUndoMoveButton: NO
                     undoingShip: nil];
}

					/************************************
					 *		 WRAPPERS FOR HEXBOARD		*
					 ************************************/

- (void) handleAmmoChangeTo:(AmmunitionType) at
{
    if (_SelectedShip != nil)
    {
        NSLog(@"Ship %@ changes ammo to: %d", _SelectedShip, at);
        [_SelectedShip set_SelectedAmmoType: at];
    }
}

/* used by the interface to get initial wind direction */
- (HexDirection) getWindDirection
{
	return [_HexBoard _WindDirection];
}

/* save current map */
- (void) saveMap:(NSString *) filename
{
#ifdef MAPCREATOR
    //if a map is created by map creator, we can calculate permanent ai hints here to speed up the loading process
    [_HexBoard initAI];
#endif
	
    NSString * actual_filename;
	
	if (filename == nil) actual_filename = translateFilePath(@"autosave.map");
	else actual_filename = translateFilePath(filename);
	
	NSMutableDictionary * rootObject;
	rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue: _HexBoard forKey:@"HexBoard"];
	[rootObject setValue: _BGImageName forKey:@"BGImageName"];
	
	bool success = [NSKeyedArchiver archiveRootObject: rootObject toFile: actual_filename];
	
	if (success)
	{
		NSLog(@"Savegame successfull!");
		[AppWideSettings set_AutoSaveAvailable:YES];

        NSString * single_or_multi;
        if (_HexBoard._MultiPlayer) single_or_multi = @"Two Player";
        else single_or_multi = @"Single Player";
        
        NSString * autosave_info = [NSString stringWithFormat:@"\nScenario: %@\nDifficulty: %@\nCreated: %@\n%@",
                                    _HexBoard._ScenarioName, _HexBoard._ScenarioDifficulty, getCurrentDateAndTime(), single_or_multi ];
        
        [AppWideSettings set_AutoSaveInfoString: autosave_info ];
        
        [_pInterfaceView displayThisTextOnConsole:@"Game Saved"];
	}
	else
	{
		NSLog(@"Savegame FAILED!");
		[AppWideSettings set_AutoSaveAvailable:NO];
	}
}

- (void) forceWindUpdate
{
	[_pInterfaceView setWindDirection: [_HexBoard _WindDirection]
							 animated: NO];
}

#ifdef MAPCREATOR

- (void) setWindDirection:(HexDirection) dir
{
	_HexBoard._WindDirection = dir;
	[self forceWindUpdate];
}

- (void) setSideOfConflict:(SideOfConflict) side
{
	_HexBoard._CurrentSide = side;
}

#endif

//call this to switch from terrain to background rather dynamically (for map chechking)
- (void) switchDrawingMode
{
    NSLog(@"Switching display mode");
    
#ifdef MAPCREATOR
    _DrawingMode = (_DrawingMode + 1) % 2;          //only bg view and terrain view required
#else    
    if (_DrawingMode == drawBG) _DrawingMode = drawTerrainOverBG;      //only bg view and terrain view over bg allowed
    else _DrawingMode = drawBG;
#endif
    [self setNeedsDisplay];
}

                    /*****************************
                     *    ALERT VIEW DELEGATE    *
                     *****************************/

//Alert view appears - play sound
- (void)didPresentAlertView:(UIAlertView *) alertView
{
    NSLog(@"Alert view with tag %d appeared!", alertView.tag);
    
    switch (alertView.tag)
    {
        case AlertTypeTurnBegins:
            
            //play sound
            [globalSoundCenter playEffect:SOUND_TURN_START];
            
            //prepare AI if needed
            if (_AIsTurn)
            {
                if (_CurrentSide == RedSide) [_RedPlayerAI prepareForTurn];
                else [_BluePlayerAI prepareForTurn];
            }
            break;
            
        case AlertTypeShootingFail:
            break;
            
        case AlertTypeShallowWater:
            break;
    }
}

//Alert view disappears
-  (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{    
    NSLog(@"Alert view with tag %d disappeared!", alertView.tag);
    NSLog(@"Button clicked seems to be: %d", buttonIndex);
    
    switch (alertView.tag)
    {
        case AlertTypeTurnBegins:
            NSLog(@"Turn may begin!");
            
            //let the AI play
            if (_AIsTurn)
            {
                if (_CurrentSide == RedSide) [_RedPlayerAI selectNextWarpathWithBoardAnalysis: YES_NUM];
                else [_BluePlayerAI selectNextWarpathWithBoardAnalysis: YES_NUM];
            }
            else
            {
                [self zoomToShip: [_HexBoard GetMostImportantShipForSide:_CurrentSide] ];
            }
            
            break;
            
        case AlertTypeShootingFail:
            NSLog(@"Try another target!");
            break;
            
        case AlertTypeShallowWater:
            NSLog(@"What should we do with shallow water?");
            
            if (buttonIndex == AYETAG)
            {
                //go ahead and beach me!
                NSLog(@"Beaching confirmed!");
                [self performMove];
            }
            else
            {
                NSLog(@"Drop the anchor!");
                //do not want!
            }
            
            break;
    }
    
    [alertView release];
    _CurrentBIAlert = nil;
}

- (void) setGamePause:(BOOL) pause
{
    if (pause)
    {
        NSLog(@"Battle Interface Pausing!!!");
        _BattlePaused = YES;
        
        //pause ai if necessary
        if (_AIsTurn)
        {
            if (_CurrentSide == RedSide) [_RedPlayerAI setPause:YES];
            else [_BluePlayerAI setPause:YES];
        }
    }
    else
    {
        NSLog(@"Battle Interface Resuming!!!");
        _BattlePaused = NO;
        
        if (_NeedsDamageUpdateAfterRestart)
        {
            _NeedsDamageUpdateAfterRestart = NO;
            [self handleDamage];
        }
        
        //unpause ai if necessary
        if (_AIsTurn)
        {
            if (_CurrentSide == RedSide) [_RedPlayerAI setPause:NO];
            else [_BluePlayerAI setPause:NO];
        }
    }
}

- (void) quitGame
{
    NSLog(@"Mamma mia! BattleInterface quitting in midgame!");
    
    //if there is alertview present - dismiss it
    [_CurrentBIAlert dismissWithClickedButtonIndex:0 animated: NO];
    
    //zap timers
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //savegame
    [self saveMap:nil];
    
    //instruct main controller to destroy this and return to main menu
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_POP_AND_DESTROY_ME object:@"BIVC"];
}

- (void) receiveNotification:(NSNotification *) notification
{
	if ([[notification name] isEqualToString: NOTIF_NAME_PAUSE_BI])
    {
        [self setGamePause: YES];
    }

    if ([[notification name] isEqualToString: NOTIF_NAME_UNPAUSE_BI])
    {
        [self setGamePause: NO];
    }

    if ([[notification name] isEqualToString: NOTIF_NAME_QUIT_BI])
    {
        [self quitGame];
    }
}


						/************************
						 *		 CLEANUP		*
						 ************************/

- (void) dealloc {
	NSLog(@"WARNING: MapView is being dealloc'd!");
	    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    //stop watching
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
	[_BGImage release];
	[_BGImageName release];
	
	_pInterfaceView = nil;
	_pEncapsulatingScrollView = nil;
	
    [_pOptionsView release];
    _pOptionsView = nil;
    
	[_BluePlayerAI release];
    _BluePlayerAI = nil;
    
	[_RedPlayerAI release];
    _RedPlayerAI = nil;

    [_HexBoard release];

    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    	    
    [super dealloc];
	NSLog(@"MapView dealloc finishes ok!");
}

@end

NSString * getCurrentDateAndTime()
{
    // get current date/time
    NSDate * today = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString * currentTime = [dateFormatter stringFromDate:today];
    [dateFormatter release];
    
    return currentTime;
}