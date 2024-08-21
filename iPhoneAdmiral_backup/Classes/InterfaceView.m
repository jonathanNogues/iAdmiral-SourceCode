//
//  InterfaceView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InterfaceView.h"
#import "MapView.h"
#import "RoundButton.h"
#import "SoundCenter.h"
#import "SettingsContainer.h"
#import "AmmoChooserView.h"

#define INTERFACE_CENTER_X          240.0
#define INTERFACE_CENTER_Y_IN       298.0
#define INTERFACE_CENTER_Y_OUT      322.0

#define WIND_BUTTON_CENTER_X_IN     240.0
#define WIND_BUTTON_CENTER_Y_IN     290.0
#define WIND_BUTTON_CENTER_X_OUT    445.0
#define WIND_BUTTON_CENTER_Y_OUT    295.0

#define AUTOHIDE_ANIM_TIME          0.4
#define AUTOHIDE_DELAY              4.0

//these are defined in .XIB so DO NOT change them
#define ROUNDSHOTBUTTONTAG          101
#define CHAINSHOTBUTTONTAG          102
#define GRAPESHOTBUTTONTAG          103

@implementation InterfaceView

@synthesize _PointerToMap, _FireButton, _WindButton, _NextButton,
			_HPLabel, _GunsLabel, _SoldiersLabel, _MPLabel, _TPLabel, _SpeedLabel;

@synthesize _isHidden, _isHiding;

@synthesize _AmmoChooser;
@synthesize _ConsoleTypeLabel;

- (id)initWithImage:(UIImage *) image
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)dealloc 
{
	NSLog(@"WARNING: Interface View is being dealloc'ed!");

    [_AutoHideTimer invalidate];
    _AutoHideTimer = nil;

	_PointerToMap = nil;
	
	[_FireButton release];
	[_WindButton release];
	[_NextButton release];
	_FireButton = nil;
	_WindButton = nil;
	_NextButton  = nil;
	
	[_HPLabel release];
	[_GunsLabel release];
	[_SoldiersLabel release];
	[_MPLabel release];
	[_TPLabel release];
	[_SpeedLabel release];
    
	_HPLabel = nil;
	_GunsLabel = nil;
	_SoldiersLabel  = nil;
	_MPLabel = nil;
	_TPLabel = nil;
	_SpeedLabel  = nil;
    _ConsoleTypeLabel = nil;
    
    [_AmmoChooser release];
    _AmmoChooser = nil;
    	
	[super dealloc];
	NSLog(@"InterfaceView dealloc finishes ok!");
}

- (void) awakeFromNib
{
    _TurnEnd = NO;
    _WindButtonEnabled = YES;
    _OtherButtonsEnabled = YES;

    _isHiding = NO;
    _isHidden = NO;
        
    [self setImage:[UIImage imageNamed:@"interface_bg.png"]];
}

                        /************************
                         *		AUTOHIDING		*
                         ***********************/

- (void) set_isHidden:(_Bool) isHidden
{    
    
    //check for autohiding
    if (!AppWideSettings._InterfaceAutoHiding)
    {
        //force appearance
        self.center = CGPointMake(INTERFACE_CENTER_X, INTERFACE_CENTER_Y_IN);
        _WindButton.center = CGPointMake(WIND_BUTTON_CENTER_X_IN, WIND_BUTTON_CENTER_Y_IN);
        
        return;    
    }

    CGPoint new_wind_center;
    CGPoint new_inter_center;
    
    if(isHidden)        //set to out of screen
    {
        new_wind_center = CGPointMake(WIND_BUTTON_CENTER_X_OUT, WIND_BUTTON_CENTER_Y_OUT);
        new_inter_center = CGPointMake(INTERFACE_CENTER_X, INTERFACE_CENTER_Y_OUT);
    }
    else                //set to inscreen
    {
        new_wind_center = CGPointMake(WIND_BUTTON_CENTER_X_IN, WIND_BUTTON_CENTER_Y_IN);
        new_inter_center = CGPointMake(INTERFACE_CENTER_X, INTERFACE_CENTER_Y_IN);        
    }

    //ANIMATION
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: AUTOHIDE_ANIM_TIME];
    [UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector:@selector(hidingDone:finished:context:)];

    self.center = new_inter_center;
    _WindButton.center = new_wind_center;
    
    [UIView commitAnimations];
    
    _isHiding = YES;
    _isHidden = isHidden;
}

- (void) hidingDone:(NSString *)animationID
           finished:(NSNumber *)finished
            context:(void *)context
{
    _isHiding = NO;
}


//bring back the interface by clicking near the edge of the screen
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //if we're not authiding...
    if (! AppWideSettings._InterfaceAutoHiding) return;
    
	UITouch *touch = [touches anyObject];
    
	if ([touch tapCount] == 1)
	{
        
		if (_isHidden)
        {
            [globalSoundCenter playEffect:SOUND_CLICK];            
            [self set_isHidden: NO];
        }
        
        [self launchAutoHideTimer];
	}     
}

- (void) launchAutoHideTimer
{
    //check for autohiding
    if (! AppWideSettings._InterfaceAutoHiding) return;

    //zap previous timer man
    [_AutoHideTimer invalidate];
    
    _AutoHideTimer = [NSTimer scheduledTimerWithTimeInterval: AUTOHIDE_DELAY
                                                      target: self
                                                    selector: @selector(autoHideByTimer:)
                                                    userInfo: nil
                                                     repeats: NO];
}

- (void) autoHideByTimer:(NSTimer *) timer
{
    [self set_isHidden: YES];
    
    _AutoHideTimer = nil;
}

					/************************************
					*		THE BUTTON PERFORMERS		*
					************************************/


- (void) FireButtonGO:(id) sender
{
	if (! _OtherButtonsEnabled)
	{
		NSLog(@"This button is disabled!");
		return;
	}
	
    [globalSoundCenter playEffect:SOUND_CLICK];

	NSLog(@"Interface: Fire!\n");
	
	[_PointerToMap handleFire];
}

- (void) OptionsButtonGO:(id) sender
{
	NSLog(@"Interface: Options!\n");
	
	if (!_WindButtonEnabled) 
	{
		NSLog(@"Interface: Wind button disabled!!!");
		return;
	}
    
    [globalSoundCenter playEffect:SOUND_CLICK];
	
	//disable the button until the options menu animation is done.
	//this will be signaled by the mapview
	_WindButtonEnabled = NO;
	_OtherButtonsEnabled = NO;
	
    //stop autohiding
    [_AutoHideTimer invalidate];
    _AutoHideTimer = nil;
	
	[_PointerToMap handleOptions];
}

- (void) NextOrEndGO:(id) sender
{
	if (! _OtherButtonsEnabled)
	{
		NSLog(@"This button is disabled!");
		return;
	}
    
    [globalSoundCenter playEffect:SOUND_CLICK];
	
	if (_TurnEnd)
	{
		NSLog(@"Interface: End Turn!\n");
		[_PointerToMap handleEndTurn];
	}
	else
	{
		NSLog(@"Interface: Next!\n");
		[_PointerToMap handleNextShip];			
	}
}

- (void) handleShotButtons:(id) sender
{
    int tag = [((UIButton *)sender) tag];
    
    [globalSoundCenter playEffect: SOUND_CLICK];
    
    AmmunitionType new_ammo_type;
    
    switch (tag)
    {
        case ROUNDSHOTBUTTONTAG:
            new_ammo_type = AmmoRoundShot;
            break;
            
        case CHAINSHOTBUTTONTAG:
            new_ammo_type = AmmoChainShot;
            break;
            
        case GRAPESHOTBUTTONTAG:
            new_ammo_type = AmmoGrapeShot;
            break;
    }

    [_AmmoChooser setSelectedAmmoTypeTo: new_ammo_type];
    [_PointerToMap handleAmmoChangeTo: new_ammo_type];

    [_AmmoChooser setVisibilityTo:StateIconOnly];
}

					/****************************************
					*		INTERFACE UPDATE FUNCTIONS		*
					****************************************/

- (void) setAmmoChooserStateTo:(AmmoChooserUIState) acuis
{
    [_AmmoChooser setVisibilityTo: acuis];
}

- (void) setSelectedAmmoTypeTo:(AmmunitionType) at
{
    [_AmmoChooser setSelectedAmmoTypeTo: at];
}

/* Set ship data, the not so often changing part */
- (void) setShipDataHP:(int) hp
				  Guns:(int) guns
			  Soldiers:(int) sol
{
	NSLog(@"Setting Ship Data...\n");
	
	NSString * temp1 = [[NSString alloc] initWithFormat:@"%d", hp];
	[_HPLabel setText:temp1];
	[temp1 release];

	NSString * temp2 = [[NSString alloc] initWithFormat:@"%d", guns];
	[_GunsLabel setText:temp2];
	[temp2 release];

	NSString * temp3 = [[NSString alloc] initWithFormat:@"%d", sol];
	[_SoldiersLabel setText:temp3];
	[temp3 release];	
}

/* update the oft changing ship data part */
- (void) updateShipDataMP:(int) mp
					   TP:(int) tp
					Turns:(TurningAbility) ta;
{
	NSLog(@"Updating Ship Data...\n");

	NSString * temp1 = [[NSString alloc] initWithFormat:@"%d", mp];
	[_MPLabel setText:temp1];
	[temp1 release];
	
	NSString * temp2 = [[NSString alloc] initWithFormat:@"%d", tp];
	[_TPLabel setText:temp2];
	[temp2 release];
	
    NSString * temp3;
    
    switch (ta)
    {
        case TurnImpossible:
            [_SpeedLabel setTextColor: BurgundyColor];
            temp3 = @"0";
            break;
            
        case TurnEmergency:
            [_SpeedLabel setTextColor: BurgundyColor];
            temp3 = @"(1)";
            break;
            
        default:
            [_SpeedLabel setTextColor: [UIColor blackColor]];
            temp3 = [[NSString alloc] initWithFormat:@"%d", ta];
            break;
    }
    
	[_SpeedLabel setText:temp3];
	[temp3 release];	
}

/* called to set next_or_end button mode */
- (void) setTurnEnd:(bool) te
{
	_TurnEnd = te;
	
	if (te)
	{
		//this does not work, dunno why
		NSLog(@"Setting button to END\n");
		//[_NextButton setTitle:@"END" forState:UIControlStateNormal];
		[_NextButton setImage: [UIImage imageNamed:@"interface_end_bg.png"]
					 forState: UIControlStateNormal ];
	}
	else
	{
		NSLog(@"Setting button to NEXT\n");	
		//[_NextButton setTitle:@"NEXT" forState:UIControlStateNormal];
		[_NextButton setImage: [UIImage imageNamed:@"interface_next_bg.png"]
					 forState: UIControlStateNormal ];
	}
}

/* sets the rotation of the compass rose (wind button) */
- (void) setWindDirection:(HexDirection) dir
				 animated:(bool) ani
{
	NSLog(@"Rotating WIND BUTTON to %d degrees", dir * 60 );
	
	CGRect wbrect = [_WindButton frame];
	
	if (ani)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration: 0.5];
		_WindButton.transform = CGAffineTransformMakeRotation( dir * 60 * M_PI / 180 );
		[UIView commitAnimations];
	}
	else
	{
		_WindButton.transform = CGAffineTransformMakeRotation( dir * 60 * M_PI / 180 );
	}
	
	wbrect = [_WindButton frame];
}

- (void) setUserInteractionEnabled:(BOOL) userInteractionEnabled
{
    _WindButtonEnabled = userInteractionEnabled;
    _OtherButtonsEnabled = userInteractionEnabled;
    
    [super setUserInteractionEnabled:userInteractionEnabled];
}

/* resets windbutton for usage */
- (void) resetWindButton
{
	_WindButtonEnabled = YES;
}

/* resets other buttons for usage */
- (void) resetOtherButtons
{
	_OtherButtonsEnabled = YES;
}

- (void) displayThisTextOnConsole:(NSString *) text
{
    [_ConsoleTypeLabel setText:text];
    [_ConsoleTypeLabel setAlpha:1.0];
    
    AnimationBlock_t anim_block = 
    ^{
        _ConsoleTypeLabel.alpha = 0.0;
    };
    
    /*
    CompletionBlock_t comp_block = 
    ^(BOOL fin){
        
    };*/
    
    [UIView animateWithDuration: 2.0
                          delay: 1.0
                        options: UIViewAnimationOptionAllowUserInteraction
                     animations: anim_block
                     completion: nil ];
}

@end
