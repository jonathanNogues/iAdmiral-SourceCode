//
//  TutorialsAndInstructionsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DQReadyControl;

@interface TutorialsAndInstructionsView : UIImageView {
    DQReadyControl * _AvailableTutorialsLabel;
    DQReadyControl * _AdmiralopediaControl;
    DQReadyControl * _BackControl;
    
    DQReadyControl * _Tutorial1Control;
    DQReadyControl * _Tutorial2Control;
    DQReadyControl * _Tutorial3Control;
    DQReadyControl * _Tutorial4Control;
}

@property (nonatomic, retain) IBOutlet DQReadyControl * _AvailableTutorialsLabel;
@property (nonatomic, retain) IBOutlet DQReadyControl * _AdmiralopediaControl;
@property (nonatomic, retain) IBOutlet DQReadyControl * _BackControl;

@property (nonatomic, retain) IBOutlet DQReadyControl * _Tutorial1Control;
@property (nonatomic, retain) IBOutlet DQReadyControl * _Tutorial2Control;
@property (nonatomic, retain) IBOutlet DQReadyControl * _Tutorial3Control;
@property (nonatomic, retain) IBOutlet DQReadyControl * _Tutorial4Control;

- (IBAction) handleTutorialButtons:(id) sender;

- (IBAction) handleAdmiralopedia:(id) sender;

- (IBAction) handleDone:(id) sender;

- (void) tutorialPlaybackComplete:(NSNotification *) notification;

@end
