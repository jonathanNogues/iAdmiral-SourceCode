//
//  SettingsViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsView;

@interface SettingsViewController : UIViewController {
	SettingsView * _SettingsView;
}

@property (nonatomic, retain) IBOutlet SettingsView * _SettingsView;

@end
