//
//  ScenarioDetailsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScenarioDetailsView.h"
#import "Common.h"
#import "SoundCenter.h"
#import "ScenarioChoice.h"
#import "DQReadyControl.h"

@implementation ScenarioDetailsView

@synthesize _ScenarioMapMiniature, _ScenarioDescriptionView, _ScenarioNameLabel;
@synthesize _ScenarioMapFileName;
@synthesize _MultiplayerEnabled;

@synthesize _ToBattleControl;
@synthesize _BackControl;
@synthesize _DifficultyControl;

- (void) awakeFromNib
{
    [self setImage:[UIImage imageNamed:@"ScenarioDetailsBG.png"]];

    [_DifficultyControl set_TextSize:   35.0];
    [_DifficultyControl set_TextCentered:YES];
    [_DifficultyControl set_Text:       @"Medium"];
    [_DifficultyControl setActionTarget:self 
                               selector:@selector(handleDifficultyButton:)];
    
    [_BackControl set_TextSize:         40.0];
    [_BackControl set_Text:             @"back"];
    [_BackControl setActionTarget:      self 
                         selector:      @selector(handleBackButton:)];

    [_ToBattleControl set_TextColor:    BurgundyColor];
    [_ToBattleControl set_TextSize:     45.0];
    [_ToBattleControl set_Text:         @"to battle !"];
    [_ToBattleControl setActionTarget:  self 
                             selector:  @selector(handleToBattleButton:)];
}

- (void) hideDifficulty
{
    _CurrentDifficulty = DiffAutosave;
    [_DifficultyControl setAlpha: 0.0];
}

- (void) resetDifficulty
{
    _CurrentDifficulty = DiffEasy;
    [_DifficultyControl setAlpha: 1.0];
    [_DifficultyControl set_Text: @"Easy"];
}

- (IBAction) handleDifficultyButton:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];

    _CurrentDifficulty = (_CurrentDifficulty + 1) % 3;
    
    switch (_CurrentDifficulty) 
    {
        case DiffEasy:
            [_DifficultyControl set_Text: @"Easy"];
            break;

        case DiffMedium:
            [_DifficultyControl set_Text: @"Medium"];
            break;

            
        case DiffHard:
            [_DifficultyControl set_Text: @"Hard"];
            break;

        default:
            break;
    }
}

- (IBAction) handleBackButton:(id) sender
{
    [globalSoundCenter playEffect:SOUND_CLICK];

    [self removeFromSuperview];
}

- (IBAction) handleToBattleButton:(id) sender
{
    //                      PREPARE ACTUAL LAUNCH INFO
    ScenarioChoice * schoice = [[ScenarioChoice alloc] init];
    switch (_CurrentDifficulty) 
    {
        case DiffEasy:
            schoice._MapFileName = [NSString stringWithFormat:@"%@%@", _ScenarioMapFileName, @"_easy"];
            schoice._AutoSave = NO;
            
            break;
            
        case DiffMedium:
            schoice._MapFileName = [NSString stringWithFormat:@"%@%@", _ScenarioMapFileName, @"_medium"];
            schoice._AutoSave = NO;

            break;
            
        case DiffHard:
            schoice._MapFileName = [NSString stringWithFormat:@"%@%@", _ScenarioMapFileName, @"_hard"];
            schoice._AutoSave = NO;

            break;
            
        case DiffAutosave:
            schoice._MapFileName = _ScenarioMapFileName;
            schoice._AutoSave = YES;
            break;
    }
    
    schoice._Multiplayer = _MultiplayerEnabled;
    
    //PLAY CLICK SOUND
    [globalSoundCenter playEffect:SOUND_CLICK];
    
    //                      PREPARE LOADING SCREEN
    _LoadingScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScenarioLoadingScreen.png"]];
    [_LoadingScreen setAlpha:0.0];
    
    //                      LOADING INDICATOR
    _LoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_LoadingScreen addSubview:_LoadingIndicator];
    [_LoadingIndicator setCenter:CGPointMake(230, 250)];
    
    [self addSubview: _LoadingScreen];
    [self setCenter:[self center]];

    //prepare animations
    AnimationBlock_t anim_block = 
    ^{
        [_LoadingScreen setAlpha: 1.0];
    };
    
    CompletionBlock_t comp_block = 
    ^(BOOL fin){
        NSLog(@"To battle defined in %@!", schoice._MapFileName);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_SWITCH_TO_BI object: schoice];
    };
    
    //                      START ANIMATIONS
    [_LoadingIndicator startAnimating];
    
    [UIView animateWithDuration:0.5
                     animations:anim_block
                     completion:comp_block ];}

- (void) removeLoadingScreen
{
    [_LoadingIndicator stopAnimating];
    [_LoadingIndicator removeFromSuperview];
    [_LoadingIndicator release];
    _LoadingIndicator = nil;
    
    [_LoadingScreen removeFromSuperview];
    [_LoadingScreen release];
    _LoadingScreen = nil;    
}


- (void)dealloc 
{    
    NSLog(@"WARNING: ScenarioDetailsView is being dealloc'd!");
    
    [self removeLoadingScreen];
    
    _ScenarioMapMiniature = nil;
    _ScenarioDescriptionView = nil;
    _ScenarioNameLabel = nil;
    
    [_DifficultyControl release];
    [_ToBattleControl release];
    [_BackControl release];
    
    [super dealloc];
    NSLog(@"ScenarioDetailsView dealloc ok!");

}

@end
