//
//  ShipHealthView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class Ship;

typedef enum
{
	HPPos_Below,
	HPPos_Left,
	HPPos_Right,	
} HPBarPosition;

@interface ShipHealthView : UIView 
{
	NSMutableArray * _HPSubviews;
	
	HPBarPosition _HPBarPosition;
	
	double _AnimationTime;
	
	UIImageView * _SpecialIcon;
	
	int _CurrentHP;
	int _NewHP;
}

- (id) initWithShip:(Ship *) ship;

- (CGPoint) calculateCenterFor:(int) hp_blip_num
                    totalBlips:(int) hp_blip_total
               withSpecialIcon:(bool) spi
                   bigSizeShip:(bool) big;

//prepare hp bar for changes by informing it of the new HP value
- (void) updateShipHPBy:(int) hp_loss;

//animate the hp bar to match the new hp value
- (void) animateHPChange:(double) animDuration;

//set HP bar position for supplied course
- (void) setHPBarPositionForCourse:(HexDirection) course;

//rotate the HP bar to appropriate position
- (void) rotateHPBarToPosition;

@end
