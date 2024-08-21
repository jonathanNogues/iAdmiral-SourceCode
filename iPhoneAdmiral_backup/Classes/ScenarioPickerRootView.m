//
//  ScenarioPickerRootView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScenarioPickerRootView.h"
#import "ScenarioPickerPickView.h"
#import "ScenarioDetailsView.h"

#import "ScenarioInfo.h"
#import "Common.h"
#import "SoundCenter.h"

#import "DQReadyControl.h"

@implementation ScenarioPickerRootView

@synthesize _ScenarioScroller;
@synthesize _ScenariosView;
@synthesize _ChosenScenarioView;
@synthesize _LoadingScreen;

@synthesize _SingleOrMultiControl;
@synthesize _AvailableScenariosControl;
@synthesize _BackControl;

@synthesize _Scenarios;

- (void) awakeFromNib
{
	[self setImage:[UIImage imageNamed:@"ScenarioPickerBG.png"]];
	
	[_ScenarioScroller setBackgroundColor:[UIColor clearColor]];
	[_ScenarioScroller setCanCancelContentTouches:YES];
	_ScenarioScroller.clipsToBounds = YES;
	_ScenarioScroller.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    [_ScenarioScroller setShowsHorizontalScrollIndicator:NO];
    
    _MultiplayerEnabled = NO;

    [_SingleOrMultiControl set_TextSize:        35.0];
    [_SingleOrMultiControl set_TextIndent:      1];
    [_SingleOrMultiControl set_Text:            @"Singleplayer"];
    [_SingleOrMultiControl setActionTarget:     self
                                  selector:     @selector(handlePlayerButton:)];
    
    [_AvailableScenariosControl set_TextSize:   75.0];
    [_AvailableScenariosControl set_Text:       @"available scenarios"];

    [_BackControl set_TextSize:                 70.0];
    [_BackControl set_Text:                     @"back"];
    [_BackControl setActionTarget:              self
                         selector:              @selector(handleBackToMM:)];
}

//sets up the small view with scenariobuttons
- (void) showScenarios
{
	NSLog(@"SPRV: preparing scenarios!");
	
	//create scenario picker view
	_ScenariosView = [[ScenarioPickerPickView alloc] initWithScenarioArray:_Scenarios];
	[_ScenariosView set_pParent:self];
	
	//add it to the scroller
	[_ScenarioScroller addSubview:_ScenariosView];
	
	//setup scroller size
	CGSize scrollsize = _ScenariosView.frame.size;
	[_ScenarioScroller setContentSize:scrollsize];
}

- (void) destroyScenarios
{
	NSLog(@"SPRV: removing scenarios!");

	[_ScenariosView removeFromSuperview];
	[_ScenariosView release];
	_ScenariosView = nil;
}


- (void) handleSelectedScenarioWithNumber:(int) num
{
	//set scenario details
	ScenarioInfo * scnf = [_Scenarios objectAtIndex: num];
	
	//set map miniature
	[_ChosenScenarioView._ScenarioMapMiniature setImage:[UIImage imageNamed:scnf._MiniatureImageName]];
	
	//set description
	_ChosenScenarioView._ScenarioDescriptionView.text = scnf._ScenarioDescription;
    
    //set scenario name
    _ChosenScenarioView._ScenarioNameLabel.text = scnf._ScenarioName;
	
    //set initial difficulty to medium for normal scenarios
    if (num > 0) [_ChosenScenarioView resetDifficulty];
    else [_ChosenScenarioView hideDifficulty];      //and hide it for autosave button
    
    //set scenario name string
    [_ChosenScenarioView set_ScenarioMapFileName: scnf._MapFileName];
	
    //set multi enabled or not
    [_ChosenScenarioView set_MultiplayerEnabled: _MultiplayerEnabled];
    
	[self addSubview: _ChosenScenarioView];
}

/* hide scenario detail view */
- (void) hideScenarioDetails:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];
    
    [_ChosenScenarioView removeLoadingScreen];
	[_ChosenScenarioView removeFromSuperview];
}

- (IBAction) handlePlayerButton:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];
        
    _MultiplayerEnabled = ! _MultiplayerEnabled;
    
    if (_MultiplayerEnabled)
    {
        [_SingleOrMultiControl set_Text:@"Multiplayer"];
    }
    else
    {
        [_SingleOrMultiControl set_Text:@"Singleplayer"];
    }
}

- (IBAction) handleBackToMM:(id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_POP_ME_ANIMATED object:nil ];
}

- (void)dealloc {
    [super dealloc];
	
	[_ScenarioScroller release];
	[_ScenariosView release];
	[_ChosenScenarioView release];
    
    [_SingleOrMultiControl release];
    [_AvailableScenariosControl release];
    [_BackControl release];
    
	[_Scenarios release];
}

@end
