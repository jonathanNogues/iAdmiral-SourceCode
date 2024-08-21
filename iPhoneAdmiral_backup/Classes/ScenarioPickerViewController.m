//
//  ScenarioPickerViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScenarioPickerViewController.h"
#import "ScenarioInfo.h"
#import "ScenarioPickerRootView.h"

#import "Common.h"

#import "SoundCenter.h"

#define EXISTING_SCENARIOS_NUM 13

//uncomment next line to save scenario list to disk
//#define CREATE_SCENARIOS_LIST 1

@implementation ScenarioPickerViewController

@synthesize _SPRootView;

- (void) loadAvailableScenarios
{
#ifdef CREATE_SCENARIOS_LIST
	
	_AvailableScenarios = [[NSMutableArray alloc] initWithCapacity:EXISTING_SCENARIOS_NUM];
	
	ScenarioInfo * scnfo0 = [[ScenarioInfo alloc] init];
	scnfo0._ScenarioName = @"Last Save";
	scnfo0._MapFileName = @"autosave.map";
	scnfo0._MiniatureImageName = @"autosave_mini.png";
	scnfo0._ScenarioDescription = @"Last Save";
	[_AvailableScenarios addObject:scnfo0];
	
	ScenarioInfo * encounter = [[ScenarioInfo alloc] init];
	encounter._ScenarioName = @"First Encounter";
	encounter._MapFileName = @"1stencounter";
	encounter._MiniatureImageName = @"1stencounter_mini.png";
	encounter._ScenarioDescription = @"We have been informed that few Spanish trading vessels have stopped near the Isle of Hermosa, probably to replenish supplies. Gather what ships we have and engage them.";
	[_AvailableScenarios addObject:encounter];

	ScenarioInfo * DeadlySurprise = [[ScenarioInfo alloc] init];
	DeadlySurprise._ScenarioName = @"Deadly Surprise";
	DeadlySurprise._MapFileName = @"deadly_surprise";
	DeadlySurprise._MiniatureImageName = @"deadly_surprise_mini.png";
	DeadlySurprise._ScenarioDescription = @"\nA Spanish Galleon escorted by a War Brig is passing nearby. Assume command of the frigate \'Surprise\' and capture or sink it.";
	[_AvailableScenarios addObject:DeadlySurprise];

	ScenarioInfo * EasierWay = [[ScenarioInfo alloc] init];
	EasierWay._ScenarioName = @"An Easier Way";
	EasierWay._MapFileName = @"easier_way";
	EasierWay._MiniatureImageName = @"easier_way_mini.png";
	EasierWay._ScenarioDescription = @"Spies report that several Spanish Galleons loaded with troops are heading for Guadelupe. Destroying them at sea would be much easier than defeating them on land. Make sure none escape.";
	[_AvailableScenarios addObject:EasierWay];

	ScenarioInfo * BreakingBlockade = [[ScenarioInfo alloc] init];
	BreakingBlockade._ScenarioName = @"Breaking the Blockade";
	BreakingBlockade._MapFileName = @"blockade";
	BreakingBlockade._MiniatureImageName = @"blockade_mini.png";
	BreakingBlockade._ScenarioDescription = @"A Spanish squadron led by the mighty War Galleon \'Monarca\' has blockaded the Straits of Aruba. Escort Galleon \'Beagle\' through the Straits to show them that this is unacceptable!";
	[_AvailableScenarios addObject:BreakingBlockade];

	ScenarioInfo * Rescue = [[ScenarioInfo alloc] init];
	Rescue._ScenarioName = @"To the Rescue";
	Rescue._MapFileName = @"rescue";
	Rescue._MiniatureImageName = @"rescue_mini.png";
	Rescue._ScenarioDescription = @"Galleon \'Capricorn\' has run aground during a storm while heading to the Old World laden with gold. Enemy fleet is moving to capture or destroy it. Defend \'Capricorn\' at all cost!";
	[_AvailableScenarios addObject:Rescue];

    ScenarioInfo * PrizeShip = [[ScenarioInfo alloc] init];
	PrizeShip._ScenarioName = @"Prize Ship";
	PrizeShip._MapFileName = @"prize_ship";
	PrizeShip._MiniatureImageName = @"prize_ship_mini.png";
	PrizeShip._ScenarioDescription = @"A War Galleon taken as a prize is sailing for Pt. Moresby. The Spaniards tried to take it back, but a storm scattered both fleets. As the storm clears, the Spanish prepare another attack.";
	[_AvailableScenarios addObject:PrizeShip];

    ScenarioInfo * TwoFronts = [[ScenarioInfo alloc] init];
	TwoFronts._ScenarioName = @"Two Fronts";
	TwoFronts._MapFileName = @"two_fronts";
	TwoFronts._MiniatureImageName = @"two_fronts_mini.png";
	TwoFronts._ScenarioDescription = @"Spanish cargo fleet awaits rendezvouz with a military squadron in the Bight of Segura. Can you destroy it before the squadron arrives? Or will you have to fight on two fronts?";
	[_AvailableScenarios addObject:TwoFronts];
    
    ScenarioInfo * Visit = [[ScenarioInfo alloc] init];
	Visit._ScenarioName = @"Unfriendly Visit";
	Visit._MapFileName = @"unfriendly_visit";
	Visit._MiniatureImageName = @"unfriendly_visit_mini.png";
	Visit._ScenarioDescription = @"Our fleet is assembling near the Cooley Peninsula for a major action against the Spanish. Fearing it's might, the Spaniards decided to attack it while it was still mustering.";
	[_AvailableScenarios addObject:Visit];
    
    ScenarioInfo * PitchedBattle = [[ScenarioInfo alloc] init];
	PitchedBattle._ScenarioName = @"Pitched Battle";
	PitchedBattle._MapFileName = @"pitched";
	PitchedBattle._MiniatureImageName = @"pitched_mini.png";
	PitchedBattle._ScenarioDescription = @"Huge battle in the Straits of Aruba. Enemy has more ships, but you have the magnificent \'Neptune\' and winds are in your favor. Will this be enough for a victory?";
	[_AvailableScenarios addObject:PitchedBattle];

	ScenarioInfo * Breakout = [[ScenarioInfo alloc] init];
	Breakout._ScenarioName = @"Flight of Achilles";
	Breakout._MapFileName = @"breakout";
	Breakout._MiniatureImageName = @"breakout_mini.png";
	Breakout._ScenarioDescription = @"It's a trap! The Spanish have us surrounded with a much stronger fleet. The King's nephew is aboard the \'Achilles\'. Get him to safety at all cost! All other ships are expendable.";
	[_AvailableScenarios addObject:Breakout];

//new in version 1.1
    
	ScenarioInfo * Relief = [[ScenarioInfo alloc] init];
	Relief._ScenarioName = @"Relief Convoy";
	Relief._MapFileName = @"relief_convoy";
	Relief._MiniatureImageName = @"relief_convoy_mini.png";
	Relief._ScenarioDescription = @"Our colony of Eleuthera has been harassed by the Spaniards. Break through to the city with a galleon laden with military supplies to aid in its defense.";
	[_AvailableScenarios addObject:Relief];

	ScenarioInfo * Barbuda = [[ScenarioInfo alloc] init];
	Barbuda._ScenarioName = @"Assault on Barbuda";
	Barbuda._MapFileName = @"barbuda";
	Barbuda._MiniatureImageName = @"barbuda_mini.png";
	Barbuda._ScenarioDescription = @"The King wishes us to take the Spanish fortress-city of Barbuda. An invasion is planned later this year, your immediate task is to destroy Barbuda's fortifications.";
	[_AvailableScenarios addObject:Barbuda];

    ScenarioInfo * CoastalRaid = [[ScenarioInfo alloc] init];
	CoastalRaid._ScenarioName = @"Raiding Spanish Main";
	CoastalRaid._MapFileName = @"spanish_main";
	CoastalRaid._MiniatureImageName = @"spanish_main_mini.png";
	CoastalRaid._ScenarioDescription = @"Admiral, conduct a raid on Spanish Main near the city of Caracas. Bombardment of cities and destroying fortifications is a priority, but disrupt enemy shipping if you can.";
	[_AvailableScenarios addObject:CoastalRaid];

//new in version 1.3    
    
    ScenarioInfo * MerchantResistance = [[ScenarioInfo alloc] init];
	MerchantResistance._ScenarioName = @"Merchant Resistance";
	MerchantResistance._MapFileName = @"resistance";
	MerchantResistance._MiniatureImageName = @"resistance_mini.png";
	MerchantResistance._ScenarioDescription = @"A Spanish privateer squadron has been terrorizing nearby towns and is now heading here. You are tasked with organizing a defense using any ships available in the region.";
	[_AvailableScenarios addObject:MerchantResistance];

    ScenarioInfo * BloodyVengeance = [[ScenarioInfo alloc] init];
	BloodyVengeance._ScenarioName = @"Bloody Vengeance";
	BloodyVengeance._MapFileName = @"vengeance";
	BloodyVengeance._MiniatureImageName = @"spanish_main_mini.png";
	BloodyVengeance._ScenarioDescription = @"The Spanish have captured several of our warships in recent action. They are moving the vessels to Caracas. You are to sink them before they are repaired and used against us!";
	[_AvailableScenarios addObject:BloodyVengeance];

#else
	//decode them, from scenario.list file!
	NSDictionary * rootObject;

 #ifdef LITE_ADMIRAL
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource: @"scenario_lite"
                                                                                             ofType: @"list"] ];
 #else
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource: @"scenario"
                                                                                             ofType: @"list"] ];
 #endif

	_AvailableScenarios = [[rootObject valueForKey:@"AvailableScenarios"] retain];
#endif
}

//call this when we have updated scenarios list
- (void) saveAvailableScenariosList
{
	NSMutableDictionary * rootObject;
	rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue: _AvailableScenarios forKey:@"AvailableScenarios"];
	
	bool success = [NSKeyedArchiver archiveRootObject: rootObject
											   toFile: [[NSBundle mainBundle] pathForResource: @"scenario"
																					   ofType: @"list"] ];
	
	if (success) NSLog(@"Archiving of scenario list successfull!");
	else NSLog(@"Archiving scenario list FAILED!");	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//prepare scenario information
	[self loadAvailableScenarios];

#ifdef CREATE_SCENARIOS_LIST
	//save scenario list
	[self saveAvailableScenariosList];
#endif	
	
	[_SPRootView set_Scenarios:_AvailableScenarios];	
	[_SPRootView hideScenarioDetails:nil];
}

- (void) viewWillAppear:(BOOL) animated
{
	[_SPRootView showScenarios];
	[globalSoundCenter playEffect:SOUND_SCREEN_CHANGE];
    
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL) animated
{
    [_SPRootView._ScenarioScroller flashScrollIndicators];
    
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (animated) [globalSoundCenter playEffect:SOUND_SCREEN_CHANGE];

    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL) animated
{
	[_SPRootView destroyScenarios];
    [_SPRootView hideScenarioDetails:nil];
    
	[super viewDidDisappear:animated];
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
    [super dealloc];
	    
	[_SPRootView release];
	[_AvailableScenarios release];
}


@end
