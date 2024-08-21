//
//  TutorialsAndInstructionsViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialsAndInstructionsViewController.h"
#import "SoundCenter.h"

@implementation TutorialsAndInstructionsViewController

@synthesize _InstructionsRootView;

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
			interfaceOrientation == UIInterfaceOrientationLandscapeRight );
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


- (void)dealloc 
{
    [_InstructionsRootView release];
    _InstructionsRootView = nil;
    
    [super dealloc];
}


@end
