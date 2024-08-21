//
//  ShipSelectorView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundButton;
@class MapView;
@class Ship;

@interface ShipSelectorView : UIView {
	UIImageView * _SelectorRing;
	
	RoundButton * _GoButton;
	RoundButton * _TurnLeftButton;
	RoundButton * _TurnRightButton;
	RoundButton * _AnchorButton;
	
	UIImageView * _LeftFiringArc;
	UIImageView * _RightFiringArc;
    UIImageView * _FortFiringArc;
}

/* init with default values for everything */
- (id) initWithMapViewPointer:(MapView *) pMap;

/* adjusts the positions of icons for large ships */
- (void) adjustIconPositionForShip:(Ship *) selectee;

/* set visibility and accesibility of different navigation elements */
- (void) setVisibilityForSelector:(bool) sel_vis
						 goButton:(bool) go_vis
						 tlButton:(bool) tl_vis
						 trButton:(bool) tr_vis
					 anchorButton:(bool) anc_vis;

/* set visibility of different combat aid elements */
- (void) setVisibilityForSelector:(bool) sel_vis
					leftFiringArc:(bool) larc_vis
				   rightFiringArc:(bool) rarc_vis
                    fortFiringArc:(bool) farc_vis;

@end
