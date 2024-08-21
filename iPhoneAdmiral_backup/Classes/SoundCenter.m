//
//  SoundCenter.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundCenter.h"
#import "ObjectAL.h"

SoundCenter * globalSoundCenter;

@implementation SoundCenter

@synthesize _PlaysMusic, _PlaysSound;

- (id) initWithMusic:(bool) pm
			andSound:(bool) ps
{
	self = [super init];
	
	//setup the global options
	_PlaysMusic = pm;
	_PlaysSound = ps;
	
	// Allow Ipod in the bg
	[OALSimpleAudio sharedInstance].allowIpod = !pm;
	
	// Mute all audio if the silent switch is turned on. 
	[OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
	
	// Preload all sound effects
	NSLog(@"Preloading AUDIO...");
	[[OALSimpleAudio sharedInstance] preloadEffect:SOUND_CANNON_SALVO];
	[[OALSimpleAudio sharedInstance] preloadEffect:SOUND_CLICK];
	[[OALSimpleAudio sharedInstance] preloadEffect:SOUND_SCREEN_CHANGE];
    
	return self;
}

- (void) set_PlaysMusic:(bool) pm
{
	_PlaysMusic = pm;
	[OALSimpleAudio sharedInstance].allowIpod = !pm;
    
    //zap music if we do not want it, or start playing menu music
    if (!pm) [self stopBG];
    else [self onMenuEnter];
}

- (void) playBGTrack:(NSString *) bgtrack 
             Repeat:(BOOL) looping
{
    //if we do not play music, then we should quit here
    if (!_PlaysMusic) return;
    
	NSLog(@"Playing track: %@", bgtrack);
	[[OALSimpleAudio sharedInstance] playBg:bgtrack loop:looping];
    
    if ([bgtrack isEqualToString:MUSIC_MENU]) _MainMenuTrackPlaying = YES;
    else _MainMenuTrackPlaying = NO;
}

- (void) onBackgroundFadeComplete
{
    if (_NextBgTrack == nil)
    {
        //fade out is complete but we do not want new audio!
        [[OALSimpleAudio sharedInstance] setBgVolume:1.0];
        [self stopBG];	
    }
    else
    {
        //select new track
        [self playBGTrack:_NextBgTrack
                   Repeat:YES];
    
        //fade it in
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:1.0f 
                                                       duration:1.0f 
                                                         target:nil 
                                                       selector:nil ];
    }
}


- (void) playEffect:(NSString *) eff
{
    //if we do not play effects, then we should quit here
    if (!_PlaysSound) return;
    
	[[OALSimpleAudio sharedInstance] playEffect: eff];
}

- (void) stopBG
{
    _MainMenuTrackPlaying = NO;
	[[OALSimpleAudio sharedInstance] stopBg];	
}

- (void) stopAll
{
	[[OALSimpleAudio sharedInstance] stopEverything];
}

- (void) onMenuEnter
{
    //if main manu is already playing, return
    if (_MainMenuTrackPlaying) return;
    
    //if some other track is playing, fade it out then fade in menu
    if ([OALSimpleAudio sharedInstance].bgPlaying)
    {
    
        _NextBgTrack = MUSIC_MENU;
    
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:0.0f 
                                                       duration:1.0f 
                                                         target:self 
                                                       selector:@selector(onBackgroundFadeComplete)];
    }
    else    //no track is playing in background
    {
        //set bg to silent
        [[OALSimpleAudio sharedInstance] setBgVolume: 0.0];

        //select track
        [self playBGTrack:MUSIC_MENU Repeat:YES];
        
        //fade it in
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:1.0f 
                                                       duration:2.0f 
                                                         target:nil 
                                                       selector:nil ];
    }
}

- (void) onBattleInterfaceEnter
{
    //if some other track is playing, fade it out then fade in menu
    if ([OALSimpleAudio sharedInstance].bgPlaying)
    {
        
        _NextBgTrack = MUSIC_BATTLE;
        
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:0.0f 
                                                       duration:1.0f 
                                                         target:self 
                                                       selector:@selector(onBackgroundFadeComplete)];
    }
    else    //no track is playing in background
    {
        //set bg to silent
        [[OALSimpleAudio sharedInstance] setBgVolume: 0.0];
        
        //select track
        [self playBGTrack:MUSIC_BATTLE Repeat:YES];
        
        //fade it in
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:1.0f 
                                                       duration:3.0f 
                                                         target:nil 
                                                       selector:nil ];
    }
}

- (void) onScenarioStartsLoading
{
    if ([OALSimpleAudio sharedInstance].bgPlaying)
    {
        //make sure nothing starts playing after fade
        _NextBgTrack = nil;
        
        NSLog(@"Audio fading!");
        
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:0.0f 
                                                       duration:3.0f 
                                                         target:self 
                                                       selector:@selector(onBackgroundFadeComplete)];
    }

}


- (void) onStatsEnterVictorious:(bool) victory
{    
    NSString * chosen_track;
    
    if (victory) chosen_track = MUSIC_VICTORY;
    else chosen_track = MUSIC_DEFEAT;

    //if some other track is playing, fade it out then fade in menu
    if ([OALSimpleAudio sharedInstance].bgPlaying)
    {
        
        _NextBgTrack = chosen_track;
        
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:0.0f 
                                                       duration:1.0f 
                                                         target:self 
                                                       selector:@selector(onBackgroundFadeComplete)];
    }
    else    //no track is playing in background
    {
        //set bg to silent
        [[OALSimpleAudio sharedInstance] setBgVolume: 0.0];
        
        //select track
        [self playBGTrack:chosen_track Repeat:YES];
        
        //fade it in
        [[OALSimpleAudio sharedInstance].backgroundTrack fadeTo:1.0f 
                                                       duration:3.0f 
                                                         target:nil 
                                                       selector:nil ];
    }
    
    
}

@end
