//
//  OptionsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundButton;
@class MapView;

@interface OptionsView : UIImageView {
	RoundButton * _UndoButton;
	RoundButton * _ForceEndTurn;
	RoundButton * _SaveButton;
	RoundButton * _ExitButton;
    RoundButton * _TerrainViewButton;
	
	MapView * _pMapView;
}

@property (nonatomic, assign) MapView * _pMapView;

- (void) handleUndoButton;
- (void) handleForceEndTurn;
- (void) handleSaveButton;
- (void) handleExitButton;
- (void) handleTerrainViewButton;

@end
