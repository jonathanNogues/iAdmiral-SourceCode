//
//  ScenarioDetailsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DQReadyControl;

typedef enum
{
    DiffEasy,
    DiffMedium,
    DiffHard,
    DiffAutosave,       //no difficulty setting for this one
} Difficulty;

@interface ScenarioDetailsView : UIImageView {
	UIImageView * _ScenarioMapMiniature;
	UITextView * _ScenarioDescriptionView;
    UILabel * _ScenarioNameLabel;
	
    DQReadyControl * _ToBattleControl;
    DQReadyControl * _BackControl;
    DQReadyControl * _DifficultyControl;
    
    Difficulty _CurrentDifficulty;
    
    NSString * _ScenarioMapFileName;
    
    UIImageView * _LoadingScreen;
    UIActivityIndicatorView * _LoadingIndicator;    
    
    bool _MultiplayerEnabled;
}

@property (nonatomic, retain) IBOutlet UIImageView * _ScenarioMapMiniature;
@property (nonatomic, retain) IBOutlet UILabel * _ScenarioNameLabel;
@property (nonatomic, retain) IBOutlet UITextView * _ScenarioDescriptionView;

@property (nonatomic, retain) IBOutlet DQReadyControl * _ToBattleControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _BackControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _DifficultyControl;

@property (nonatomic, assign) NSString * _ScenarioMapFileName;
@property (nonatomic, assign) bool _MultiplayerEnabled;

- (void) resetDifficulty;

- (void) hideDifficulty;

- (IBAction) handleDifficultyButton:(id) sender;

- (IBAction) handleBackButton:(id) sender;

- (IBAction) handleToBattleButton:(id) sender;

- (void) removeLoadingScreen;

@end
