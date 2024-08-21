//
//  MainMenuView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class DQReadyControl;

@interface MainMenuView : UIImageView
{
    DQReadyControl * _ContinueBattleControl;
    DQReadyControl * _NewScenarioControl;
    DQReadyControl * _InstructionsControl;
    DQReadyControl * _SettingsControl;
    DQReadyControl * _CreditsControl;
    
    DQReadyControl * _iAdmiralLabel1;
    DQReadyControl * _iAdmiralLabel2;
    
    //for continue button loading autosave
    UIImageView * _LoadingScreen;
    UIActivityIndicatorView * _LoadingIndicator;
    
    //LITE ADMIRAL
    DQReadyControl * _LiteLabel;
    DQReadyControl * _GetFullControl;
}

@property (nonatomic, retain) IBOutlet DQReadyControl * _ContinueBattleControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _NewScenarioControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _InstructionsControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _SettingsControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _CreditsControl;

@property (nonatomic, retain) IBOutlet DQReadyControl * _iAdmiralLabel1;
@property (nonatomic, retain) IBOutlet DQReadyControl * _iAdmiralLabel2;

//LITE ADMIRAL
@property (nonatomic, retain) IBOutlet DQReadyControl * _LiteLabel;
@property (nonatomic, retain) IBOutlet DQReadyControl * _GetFullControl;

- (void) setup;

- (void) animateLoadingScreen:(CompletionBlock_t) comp_block;

- (void) dropLoadingScreen;

//LITE ADMIRAL
#ifdef LITE_ADMIRAL
- (void) launchAppStore;
#endif

@end
