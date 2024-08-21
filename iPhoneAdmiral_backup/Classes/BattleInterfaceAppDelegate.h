//
//  BattleInterfaceAppDelegate.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenuViewController;
@class SettingsContainer;

@interface BattleInterfaceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;

	MainMenuViewController * _MainMenuController;
	UINavigationController * _NavigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MainMenuViewController * _MainMenuController;
@property (nonatomic, retain) IBOutlet UINavigationController * _NavigationController;

@end

