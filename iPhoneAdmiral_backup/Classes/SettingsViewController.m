//
//  SettingsViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import "BattleInterfaceAppDelegate.h"
#import "SettingsViewController.h"
#import "SettingsView.h"
#import "UICommon.h"

#import "SoundCenter.h"

@implementation SettingsViewController

@synthesize _SettingsView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	//set the controls of the view to apropriate states
	[_SettingsView setup];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) viewWillAppear:(BOOL) animated
{
    [globalSoundCenter playEffect:SOUND_SCREEN_CHANGE];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL) animated
{
    if (animated) [globalSoundCenter playEffect:SOUND_SCREEN_CHANGE];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
