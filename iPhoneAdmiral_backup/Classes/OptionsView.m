//
//  OptionsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OptionsView.h"
#import "Common.h"
#import "MapView.h"

#import "SoundCenter.h"

@implementation OptionsView

@synthesize _pMapView;

#define UNDO_X	50
#define UNDO_Y	150

#define FET_X	70
#define FET_Y	90

#define SAVE_X	220
#define SAVE_Y	90

#define EXIT_X	250
#define EXIT_Y	150

#define TERR_X  150
#define TERR_Y  55


- (id) initWithImage:(UIImage *) image
{
	[super initWithImage:image];
	
	[self setUserInteractionEnabled:YES];
	
	/************************ UNDO BUTTON ************************/

	_UndoButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	
	//set background image
	UIImage * close_image = [UIImage imageNamed:@"UndoButton.png"];
	[_UndoButton setFrame:CGRectMake(0, 0, close_image.size.width, close_image.size.height)];
	[_UndoButton setBackgroundImage:close_image forState:UIControlStateNormal & UIControlStateSelected];
	
	//set action
	[_UndoButton setEnabled:YES];
	[_UndoButton addTarget:self
					 action:@selector(handleUndoButton)
		   forControlEvents:UIControlEventTouchUpInside];
	
	//add to view and set position
	CGPoint center = CGPointMake(UNDO_X, UNDO_Y);
	[_UndoButton setCenter:center];
	[self addSubview:_UndoButton];

	/******************** FORCE END TURN BUTTON ********************/
	
	_ForceEndTurn = [RoundButton buttonWithType:UIButtonTypeCustom];
	
	//set background image
	//UIImage *
	close_image = [UIImage imageNamed:@"EndTurn.png"];
	[_ForceEndTurn setFrame:CGRectMake(0, 0, close_image.size.width, close_image.size.height)];
	[_ForceEndTurn setBackgroundImage:close_image forState:UIControlStateNormal & UIControlStateSelected];
	
	//set action
	[_ForceEndTurn setEnabled:YES];
	[_ForceEndTurn addTarget:self
					action:@selector(handleForceEndTurn)
		  forControlEvents:UIControlEventTouchUpInside];
	
	//add to view and set position
	//CGPoint 
	center = CGPointMake(FET_X, FET_Y);
	[_ForceEndTurn setCenter:center];
	[self addSubview:_ForceEndTurn];

	/************************ SAVE BUTTON ************************/
	
	_SaveButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	
	//set background image
	//UIImage *
	close_image = [UIImage imageNamed:@"SaveButton.png"];
	[_SaveButton setFrame:CGRectMake(0, 0, close_image.size.width, close_image.size.height)];
	[_SaveButton setBackgroundImage:close_image forState:UIControlStateNormal & UIControlStateSelected];
	
	//set action
	[_SaveButton setEnabled:YES];
	[_SaveButton addTarget:self
					  action:@selector(handleSaveButton)
			forControlEvents:UIControlEventTouchUpInside];
	
	//add to view and set position
	//CGPoint 
	center = CGPointMake(SAVE_X, SAVE_Y);
	[_SaveButton setCenter:center];
	[self addSubview:_SaveButton];

	/************************ EXIT BUTTON ************************/
	
	_ExitButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	
	//set background image
	//UIImage *
	close_image = [UIImage imageNamed:@"ExitToMain.png"];
	[_ExitButton setFrame:CGRectMake(0, 0, close_image.size.width, close_image.size.height)];
	[_ExitButton setBackgroundImage:close_image forState:UIControlStateNormal & UIControlStateSelected];
	
	//set action
	[_ExitButton setEnabled:YES];
	[_ExitButton addTarget:self
					action:@selector(handleExitButton)
		  forControlEvents:UIControlEventTouchUpInside];
		
	//add to view and set position
	//CGPoint 
	center = CGPointMake(EXIT_X, EXIT_Y);
	[_ExitButton setCenter:center];
	[self addSubview:_ExitButton];
	
 	/************************ TERRAINVIEW BUTTON ************************/
   
    _TerrainViewButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	
	//set background image
	close_image = [UIImage imageNamed:@"TerrainViewButton.png"];
	[_TerrainViewButton setFrame:CGRectMake(0, 0, close_image.size.width, close_image.size.height)];
	[_TerrainViewButton setBackgroundImage:close_image forState:UIControlStateNormal & UIControlStateSelected];
	
	//set action
	[_TerrainViewButton setEnabled:YES];
	[_TerrainViewButton addTarget:self
					action:@selector(handleTerrainViewButton)
		  forControlEvents:UIControlEventTouchUpInside];
    
	//add to view and set position
	//CGPoint 
	center = CGPointMake(TERR_X, TERR_Y);
	[_TerrainViewButton setCenter:center];
	[self addSubview:_TerrainViewButton];
    
	return self;
}	

- (void) handleUndoButton
{
	NSLog(@"OptionsView: UNDO function!");
    
    [globalSoundCenter playEffect:SOUND_CLICK];

	[_pMapView handleUndoButton];
}

- (void) handleForceEndTurn
{
	NSLog(@"OptionsView: FORCE END TURN function!");
    
    [globalSoundCenter playEffect:SOUND_CLICK];

	//hide the menu
	[_pMapView handleOptions];

	//force end turn when animation finishes
	[NSTimer scheduledTimerWithTimeInterval: 0.5
									 target: _pMapView
								   selector: @selector(handleEndTurn)
								   userInfo: nil
									repeats: NO ];
}

- (void) handleSaveButton
{
	NSLog(@"OptionsView: SAVE function!");
    
    [globalSoundCenter playEffect:SOUND_CLICK];
	
#ifdef MAPCREATOR
	[_pMapView saveMap:@"MAPCREATOR.map"];
#else
	[_pMapView saveMap:nil];	//autosave.map
#endif
}

- (void) handleExitButton
{
	NSLog(@"OptionsView: EXIT function!");

    [globalSoundCenter playEffect:SOUND_CLICK];

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_POP_ME_ANIMATED object:self];
}

- (void) handleTerrainViewButton
{
    NSLog(@"OptionsView: TerrainView function!");

    [globalSoundCenter playEffect:SOUND_CLICK];

    [_pMapView switchDrawingMode];
}


- (void)dealloc {
	NSLog(@"WARNING: OptionsView is being dealloc'd!");
	_pMapView = nil;

	[_UndoButton removeFromSuperview];
	_UndoButton = nil;
	
	[_ForceEndTurn removeFromSuperview];
	_ForceEndTurn = nil;
	
	[_SaveButton removeFromSuperview];
	_SaveButton = nil;
	
	[_ExitButton removeFromSuperview];
	_ExitButton = nil;
	
    [_TerrainViewButton removeFromSuperview];
    _TerrainViewButton = nil;
	
    [super dealloc];
	NSLog(@"OptionsView dealloc finishes ok!");
}


@end
