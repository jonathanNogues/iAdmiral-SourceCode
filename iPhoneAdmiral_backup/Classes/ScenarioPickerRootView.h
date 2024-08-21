//
//  ScenarioPickerRootView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DQReadyControl;
@class ScenarioPickerPickView;
@class ScenarioDetailsView;

@interface ScenarioPickerRootView : UIImageView 
{
	UIScrollView * _ScenarioScroller;
	ScenarioPickerPickView * _ScenariosView;
	ScenarioDetailsView * _ChosenScenarioView;
	
    DQReadyControl * _SingleOrMultiControl;
    DQReadyControl * _AvailableScenariosControl;
    DQReadyControl * _BackControl;
    
    UIImageView * _LoadingScreen;
    
	NSArray * _Scenarios;
    
    bool _MultiplayerEnabled;
}

@property (nonatomic, retain) IBOutlet UIScrollView * _ScenarioScroller;
@property (nonatomic, retain) ScenarioPickerPickView * _ScenariosView;
@property (nonatomic, retain) IBOutlet ScenarioDetailsView * _ChosenScenarioView;
@property (nonatomic, retain) UIImageView * _LoadingScreen;

@property (nonatomic, retain) IBOutlet DQReadyControl * _SingleOrMultiControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _AvailableScenariosControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _BackControl;

@property (nonatomic, assign) NSArray * _Scenarios;

- (void) showScenarios;

- (void) destroyScenarios;

- (void) handleSelectedScenarioWithNumber:(int) num;

/* hide scenario detail view */
- (void) hideScenarioDetails:(id) sender;

- (IBAction) handlePlayerButton:(id) sender;

@end
