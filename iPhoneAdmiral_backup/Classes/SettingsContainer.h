//
//  SettingsContainer.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsContainer : NSObject
{
	/// play music
	bool _PlayMusic;
	
	/// play sounds
	bool _PlaySounds;
	
	/// autosave available
	bool _AutoSaveAvailable;
    
    /// autosave info string
    NSString * _AutoSaveInfoString;
    
    ///interface autohiding
    bool _InterfaceAutoHiding;
    
    ///relistic movement mode
    bool _RealisticModeOn;
}

@property (nonatomic, assign) bool _PlayMusic;
@property (nonatomic, assign) bool _PlaySounds;
@property (nonatomic, assign) bool _AutoSaveAvailable;
@property (nonatomic, assign) bool _InterfaceAutoHiding;
@property (nonatomic, assign) NSString * _AutoSaveInfoString;
@property (nonatomic, assign) bool _RealisticModeOn;

- (void) saveToUserDefaults;

- (void) restoreFromUserDefaults;

@end
