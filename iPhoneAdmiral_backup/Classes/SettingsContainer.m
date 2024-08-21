//
//  SettingsContainer.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsContainer.h"
#import "Common.h"

#import "SoundCenter.h"

//global settings container
SettingsContainer * AppWideSettings;

@implementation SettingsContainer

@synthesize _AutoSaveAvailable;
@synthesize _AutoSaveInfoString;
@synthesize _PlayMusic;
@synthesize _PlaySounds;
@synthesize _InterfaceAutoHiding;
@synthesize _RealisticModeOn;

- (id) init
{
	self = [super init];
		
	//first run...
	_PlayMusic = YES;
	_PlaySounds = YES;
	_AutoSaveAvailable = NO;
    _AutoSaveInfoString = [[NSString alloc] init];
    _InterfaceAutoHiding = NO;
    _RealisticModeOn = NO;
    
	return self;
}

- (void) set_PlayMusic:(_Bool) pm
{
    _PlayMusic = pm;
    
    //update sound center immiedieatly
    [globalSoundCenter set_PlaysMusic:pm];

    [self saveToUserDefaults];
}

- (void) set_PlaySounds:(_Bool) ps
{
    _PlaySounds = ps;
    
    //update sound center immiedieatly
    [globalSoundCenter set_PlaysSound:ps];    

    [self saveToUserDefaults];
}


- (void) set_AutoSaveAvailable:(_Bool) avail
{
	if (_AutoSaveAvailable != avail)	//change - save it
	{
		_AutoSaveAvailable = avail;
		[self saveToUserDefaults];
	}
}

- (void) set_InterfaceAutoHiding:(_Bool) autohide
{
    _InterfaceAutoHiding = autohide;
    
    [self saveToUserDefaults];
}

- (void) set_RealisticModeOn:(_Bool) rs
{
    _RealisticModeOn = rs;
    
    [self saveToUserDefaults];
}

- (void) set_AutoSaveInfoString:(NSString *) asis
{
    _AutoSaveInfoString = asis;
    
    NSLog(@"Autosave info now reads: %@", _AutoSaveInfoString);
    
    [self saveToUserDefaults];
}

- (void) saveToUserDefaults
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //flag that the defaults are indeed being saved
    [prefs setBool:YES forKey:@"TheDefaultsWereSaved"];
    
    [prefs setBool:_PlayMusic forKey:@"_PlayMusic"];
    [prefs setInteger:_PlaySounds forKey:@"_PlaySounds"];
    [prefs setBool:_AutoSaveAvailable forKey:@"_AutoSaveAvailable"];
    [prefs setValue:_AutoSaveInfoString forKey:@"_AutoSaveInfoString"];
    [prefs setBool:_InterfaceAutoHiding forKey:@"_InterfaceAutoHiding"];
    [prefs setBool:_RealisticModeOn forKey:@"_RealisticModeOn"];
}

- (void) restoreFromUserDefaults
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //checks if the defaults were previously saved
    if (! [prefs boolForKey:@"TheDefaultsWereSaved"] ) return;
    
	_PlayMusic =            [prefs boolForKey:@"_PlayMusic"];
	_PlaySounds =           [prefs boolForKey:@"_PlaySounds"];
	_AutoSaveAvailable =    [prefs boolForKey:@"_AutoSaveAvailable"];
    _AutoSaveInfoString =   [[prefs valueForKey:@"_AutoSaveInfoString"] retain];
    _InterfaceAutoHiding =  [prefs boolForKey:@"_InterfaceAutoHiding"];
    _RealisticModeOn =      [prefs boolForKey:@"_RealisticModeOn"];

}

@end
