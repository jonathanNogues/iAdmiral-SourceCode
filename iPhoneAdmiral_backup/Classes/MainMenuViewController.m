//
//  MainMenuViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "BattleInterfaceViewController.h"
#import "InstructionsViewController.h"
#import "TutorialsAndInstructionsViewController.h"
#import "SettingsViewController.h"
#import "ScenarioPickerViewController.h"
#import "StatisticsViewController.h"
#import "CreditsViewController.h"

#import "MainMenuView.h"
#import "Common.h"

#import "ScenarioChoice.h"

#import "SettingsContainer.h"
#import "SoundCenter.h"

@implementation MainMenuViewController

@synthesize _MainMenu, _SettingsController, _TutorialsAndInstructionsController, _InstructionsController, 
			_ScenarioPickerController, _CreditsViewController;

- (void) switchToBI:(id)sender
{
	NSLog(@"MMVC: Switch to Battle Interface!");

	if (_BattleInterfaceController == nil)
	{
		NSLog(@"Battle Interface not loaded, launching autosave.");
        
        ScenarioChoice * sc = [[ScenarioChoice alloc] init];
        sc._MapFileName = @"autosave.map";
        sc._AutoSave = YES;
        
        CompletionBlock_t comp_block = 
        ^(BOOL fin) {
            _BattleInterfaceController = [[BattleInterfaceViewController alloc] init];
            [_BattleInterfaceController set_ChosenScenario: sc];

            [((UINavigationController *)[self parentViewController]) pushViewController:_BattleInterfaceController 
                                                                               animated:YES];
        };
        
        [_MainMenu animateLoadingScreen:comp_block];
	}
    else
    {
        [((UINavigationController *)[self parentViewController]) pushViewController:_BattleInterfaceController 
                                                                           animated:YES];
    }
}

- (void) switchToInstructions:(id)sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];
    
	NSLog(@"MMVC: Switch to Instructions!");
	
	[((UINavigationController *)[self parentViewController]) pushViewController:_TutorialsAndInstructionsController 
																	   animated:YES];
}

- (void) switchToSettings:(id)sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];

	NSLog(@"MMVC: Switch to Settings!");
    	
	[((UINavigationController *)[self parentViewController]) pushViewController:_SettingsController 
																	   animated:YES];
}

- (void) switchToScenarioPicker:(id)sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];

	NSLog(@"MMVC: Switch to Scenario Picker!");
    
	[((UINavigationController *)[self parentViewController]) pushViewController:_ScenarioPickerController 
																	   animated:YES];		
}

- (void) switchToCredits:(id)sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];

	NSLog(@"MMVC: Switch to Credits!");
    
	[((UINavigationController *)[self parentViewController]) pushViewController:_CreditsViewController 
																	   animated:YES];		
}


- (void) switchToStatisticsWithStats:(StatisticsContainer *) stats
{
	NSLog(@"Switch to Statistics View running!");
	
	[((UINavigationController *)[self parentViewController]) popViewControllerAnimated:NO];
	
	[_StatisticsController set_stats:stats];
	
	[((UINavigationController *)[self parentViewController]) pushViewController:_StatisticsController 
																	   animated:YES];	
}

- (void) receiveNotification:(NSNotification *) notification
{

	if ([[notification name] isEqualToString: NOTIF_NAME_POP_AND_DESTROY_ME])
	{
		[((UINavigationController *)[self parentViewController]) popViewControllerAnimated:NO];

        NSString * sender_name = [notification object];
        
        if ([sender_name isEqualToString:@"BIVC"])
		//if ([[notification object] isKindOfClass: [BattleInterfaceViewController class]])
		{
			[_BattleInterfaceController release];
			_BattleInterfaceController = nil;
		}

        if ([sender_name isEqualToString:@"SVC"])
		//if ([[notification object] isKindOfClass: [StatisticsViewController class]])
		{
			[_StatisticsController release];
			_StatisticsController = nil;
		}
	}	//NOTIF_NAME_POP_AND_DESTROY_ME
	
	
	if ([[notification name] isEqualToString:NOTIF_NAME_POP_ME])
	{
        NSLog (@"Received the PopCurrentViewController notification!");
		[((UINavigationController *)[self parentViewController]) popViewControllerAnimated:NO];
	}	//NOTIF_NAME_POP_ME
	
	
	if ([[notification name] isEqualToString:NOTIF_NAME_POP_ME_ANIMATED])
	{
        NSLog (@"Received the PopCurrentViewControllerAnimated notification!");
        
		[((UINavigationController *)[self parentViewController]) popViewControllerAnimated:YES];
	}	//NOTIF_NAME_POP_ME_ANIMATED
	
	
	if ([[notification name] isEqualToString:NOTIF_NAME_SWITCH_TO_STATS])
	{
		NSLog (@"Received the SwitchFromBItoStats notification!");
		
		[((UINavigationController *)[self parentViewController]) popViewControllerAnimated:NO];
		
		[_BattleInterfaceController release];
		_BattleInterfaceController = nil;
		
		if (_StatisticsController == nil) _StatisticsController = [[StatisticsViewController alloc] init];
		
		[_StatisticsController set_stats:[notification object]];
		        
		[((UINavigationController *)[self parentViewController]) pushViewController:_StatisticsController 
																		   animated:YES];	
	}	//NOTIF_NAME_SWITCH_TO_STATS
    
    if ([[notification name] isEqualToString:NOTIF_NAME_SWITCH_TO_BI])
	{
        [((UINavigationController *)[self parentViewController]) popViewControllerAnimated:NO];
        
        [_BattleInterfaceController release];
        _BattleInterfaceController = nil;
        
        ScenarioChoice * schoice = [notification object];
        
        NSLog(@"Switch to BI notification, recieved mapfile: %@", schoice._MapFileName);
        if (schoice._Multiplayer) NSLog(@"and multiplayer");
        else NSLog(@"and singleplayer");
        
        if (_BattleInterfaceController == nil)
        {
            NSLog(@"BIVC is NIL");
            _BattleInterfaceController = [[BattleInterfaceViewController alloc] init];
            [_BattleInterfaceController set_ChosenScenario: schoice];
        }		
        
        [((UINavigationController *)[self parentViewController]) pushViewController:_BattleInterfaceController 
                                                                           animated:YES];
	}	//NOTIF_NAME_SWITCH_TO_BI

    if ([[notification name] isEqualToString: NOTIF_NAME_SHOW_ADMIRALOPEDIA])
	{
        NSLog(@"Pushing info slides over the new TutorialView");
        
        [((UINavigationController *)[self parentViewController]) pushViewController:_InstructionsController 
                                                                           animated:YES];

    }//NOTIF_NAME_SHOW_ADMIRALOPEDIA
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) viewDidLoad
{
	//add observers for notifications of interest
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_SWITCH_TO_STATS
                                               object:nil];	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_POP_ME
                                               object:nil];	

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_POP_ME_ANIMATED
                                               object:nil];	

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_POP_AND_DESTROY_ME
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_SWITCH_TO_BI
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:) 
                                                 name:NOTIF_NAME_SHOW_ADMIRALOPEDIA
                                               object:nil];
    
    //prepare DQRS'
    [_MainMenu setup];
}

- (void) viewWillAppear:(BOOL) animated
{
	if (_BattleInterfaceController == nil && !AppWideSettings._AutoSaveAvailable)
	{
		NSLog(@"MMC: Disabling BI button!");
		[_MainMenu._ContinueBattleControl setAlpha: 0.0];
	}
	else
	{
		NSLog(@"MMC: Enabling BI button!");
		[_MainMenu._ContinueBattleControl setAlpha: 1.0];
	}
	
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [globalSoundCenter onMenuEnter];
    
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_MainMenu dropLoadingScreen];
    
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_MainMenu release];
	
	[super dealloc];
}

@end
