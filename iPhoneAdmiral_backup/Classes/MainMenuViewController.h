//
//  MainMenuViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenuView;

@class BattleInterfaceViewController;
@class InstructionsViewController;
@class SettingsViewController;
@class ScenarioPickerViewController;
@class StatisticsViewController;
@class StatisticsContainer;
@class CreditsViewController;
@class TutorialsAndInstructionsViewController;

@interface MainMenuViewController : UIViewController 
{
    MainMenuView * _MainMenu;
	
	InstructionsViewController *                _InstructionsController;
	BattleInterfaceViewController *             _BattleInterfaceController;
	SettingsViewController *                    _SettingsController;
	ScenarioPickerViewController *              _ScenarioPickerController;
	StatisticsViewController *                  _StatisticsController;
    CreditsViewController *                     _CreditsViewController;
    TutorialsAndInstructionsViewController *    _TutorialsAndInstructionsController;
}

@property (nonatomic, retain) IBOutlet MainMenuView * _MainMenu;

@property (nonatomic, retain) IBOutlet InstructionsViewController * _InstructionsController;
@property (nonatomic, retain) IBOutlet SettingsViewController * _SettingsController;
@property (nonatomic, retain) IBOutlet ScenarioPickerViewController * _ScenarioPickerController;
@property (nonatomic, retain) IBOutlet CreditsViewController * _CreditsViewController;
@property (nonatomic, retain) IBOutlet TutorialsAndInstructionsViewController * _TutorialsAndInstructionsController;

- (void) switchToBI:(id) sender;

- (void) switchToInstructions:(id) sender;

- (void) switchToSettings:(id) sender;

- (void) switchToScenarioPicker:(id) sender;

- (void) switchToCredits:(id) sender;

- (void) switchToStatisticsWithStats:(StatisticsContainer *) stats;

@end
