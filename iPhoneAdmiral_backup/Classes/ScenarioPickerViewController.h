//
//  ScenarioPickerViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScenarioPickerRootView;

@interface ScenarioPickerViewController : UIViewController {
	ScenarioPickerRootView * _SPRootView;
	
	NSMutableArray * _AvailableScenarios;
}

@property (nonatomic, retain) IBOutlet ScenarioPickerRootView * _SPRootView;

- (void) loadAvailableScenarios;

@end
