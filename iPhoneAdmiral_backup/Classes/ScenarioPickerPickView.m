//
//  ScenerioPickerPickView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScenarioPickerPickView.h"
#import "ScenarioPickerRootView.h"
#import "ScenarioInfo.h"
#import "Common.h"
#import "SettingsContainer.h"
#import "SoundCenter.h"

@implementation ScenarioPickerPickView

@synthesize _pParent;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
   }
    return self;
}

- (void) handleScenarioButtonPressed:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];
	
	UIButton * send_button = (UIButton *)sender;
	
	int num = send_button.tag;
	
	[_pParent handleSelectedScenarioWithNumber: num];
	
}

#define SCENARIO_BUTTON_WIDTH		200.0
#define SCENARIO_BUTTON_HEIGTH		40.0
#define SCENARIO_BUTTON_X_OFFSET	25.0
#define SCENARIO_BUTTON_Y_OFFSET	10.0
#define SCENARIO_BUTTON_SPREAD		10.0

- (id) initWithScenarioArray:(NSArray *) scenariosAR
{
	//setup frame
	int scenario_count = [scenariosAR count];
	
	//if autosave unavailable, deduct one scenario
	if (!AppWideSettings._AutoSaveAvailable) 
        scenario_count--;
    else     //set autosave info string from user defaults
        [(ScenarioInfo *)[scenariosAR objectAtIndex: 0] set_ScenarioDescription:AppWideSettings._AutoSaveInfoString];	
    
#ifdef LITE_ADMIRAL
    //additional space for [more scenarios] buton
	CGRect frame = CGRectMake(0, 0, 200, (scenario_count + 1) * (SCENARIO_BUTTON_HEIGTH + SCENARIO_BUTTON_SPREAD));
#else
    //create frame
	CGRect frame = CGRectMake(0, 0, 200, scenario_count * (SCENARIO_BUTTON_HEIGTH + SCENARIO_BUTTON_SPREAD));
#endif

	self = [self initWithFrame:frame];
	
	//setup scenario buttons
	int button_pos = 0;
	int scenario_numer = 0;
	for (ScenarioInfo * scnfo in scenariosAR)
	{
		//if no autosave, ignore autosave ;-)
		if ([scnfo._ScenarioName isEqualToString:@"Last Save"] && !AppWideSettings._AutoSaveAvailable)
		{
			NSLog(@"SSPV: Omitting autosave button!");
			scenario_numer++;
			continue;
		}
		
		UIButton * uib = [UIButton buttonWithType:UIButtonTypeCustom];

		UIFont * scenario_font = [UIFont fontWithName:@"Cochin-BoldItalic" size:18];
		uib.titleLabel.font = scenario_font;
		[uib setTitleColor:[UIColor blackColor] forState:UIControlStateNormal & UIControlStateSelected];

		//set action
		[uib setEnabled:YES];
		[uib addTarget:self
				action:@selector(handleScenarioButtonPressed:)
	  forControlEvents:UIControlEventTouchUpInside];
		
		[uib setTitle: scnfo._ScenarioName forState: UIControlStateNormal & UIControlStateSelected];
		
		//calculate origin coords
		CGFloat orig_x = SCENARIO_BUTTON_X_OFFSET;
		CGFloat orig_y = SCENARIO_BUTTON_Y_OFFSET + button_pos * (SCENARIO_BUTTON_HEIGTH + SCENARIO_BUTTON_SPREAD);
		
		//set position and add to view
		[uib setFrame:CGRectMake(orig_x, orig_y, SCENARIO_BUTTON_WIDTH, SCENARIO_BUTTON_HEIGTH)];		
		[uib setTag: scenario_numer];
		[self addSubview:uib];
		
		//increase position count
		button_pos++;
		scenario_numer++;
	}
	
#ifdef LITE_ADMIRAL    
    //create more scenarios button
    UIButton * uib = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIFont * scenario_font = [UIFont fontWithName:@"Cochin-BoldItalic" size:18];
    uib.titleLabel.font = scenario_font;
    [uib setTitleColor:[UIColor blackColor] forState:UIControlStateNormal & UIControlStateSelected];
    
    //set action
    [uib setEnabled:YES];
    [uib addTarget:self
            action:@selector(launchAppStore)
  forControlEvents:UIControlEventTouchUpInside];
    
    [uib setTitle: @"More Scenarios" forState: UIControlStateNormal & UIControlStateSelected];
    
    //calculate origin coords
    CGFloat orig_x = SCENARIO_BUTTON_X_OFFSET;
    CGFloat orig_y = SCENARIO_BUTTON_Y_OFFSET + button_pos * (SCENARIO_BUTTON_HEIGTH + SCENARIO_BUTTON_SPREAD);
    
    //set position and add to view
    [uib setFrame:CGRectMake(orig_x, orig_y, SCENARIO_BUTTON_WIDTH, SCENARIO_BUTTON_HEIGTH)];		
    [uib setTag: scenario_numer];
    [self addSubview:uib];
#endif
    
	return self;
}

#ifdef LITE_ADMIRAL
- (void) launchAppStore
{
    NSLog(@"Launching app store");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/app/iadmiral"]];
}
#endif


- (void) dealloc 
{
	NSLog(@"WARNING: ScenarioPickerPickView is being dealloc'd!");
	
	_pParent = nil;
	
    [super dealloc];
}


@end