//
//  TutorialsAndInstructionsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "TutorialsAndInstructionsView.h"
#import "SoundCenter.h"
#import "UICommon.h"
#import "DQReadyControl.h"

@implementation TutorialsAndInstructionsView

@synthesize _Tutorial1Control, _Tutorial2Control, _Tutorial3Control, _Tutorial4Control;

@synthesize _AvailableTutorialsLabel;
@synthesize _AdmiralopediaControl;
@synthesize _BackControl;

- (void) awakeFromNib
{
	[self setImage:[UIImage imageNamed:@"TutorialsBG.png"]];
	//[self setUserInteractionEnabled:YES];
    
    [_AvailableTutorialsLabel set_TextSize:50.0];
    [_AvailableTutorialsLabel set_TextIndent:1];
    [_AvailableTutorialsLabel set_Text:@"Available Tutorials"];
    
    [_AdmiralopediaControl set_TextSize: 40.0];
    [_AdmiralopediaControl set_TextIndent:1];
    [_AdmiralopediaControl set_Text: @"Admiralopedia"];
    [_AdmiralopediaControl setActionTarget:self
                                  selector:@selector(handleAdmiralopedia:)];
    
    [_BackControl set_TextSize:40.0];
    [_BackControl set_TextSize: 40.0];
    [_BackControl set_Text: @"back"];
    [_BackControl setActionTarget:self
                         selector:@selector(handleDone:)];
    
    [_Tutorial1Control set_TextSize:40.0];
    [_Tutorial1Control set_TextColor:BurgundyColor];
    [_Tutorial1Control set_Text:@"101 - interface"];
    [_Tutorial1Control setActionTarget:self
                              selector:@selector(handleTutorialButtons:)];

    [_Tutorial2Control set_TextSize:40.0];
    [_Tutorial2Control set_TextColor:BurgundyColor];
    [_Tutorial2Control set_Text:@"102 - navigation"];
    [_Tutorial2Control setActionTarget:self
                              selector:@selector(handleTutorialButtons:)];

    [_Tutorial3Control set_TextSize:40.0];
    [_Tutorial3Control set_TextColor:BurgundyColor];
    [_Tutorial3Control set_Text:@"103 - combat"];
    [_Tutorial3Control setActionTarget:self
                              selector:@selector(handleTutorialButtons:)];

    [_Tutorial4Control set_TextSize:40.0];
    [_Tutorial4Control set_TextColor:BurgundyColor];
    [_Tutorial4Control set_Text:@"201 - realism"];
    [_Tutorial4Control setActionTarget:self
                              selector:@selector(handleTutorialButtons:)];
    
#ifdef LITE_ADMIRAL
    [((UIImageView *)[self viewWithTag:666]) setImage:[UIImage imageNamed:@"LiteBanner.png"]];
#else
    [[self viewWithTag:666] removeFromSuperview];
#endif
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [_Tutorial1Control release];
    [_Tutorial2Control release];
    [_Tutorial3Control release];
    [_Tutorial4Control release];
    
    [_AdmiralopediaControl release];
    [_AvailableTutorialsLabel release];
    [_BackControl release];
    
    [super dealloc];
}

- (void) handleTutorialButtons:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];

    [globalSoundCenter stopBG];
    
    int tag = [((DQReadyControl *) sender) tag];
    NSString *path;
    
	switch (tag)
    {
        case 1:
            path = [[NSBundle mainBundle] pathForResource:@"interface" ofType:@"m4v"];
            break;
            
        case 2:
            path = [[NSBundle mainBundle] pathForResource:@"navigation" ofType:@"m4v"];
            break;
            
        case 3:
            path = [[NSBundle mainBundle] pathForResource:@"combat" ofType:@"m4v"];
            break;
            
        case 4:
            path = [[NSBundle mainBundle] pathForResource:@"realism" ofType:@"m4v"];
            break;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [self addSubview:player.view];
    player.fullscreen = YES;
    
    player.controlStyle = MPMovieControlStyleNone;
    
    [player prepareToPlay];
    
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserver: self  
                                             selector: @selector(tutorialPlaybackComplete:)  
                                                 name: MPMoviePlayerPlaybackDidFinishNotification  
                                               object: player];  
    
    //add controls
    [self performSelector:@selector(addControlsToPlayer:) withObject:player afterDelay:6.0];
}

- (void) addControlsToPlayer:(MPMoviePlayerController *) player
{
    player.controlStyle = MPMovieControlStyleFullscreen;
}

- (void) tutorialPlaybackComplete:(NSNotification *) notification  
{  
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    MPMoviePlayerController *moviePlayerController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self  
                                                    name:MPMoviePlayerPlaybackDidFinishNotification  
                                                  object:moviePlayerController];  
    
    [moviePlayerController.view removeFromSuperview];  
    [moviePlayerController release];
    
    //for some reason, mplayer insists on showing the status bar after being dissmissed
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    //resume music
    [globalSoundCenter playBGTrack:MUSIC_MENU Repeat:YES];
}  

- (void) handleAdmiralopedia:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_SHOW_ADMIRALOPEDIA
                                                        object:nil];
}

- (void) handleDone:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_NAME_POP_ME_ANIMATED
														object: nil];
}


@end
