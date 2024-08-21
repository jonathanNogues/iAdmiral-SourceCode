//
//  RootView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapView;
@class InterfaceView;
@class OptionsView;
@class ScenarioChoice;

@interface RootView : UIView
{
	UIScrollView * _scrollview;			///<Scrollview that encapsulates mapview
	MapView * _mapview;					///<The map of battlefield, main widow actually
	InterfaceView * _interfaceview;		///<View of the interface
	OptionsView * _pOptionsView;
}

@property (nonatomic, retain) IBOutlet UIScrollView * _scrollview;
@property (nonatomic, readonly) MapView * _mapview;
@property (nonatomic, retain) IBOutlet InterfaceView * _interfaceview;

- (void) performSetupWithScenarioChoice:(ScenarioChoice *) schoice;


@end
