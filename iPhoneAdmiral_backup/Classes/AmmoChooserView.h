//
//  AmmoChooserView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface AmmoChooserView : UIImageView
{
	UIButton * _RoundShotButton;
	UIButton * _ChainShotButton;
	UIButton * _GrapeShotButton;
	
    UIImageView * _SelectedShotIcon;
    
	AmmoChooserUIState _MyState;
    
    bool _Animating;
}

@property (nonatomic, retain) IBOutlet UIButton * _RoundShotButton;
@property (nonatomic, retain) IBOutlet UIButton * _ChainShotButton;
@property (nonatomic, retain) IBOutlet UIButton * _GrapeShotButton;
@property (nonatomic, retain) IBOutlet UIImageView * _SelectedShotIcon;

- (void) setToHidden;

- (void) setToIconOnly;

- (void) setToVisible;

- (void) setVisibilityTo:(AmmoChooserUIState) uistate;

- (void) setSelectedAmmoTypeTo:(AmmunitionType) at;

@end
