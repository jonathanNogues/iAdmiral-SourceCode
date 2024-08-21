//
//  MainMenuView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuView.h"
#import "DQReadyControl.h"

@implementation MainMenuView

@synthesize _ContinueBattleControl;
@synthesize _NewScenarioControl;
@synthesize _InstructionsControl;
@synthesize _SettingsControl;
@synthesize _CreditsControl;

@synthesize _iAdmiralLabel1;
@synthesize _iAdmiralLabel2;

//LITE ADMIRAL
@synthesize _LiteLabel;
@synthesize _GetFullControl;


- (void) awakeFromNib
{
	[self setUserInteractionEnabled:YES];
	[self setImage:[UIImage imageNamed:@"MainMenuBG.png"]];
    
#ifdef LITE_ADMIRAL
    [((UIImageView *)[self viewWithTag:666]) setImage:[UIImage imageNamed:@"LiteBanner.png"]];
#else
    [[self viewWithTag:666] removeFromSuperview];
#endif
    
    _LoadingScreen = nil;
    _LoadingIndicator = nil;
}

- (void) setup
{
    [_ContinueBattleControl set_TextSize:      60.0];
    [_ContinueBattleControl set_TextColor:     BurgundyColor];
    [_ContinueBattleControl set_Text:          @"continue"];
    [_ContinueBattleControl setActionSelector: @selector(switchToBI:)];

    [_NewScenarioControl set_TextSize:      60.0];
    [_NewScenarioControl set_Text:          @"new scenario"];
    [_NewScenarioControl setActionSelector: @selector(switchToScenarioPicker:)];

    [_InstructionsControl set_TextSize:      40.0];
    [_InstructionsControl set_Text:          @"instructions"];
    [_InstructionsControl setActionSelector: @selector(switchToInstructions:)];

    [_SettingsControl set_TextSize:      40.0];
    [_SettingsControl set_Text:          @"settings"];
    [_SettingsControl setActionSelector: @selector(switchToSettings:)];

    [_CreditsControl set_TextSize:      25.0];
    [_CreditsControl set_Text:          @"credits"];
    [_CreditsControl setActionSelector: @selector(switchToCredits:)];
    
    //----------------------------------------------------------------------------
    
    [_iAdmiralLabel1 set_TextSize:      90.0];
    [_iAdmiralLabel1 set_TextColor:     BurgundyColor];
    [_iAdmiralLabel1 set_Text:          @"i"];
    [_iAdmiralLabel2 set_TextSize:      90.0];
    [_iAdmiralLabel2 set_Text:          @"Admiral"];

    //----------------------------------------------------------------------------

//LITE ADMIRAL
#ifdef LITE_ADMIRAL
    [_GetFullControl set_TextSize:      50.0];
    [_GetFullControl set_TextColor:     BurgundyColor];
    [_GetFullControl set_TextIndent:    1];
    [_GetFullControl set_Text:          @"get full version"];
    [_GetFullControl set_ActionTarget:  self];
    [_GetFullControl setActionSelector: @selector(launchAppStore)];
#else
    
#endif
}

- (void) animateLoadingScreen:(CompletionBlock_t) comp_block
{
    //                      PREPARE LOADING SCREEN
    _LoadingScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScenarioLoadingScreen.png"]];
    [_LoadingScreen setAlpha:0.0];
    
    //                      LOADING INDICATOR
    _LoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_LoadingScreen addSubview:_LoadingIndicator];
    [_LoadingIndicator setCenter:CGPointMake(230, 250)];
    
    [self addSubview: _LoadingScreen];
    [self setCenter:[self center]];
    
    //prepare animations
    AnimationBlock_t anim_block = 
    ^{
        [_LoadingScreen setAlpha: 1.0];
    };
        
    //                      START ANIMATIONS
    [_LoadingIndicator startAnimating];
    
    [UIView animateWithDuration:0.5
                     animations:anim_block
                     completion:comp_block ];
}

- (void) dropLoadingScreen
{
    [_LoadingIndicator stopAnimating];
    [_LoadingIndicator removeFromSuperview];
    [_LoadingIndicator release];
    _LoadingIndicator = nil;
    
    [_LoadingScreen removeFromSuperview];
    [_LoadingScreen release];
    _LoadingScreen = nil;    
}

#ifdef LITE_ADMIRAL
- (void) launchAppStore
{
    NSLog(@"Launching app store");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/app/iadmiral"]];
}
#endif

- (void)dealloc {
    [_ContinueBattleControl release];
    [_NewScenarioControl release];
    [_InstructionsControl release];
    [_SettingsControl release];
    [_CreditsControl release];
    
    [_iAdmiralLabel1 release];
    [_iAdmiralLabel2 release];
    
    [_GetFullControl release];
    [_LiteLabel release];
    
    [self dropLoadingScreen];
    
    [super dealloc];

}


@end
