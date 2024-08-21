//
//  AmmoChooserView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AmmoChooserView.h"

#define VIEW_Y      140.0

#define VISIBLE_X   450.0
#define MIDDLE_X    485.0
#define HIDDEN_X    521.0

#define ANIM_TIME       0.5
#define AUTOHIDE_DELAY  3.0

@implementation AmmoChooserView

@synthesize _RoundShotButton, _ChainShotButton, _GrapeShotButton, _SelectedShotIcon;

- (void) awakeFromNib
{
	//set my own background
    [self setImage:[UIImage imageNamed:@"AmmoPickerBG.png"]];
    
    [self setVisibilityTo:StateHidden];
}

- (void) setToHidden
{
    [self setVisibilityTo: StateHidden];
}

- (void) setToIconOnly
{
    [self setVisibilityTo: StateIconOnly];
}

- (void) setToVisible
{
    [self setVisibilityTo: StateVisible];
}

- (void) setVisibilityTo:(AmmoChooserUIState) uistate
{
    //if (_Animating) return;
    
    // zap previous perform requests
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    
    _Animating = YES;
    
    CGPoint new_center = CGPointMake(0, VIEW_Y);
    
	switch (uistate)
    {
        case StateHidden:
            new_center.x = HIDDEN_X;
            break;
            
        case StateIconOnly:
            new_center.x = MIDDLE_X;
            break;
            
        case StateVisible:
            new_center.x = VISIBLE_X;
            break;
    }
    
    //animate!
    AnimationBlock_t anim_block = 
    ^{
        [self setCenter:new_center];
    };
    
    CompletionBlock_t comp_block = 
    ^(BOOL fin){
        _MyState = uistate;
        _Animating = NO;
        
        //this view does not stay fully visible permanently
        if (uistate == StateVisible)
            [self performSelector:@selector(setToIconOnly) withObject:nil afterDelay: AUTOHIDE_DELAY];
    };
    
    [UIView animateWithDuration: ANIM_TIME
                     animations: anim_block
                     completion: comp_block ];
}

- (void) setSelectedAmmoTypeTo:(AmmunitionType) at
{
    //set the icon and set the apropriate button to highlited state...
	switch (at)
    {
        case AmmoRoundShot:
            [_SelectedShotIcon setImage:[UIImage imageNamed:@"RoundshotIcon.png"]];
            [_RoundShotButton setImage:[UIImage imageNamed:@"RoundShotSelected.png"] forState:UIControlStateNormal];
            [_ChainShotButton setImage:[UIImage imageNamed:@"ChainShotShadow.png"] forState:UIControlStateNormal];
            [_GrapeShotButton setImage:[UIImage imageNamed:@"GrapeShotShadow.png"] forState:UIControlStateNormal];
            break;
            
        case AmmoChainShot:
            [_SelectedShotIcon setImage:[UIImage imageNamed:@"ChainshotIcon.png"]];
            [_RoundShotButton setImage:[UIImage imageNamed:@"RoundShotShadow.png"] forState:UIControlStateNormal];
            [_ChainShotButton setImage:[UIImage imageNamed:@"ChainShotSelected.png"] forState:UIControlStateNormal];
            [_GrapeShotButton setImage:[UIImage imageNamed:@"GrapeShotShadow.png"] forState:UIControlStateNormal];
            break;
            
        case AmmoGrapeShot:
            [_SelectedShotIcon setImage:[UIImage imageNamed:@"GrapeshotIcon.png"]];
            [_RoundShotButton setImage:[UIImage imageNamed:@"RoundShotShadow.png"] forState:UIControlStateNormal];
            [_ChainShotButton setImage:[UIImage imageNamed:@"ChainShotShadow.png"] forState:UIControlStateNormal];
            [_GrapeShotButton setImage:[UIImage imageNamed:@"GrapeShotSelected.png"] forState:UIControlStateNormal];
            break;
            
        case AmmoHotShot:
            break;
    }
}

//handle touches - so that the view can be brought to screen
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    
	if ([touch tapCount] == 1)
	{
        [self setToVisible];
    }     
}


- (void)dealloc 
{
    NSLog(@"WARNING: AmmoChooserView is being dealloc'd!");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_RoundShotButton release];
    [_ChainShotButton release];
    [_GrapeShotButton release];
    [_SelectedShotIcon release];
    
    [super dealloc];
    
    NSLog(@"AmmoChooserView dealloc ok!");
}


@end
