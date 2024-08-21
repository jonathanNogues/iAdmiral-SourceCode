//
//  SettingsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"
#import "BattleInterfaceAppDelegate.h"
#import "SettingsContainer.h"
#import "Common.h"
#import "SoundCenter.h"
#import "DQReadyControl.h"
#import "BIAlertView.h"

//this MUST match settings in SettingsViewController.xib!
#define SOUND_TAG       1
#define MUSIC_TAG       0
#define AUTOHIDE_TAG    2
#define REALISM_TAG     3

@implementation SettingsView

@synthesize _iAdmiralLabel1;
@synthesize _iAdmiralLabel2;
@synthesize _iAdmiralSettingsLabel;

@synthesize _MusicLabel;
@synthesize _SoundLabel;
@synthesize _IAHLabel;
@synthesize _RealismLabel;

@synthesize _MusicControl;
@synthesize _SoundControl;
@synthesize _IAHControl;
@synthesize _RealismControl;

@synthesize _BackControl;

- (void) awakeFromNib
{
    [_iAdmiralLabel1 set_TextColor: BurgundyColor];
    [_iAdmiralLabel1 set_TextSize:  80.0];
    [_iAdmiralLabel1 set_Text:      @"i"];    
    [_iAdmiralLabel2 set_TextSize:  80.0];
    [_iAdmiralLabel2 set_Text:      @"Admiral"];
    
    [_iAdmiralSettingsLabel set_TextColor: BurgundyColor];
    [_iAdmiralSettingsLabel set_TextSize:  30.0];
    [_iAdmiralSettingsLabel set_Text:      @"settings"];
    
    [_MusicLabel set_TextSize: 45.0];
    [_MusicLabel set_Text: @"music is"];
    
    [_SoundLabel set_TextSize: 45.0];
    [_SoundLabel set_Text: @"sound is"];
    
    [_IAHLabel set_TextSize: 45.0];
    [_IAHLabel set_Text:@"interface autohiding is"];
    
    [_RealismLabel set_TextSize: 45.0];
    [_RealismLabel set_Text: @"realistic mode is"];
    
    [_MusicControl set_TextSize:45.0];
    [_MusicControl set_TextColor: BurgundyColor];
    [_MusicControl setActionTarget:self
                          selector:@selector(handleControl:)];
    
    [_SoundControl set_TextSize:45.0];
    [_SoundControl set_TextColor: BurgundyColor];
    [_SoundControl setActionTarget:self
                          selector:@selector(handleControl:)];
    
    [_IAHControl set_TextSize:45.0];
    [_IAHControl set_TextColor: BurgundyColor];
    [_IAHControl setActionTarget:self
                        selector:@selector(handleControl:)];

    [_RealismControl set_TextSize:45.0];
    [_RealismControl set_TextColor: BurgundyColor];
    [_RealismControl setActionTarget:self
                        selector:@selector(handleControl:)];

    [_BackControl set_TextSize:45.0];
    [_BackControl set_Text:@"back"];
    [_BackControl setActionTarget:self
                         selector:@selector(handleBack:)];
    
#ifdef LITE_ADMIRAL
    [((UIImageView *)[self viewWithTag:666]) setImage:[UIImage imageNamed:@"LiteBanner.png"]];
#else
    [[self viewWithTag:666] removeFromSuperview];
#endif
}

- (void) handleControl:(id)sender
{
    int tag = [((DQReadyControl *)sender) tag];

    switch (tag) 
    {
        case MUSIC_TAG:
            AppWideSettings._PlayMusic = ! AppWideSettings._PlayMusic;
            
            if (AppWideSettings._PlayMusic) [_MusicControl set_Text:@"On"];
            else [_MusicControl set_Text:@"Off"];
            break;

        case SOUND_TAG:
            AppWideSettings._PlaySounds = ! AppWideSettings._PlaySounds;

            if (AppWideSettings._PlaySounds) [_SoundControl set_Text:@"On"];
            else [_SoundControl set_Text:@"Off"];
            break;

        case AUTOHIDE_TAG:
            [AppWideSettings set_InterfaceAutoHiding: ! AppWideSettings._InterfaceAutoHiding];
            
            if (AppWideSettings._InterfaceAutoHiding) [_IAHControl set_Text:@"On"];
            else [_IAHControl set_Text:@"Off"];
            break;

        case REALISM_TAG:
            [AppWideSettings set_RealisticModeOn: ! AppWideSettings._RealisticModeOn];
            
            if (AppWideSettings._RealisticModeOn)
            {
                [_RealismControl set_Text:@"On"];
                
                BIAlertView * biav = [[BIAlertView alloc] initWithAlertType: AlertTypeRealismOn
                                                                    message: @"WARNING:\nRealistic mode severely changes ship behavior. See related video tutorial in the Instructions section."
                                                                   delegate: nil
                                                                cancelDelay: 0.0 ];
                
                [biav show];
                [biav release];
            }
            else [_RealismControl set_Text:@"Off"];
            break;
    }
    
    [globalSoundCenter playEffect:SOUND_CLICK];
}

- (void) handleBack:(id) sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_POP_ME_ANIMATED object:nil];
}

- (void) setup
{
    [self setImage:[UIImage imageNamed:@"SettingsBG.png"]];

    //music
    if (AppWideSettings._PlayMusic)
        [_MusicControl set_Text:@"On"];
    else
        [_MusicControl set_Text:@"Off"];

    //sound
    if (AppWideSettings._PlaySounds)
        [_SoundControl set_Text:@"On"];
    else
        [_SoundControl set_Text:@"Off"];
    
    //interface autohiding
    if (AppWideSettings._InterfaceAutoHiding)
        [_IAHControl set_Text:@"On"];
    else
        [_IAHControl set_Text:@"Off"];
    
    //realistic mode
    if (AppWideSettings._RealisticModeOn)
        [_RealismControl set_Text:@"On"];
    else
        [_RealismControl set_Text:@"Off"];
}

- (void)dealloc {
    [super dealloc];
    
    [_iAdmiralLabel1 release];
    [_iAdmiralLabel2 release];
    [_iAdmiralSettingsLabel release];
    
    [_MusicLabel release];
    [_SoundLabel release];
    [_IAHLabel release];
    [_RealismLabel release];

    [_MusicControl release];
    [_SoundControl release];
    [_IAHControl release];
    [_RealismControl release];
    
    [_BackControl release];
}


@end
