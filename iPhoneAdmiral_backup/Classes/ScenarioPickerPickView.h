//
//  ScenerioPickerPickView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScenarioPickerRootView;

@interface ScenarioPickerPickView : UIView {
	ScenarioPickerRootView * _pParent;
}

@property (nonatomic, retain) ScenarioPickerRootView * _pParent;

- (id) initWithScenarioArray:(NSArray *) scenariosAR;

- (void) handleScenarioButtonPressed:(id) sender;

#ifdef LITE_ADMIRAL

- (void) launchAppStore;

#endif

@end
