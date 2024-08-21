//
//  BattleInterfaceViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootView;
@class ScenarioChoice;

@interface BattleInterfaceViewController : UIViewController {
	RootView * _rootView;
    
    ScenarioChoice * _ChosenScenario;
}

@property (nonatomic, retain) IBOutlet RootView * _rootView;
@property (nonatomic, assign) ScenarioChoice * _ChosenScenario;

@end

