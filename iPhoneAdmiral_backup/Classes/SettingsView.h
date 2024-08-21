//
//  SettingsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DQReadyControl;

@interface SettingsView : UIImageView 
{    
    DQReadyControl * _iAdmiralLabel1;
    DQReadyControl * _iAdmiralLabel2;
    DQReadyControl * _iAdmiralSettingsLabel;
    
    DQReadyControl * _MusicLabel;
    DQReadyControl * _SoundLabel;
    DQReadyControl * _IAHLabel;
    DQReadyControl * _RealismLabel;
    
    DQReadyControl * _MusicControl;
    DQReadyControl * _SoundControl;
    DQReadyControl * _IAHControl;
    DQReadyControl * _RealismControl;
    
    DQReadyControl * _BackControl;
}

@property (nonatomic, retain) IBOutlet DQReadyControl * _iAdmiralLabel1;
@property (nonatomic, retain) IBOutlet DQReadyControl * _iAdmiralLabel2;
@property (nonatomic, retain) IBOutlet DQReadyControl * _iAdmiralSettingsLabel;

@property (nonatomic, retain) IBOutlet DQReadyControl * _MusicLabel;
@property (nonatomic, retain) IBOutlet DQReadyControl * _SoundLabel;
@property (nonatomic, retain) IBOutlet DQReadyControl * _IAHLabel;
@property (nonatomic, retain) IBOutlet DQReadyControl * _RealismLabel;

@property (nonatomic, retain) IBOutlet DQReadyControl * _MusicControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _SoundControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _IAHControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _RealismControl;

@property (nonatomic, retain) IBOutlet DQReadyControl * _BackControl;

- (void) setup;

- (void) handleControl:(id) sender;

- (void) handleBack:(id) sender;

@end
