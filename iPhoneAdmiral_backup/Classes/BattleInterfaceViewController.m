//
//  BattleInterfaceViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BattleInterfaceViewController.h"
#import "RootView.h"
#import "SoundCenter.h"
#import "InterfaceView.h"
#import "SettingsContainer.h"

@implementation BattleInterfaceViewController

@synthesize _rootView;
@synthesize _ChosenScenario;

- (void) viewDidAppear:(BOOL)animated
{
    [globalSoundCenter onBattleInterfaceEnter];
    
    //interface autohiding
    if (!AppWideSettings._InterfaceAutoHiding) [_rootView._interfaceview set_isHidden: NO];
    
    [super viewDidAppear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	NSLog(@"BIVC: viewDidLoad");

	if (_rootView == nil) NSLog(@"Mamma Mia, we're gonna die!");
	
	//[_rootView performSetupWithFile: _mapFileName];
	[_rootView performSetupWithScenarioChoice: _ChosenScenario];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	NSLog(@"BIVC viewDidUnload!");
}

- (void)dealloc {	
	NSLog(@"WARNING: Battle Interface View Controller is being dealloc'd");
	
	//this shouldn't be necessary, but otherwise the rootview refuses to go...
	[_rootView release];
	_rootView = nil;
		
	[super dealloc];
}

@end
