//
//  RootView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootView.h"
#import "HexBoard.h"
#import "Ship.h"
#import "Common.h"
#import "InterfaceView.h"
#import "OptionsView.h"
#import "MapView.h"

#import "ScenarioChoice.h"
#import "VictoryConditions.h"

#ifdef MAPCREATOR

#import "MapCreator.h"

#endif

static BOOL first_run = YES;

#define ZOOM_VIEW_TAG 100

//this MUST MATCH those in MapView.m
#define OPTIONS_VIEW_TAG		1500
#define NOTIFICATION_TAG		1600
#define MAX_ZOOM_IN_SCALE		2.0
//end of those that MUST MATCH

@implementation RootView

@synthesize _scrollview, _mapview, _interfaceview;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	NSLog(@"ROOTVIEW: DrawRect Running");
	
	if (first_run){
		[_interfaceview setWindDirection: [_mapview getWindDirection] 
								animated: NO];
	
		[_mapview handleDamage];
		
		[_mapview startTurn];
		
		first_run = NO;
	}
}

- (void) performSetupWithScenarioChoice:(ScenarioChoice *) schoice
{
	first_run = YES;
	
	//init scrollview
	[_scrollview setBackgroundColor:[UIColor blackColor]];
	[_scrollview setCanCancelContentTouches:YES];
	_scrollview.clipsToBounds = YES;
	_scrollview.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
	//i have absolutely no idea why, but the scrollview starts with three subviews that do nothing
	//but cause weird things to appear on the screen when zooming. So i remove them here.
	int i = 0;
	for (UIView * sss in [_scrollview subviews])
	{
		NSLog(@"Removing mysterious subview: %i", i++);
		[sss removeFromSuperview];
	}
	
	//NSLog(@"Reading scenario file: %@", mapfilename);

// if we are in map editor we do not want to create new map...
#ifdef MAPEDITOR
 #undef MAPCREATOR
#endif
    
#ifdef MAPCREATOR	

	//SET YOUR OWN VALUES HERE
	HexBoard * hb = [[HexBoard alloc] initWithHexesPerRow: 25
												 RowCount: 19];
	
	//AND HERE
	NSString * map_image_name = @"resistance_map_bg.png";
	
    //NAME FOR AUTOSAVE
    hb._ScenarioName = @"Merchant Resistance";
    
    //Difficulty String
    hb._ScenarioDifficulty = @"Medium";
    
    hb._MultiPlayer = NO;
    
    //scenario victory conditions
    VictoryConditions * vc = [[VictoryConditions alloc] initWithRedCargo: NO
                                                              RedTargets: NO
                                                               BlueCargo: NO
                                                             BlueTargets: NO ];
    
    [hb set_VictoryConditions: vc];
    
#else
	
	//******************** CODING DECODING ********************

	NSDictionary * rootObject;
    
    if (schoice._AutoSave)
    {
        NSLog(@"Reading autosave.");
        rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile: translateFilePath(schoice._MapFileName)];
    }
    else
    {
        NSLog(@"Reading %@(.map) from resources.", schoice._MapFileName);
        rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource: schoice._MapFileName
                                                                                                 ofType: @"map"] ];
    }
    
	HexBoard * hb = [[rootObject valueForKey:@"HexBoard"] retain];
	NSString * map_image_name = [[rootObject valueForKey:@"BGImageName"] retain];

    if (schoice._Multiplayer) 
    {
        NSLog(@"Enabling multiplayer!");
        [hb set_MultiPlayer:YES];
    }
    
	//******************** CODING DECODING ********************
	
	NSLog(@"read image file name as: %@", map_image_name);

#endif

//... but we want to edit the existing one so we need all the functions
#ifdef MAPEDITOR
 #define MAPCREATOR 1
#endif

    
	_mapview = [[MapView alloc] initWithHexBoard: hb
								 BGImageFileName: map_image_name ];	


	///add tag for zooming
	[_mapview setTag:ZOOM_VIEW_TAG];
	
	//add pointers, this is not very good pracitce, but there seems to be no choice
	[_mapview set_pEncapsulatingScrollView: _scrollview];
	[_mapview set_pInterfaceView: _interfaceview];
	
	[_scrollview setZoomScale:1.0];
	[_scrollview setMinimumZoomScale:[_mapview _zoomScale]];
	[_scrollview setMaximumZoomScale:MAX_ZOOM_IN_SCALE];
    [_scrollview setBouncesZoom:NO];
	
	[_scrollview addSubview:_mapview];
	[_scrollview setContentSize:CGSizeMake(_mapview.frame.size.width, _mapview.frame.size.height)];
	
	//optionsview
	_pOptionsView = [[OptionsView alloc] initWithImage:[UIImage imageNamed:@"SteeringWheel.png"]];
	[_pOptionsView setUserInteractionEnabled:NO];
	[_pOptionsView setAlpha:0.0];
	[_pOptionsView setTag:OPTIONS_VIEW_TAG];
	[_pOptionsView set_pMapView: _mapview];
    
    [_mapview set_pOptionsView: _pOptionsView];
    [self addSubview:_pOptionsView];
    
    //make sure the options are _under_ the interface but -above- the scroll
    [self bringSubviewToFront: _interfaceview];
    [self bringSubviewToFront: _interfaceview._WindButton];
	
	//init menuview
	//give it the pointer to map
	[_interfaceview set_PointerToMap: _mapview];
	[_interfaceview resetWindButton];
	[_interfaceview resetOtherButtons];
	[_interfaceview setTurnEnd:NO];
	
#ifdef MAPCREATOR
	
	NSLog(@"* * * MAP CREATOR LAUNCHED * * *");
	MapCreator * mc = [[MapCreator alloc] initWithDefaultFrame];
	[_mapview set_pMapCreator:mc];
	[mc set_pMapView:_mapview];
	[self setUserInteractionEnabled:YES];
	[self addSubview:mc];
	[self bringSubviewToFront:mc];
	
#endif
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [_scrollview viewWithTag:ZOOM_VIEW_TAG];
}

- (void)dealloc {
	NSLog(@"WARNING: RootView is being dealloc'd!");
	
	[_scrollview release];
	[_interfaceview release];
	[_mapview release];
	[_pOptionsView release];
	
	[_pOptionsView set_pMapView: nil];
	
	//[_mapview clearPointers];
	
	[_mapview set_pEncapsulatingScrollView: nil];
	[_mapview set_pInterfaceView: nil];	
	
	[_interfaceview set_PointerToMap: nil];
	
	_scrollview = nil;
	_interfaceview = nil;
	_mapview = nil;
	
	[super dealloc];
	NSLog(@"RootView dealloc finishes ok!");
}


@end
