//
//  SoundCenter.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectAL.h"

//normal interface sounds
#define SOUND_CLICK                     @"click.caf"
#define SOUND_SCREEN_CHANGE             @"page_turn.caf"

//battle interface sounds
#define SOUND_BATTLE_BG_MUSIC			@"some background"

#define SOUND_CANNON_SALVO				@"cannon_salvo.caf"
#define SOUND_CANNON_HIT					
#define SOUND_CANNON_MISS					
#define SOUND_BOARDING_ACTION		
#define SOUND_SHIP_SINK                 @"ShipSinkSound.caf"

#define SOUND_SHIP_TURN                 @"ShipMoveSound.caf"                 
#define SOUND_SHIP_MOVE                 @"ShipMoveSound.caf"

#define SOUND_TURN_START                @"TurnBell.caf"

#define MUSIC_MENU                      @"MenuMusicLoop.m4a"
#define MUSIC_BATTLE                    @"BattleMusicLoop.m4a"
#define MUSIC_VICTORY                   @"VictoryMusicLoop.m4a"
#define MUSIC_DEFEAT                    @"DefeatMusicLoop.m4a"

//global sound center
@class SoundCenter;
extern SoundCenter * globalSoundCenter;

@interface SoundCenter : NSObject 
{
	bool _PlaysMusic;
	bool _PlaysSound;
    
    NSString * _NextBgTrack;
    float _SavedVolumeLevel;
    
    BOOL _MainMenuTrackPlaying;
}

@property (nonatomic, assign) bool _PlaysMusic;
@property (nonatomic, assign) bool _PlaysSound;

- (id) initWithMusic:(bool) pm
			andSound:(bool) ps; 

/*  call when main menu appears, internal sound center logic will 
    sort it out even if call comes after settings or instructions
    viewcontrollers disappear */
- (void) onMenuEnter;

/* call when BattleInterface appears */
- (void) onBattleInterfaceEnter;

/* call when scenario begins loading */
- (void) onScenarioStartsLoading;

- (void) onStatsEnterVictorious:(bool) victory;

- (void) playBGTrack:(NSString *) bgtrack 
              Repeat:(BOOL) looping;

- (void) playEffect:(NSString *) eff;

- (void) stopBG;

- (void) stopAll;

@end
