//
//  StatisticsViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsViewController.h"
#import "StatisticsContainer.h"
#import "StatisticsView.h"

#import "SoundCenter.h"

@implementation StatisticsViewController

@synthesize _statsView, _stats;

- (void) viewWillAppear:(BOOL)animated
{
    //prepare statistics
    [_statsView prepareForAnimationWithStats:_stats];
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    //select music - play for victory if red side won or if anyone won if this was multi
    bool victory = (_stats._winnerIs == RedSide || (_stats._WasMultiplayerGame && _stats._winnerIs != ResultDraw));
    [globalSoundCenter onStatsEnterVictorious: victory];
    
    //start animation
    [_statsView animateView];
    
    [super viewDidAppear:animated];
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    NSLog(@"WARNING: Statitics View Controller is being dealloc'd!");
    
	[_statsView release];
	_statsView = nil;
    
    [_stats release];
    _stats = nil;
    
    [super dealloc];
    
    NSLog(@"Statitics View Controller dealloc ok!");
}


@end
