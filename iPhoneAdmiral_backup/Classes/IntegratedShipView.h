//
//  IntegratedShipView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

#define NOTIF_NAME_BOARDING_BREAKUP @"Breakup_boarding_with_following_ID"

/*
 Integrated Ship Subview
 
 The goal of this view is to provide unified interface to MapView for all ship manipulation,
 combining all of the features that got added to the game overtime.
 
 This view will handle navigation animations - turning and moving,
 Also fire-on-fire animation will be included here.
 ShipHealthView will be it's subview;
 
 It will also readily provide information on course and position (by using center property).
 
 Tag property will match the previous Tags, i.e. it will be the method used by MapView to
 identify required shipview;
 
*/

@class Ship;
@class ShipHealthView;
@class FireAnimSubview;
@class UIDmgNfo;

@interface IntegratedShipView : UIView 
{
    ShipHealthView  * _MyHealthView;
    FireAnimSubview * _MyFireView;
    UIImageView     * _MyShipImage;
    
    HexDirection _MyCourse;
}

//for fast information on how to apply firing/hit/miss animation
@property (nonatomic, readonly) HexDirection _MyCourse;

//initialization
- (id) initWithShip:(Ship *) ship;

//navigation
//passing ship selector pointer is required to syncronize animations
- (void) animateMoveTo:(CGPoint) destination
       completionBlock:(CompletionBlock_t) comp_block;

- (void) animateTurn:(TurnDirection) td
     completionBlock:(CompletionBlock_t) comp_block;

- (void) undoShipCourseTo:(HexDirection) hd;

//damage
- (void) animateDamageWithUiDmgNfo:(UIDmgNfo *) uidmg;

//these two are meant as private
- (void) updateFireSizeTo:(FireSize) fs;

- (void) animateSinking;

@end
