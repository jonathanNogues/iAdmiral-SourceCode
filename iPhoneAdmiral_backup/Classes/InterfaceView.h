//
//  InterfaceView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class MapView;
@class RoundButton;
@class AmmoChooserView;

@interface InterfaceView : UIImageView 
{
	MapView * _PointerToMap;

	UIButton * _FireButton;
	RoundButton * _WindButton;
	UIButton * _NextButton;
	
	UILabel * _HPLabel;
	UILabel * _GunsLabel;
	UILabel * _SoldiersLabel;

	UILabel * _MPLabel;
	UILabel * _TPLabel;
	UILabel * _SpeedLabel;
	
	bool _TurnEnd;
	bool _WindButtonEnabled;		//this is required for temporary disabling of the button
	bool _OtherButtonsEnabled;		//for other buttons than wind
    
    //autohiding
    bool _isHidden;                 //set or test for InterfaceView being hidden
    bool _isHiding;                 //returns true if autohiding is taking place
    
    NSTimer * _AutoHideTimer;
	
	AmmoChooserView * _AmmoChooser;
    
    UILabel * _ConsoleTypeLabel;
}

@property (nonatomic, retain) IBOutlet MapView * _PointerToMap;

@property (nonatomic, retain) IBOutlet UIButton * _FireButton;
@property (nonatomic, retain) IBOutlet RoundButton * _WindButton;
@property (nonatomic, retain) IBOutlet UIButton * _NextButton;

@property (nonatomic, retain) IBOutlet UILabel * _HPLabel;
@property (nonatomic, retain) IBOutlet UILabel * _GunsLabel;
@property (nonatomic, retain) IBOutlet UILabel * _SoldiersLabel;

@property (nonatomic, retain) IBOutlet UILabel * _MPLabel;
@property (nonatomic, retain) IBOutlet UILabel * _TPLabel;
@property (nonatomic, retain) IBOutlet UILabel * _SpeedLabel;

@property (nonatomic, retain) IBOutlet UILabel * _ConsoleTypeLabel;

@property (nonatomic, retain) IBOutlet AmmoChooserView * _AmmoChooser;

@property (nonatomic, assign) bool _isHidden;
@property (nonatomic, readonly) bool _isHiding;

- (IBAction) FireButtonGO:(id) sender;
- (IBAction) OptionsButtonGO:(id) sender;
- (IBAction) NextOrEndGO:(id) sender;

- (IBAction) handleShotButtons:(id) sender;

- (void) setAmmoChooserStateTo:(AmmoChooserUIState) acuis;
- (void) setSelectedAmmoTypeTo:(AmmunitionType) at;

/* Set ship data, the not so often changing part */
- (void) setShipDataHP:(int) hp
				  Guns:(int) guns
			  Soldiers:(int) sol;

/* update the oft changing ship data part */
- (void) updateShipDataMP:(int) mp
					   TP:(int) tp
					Turns:(TurningAbility) ta;

/* called to set next_or_end button mode */
- (void) setTurnEnd:(bool) te;

/* sets the rotation of the compass rose (wind button) */
- (void) setWindDirection:(HexDirection) dir
				 animated:(bool) ani;

/* resets windbutton for usage */
- (void) resetWindButton;

/* resets other buttons for usage */
- (void) resetOtherButtons;

/* prepare for hiding in some time */
- (void) launchAutoHideTimer;

/* perform hiding */
- (void) autoHideByTimer:(NSTimer *) timer;

/* mark end of hiding/unhiding animation */
- (void) hidingDone:(NSString *)animationID
           finished:(NSNumber *)finished
            context:(void *)context;

- (void) displayThisTextOnConsole:(NSString *) text;

@end
