//
//  BoardingActionInfo.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if 0
//this was supposed to be somethink like uidmg info class, but ultimately it wasn't needed

@class DamadgeInfo;
@class BoardingAction;

typedef enum
{
	BoardingCreated,
	BoardingContinues,
	BoardingFinished,
} BoardingState;

@interface BoardingActionInfo : NSObject 
{
	int _BoardingID;
	
	BoardingState _BoardingState;
	
	int _ShipA_row;
	int _ShipA_hrw;
	int _ShipB_row;
	int _ShipB_hrw;
	
	DamadgeInfo * _RedDamadge;
	DamadgeInfo * _BlueDamadge;
	
	bool _SomethingSunk;
	
	NSSet * _IDsToDrop;
}

@property (nonatomic, readonly) int _BoardingID;

@property (nonatomic, readonly) int _ShipA_row;
@property (nonatomic, readonly) int _ShipA_hrw;
@property (nonatomic, readonly) int _ShipB_row;
@property (nonatomic, readonly) int _ShipB_hrw;

@property (nonatomic, readonly) DamadgeInfo * _RedDamadge;
@property (nonatomic, readonly) DamadgeInfo * _BlueDamadge;

@property (nonatomic, assign) bool _SomethingSunk;
@property (nonatomic, assign) BoardingState _BoardingState;
@property (nonatomic, retain) NSSet * _IDsToDrop;


- (id) initWithBoardingAction:(BoardingAction *) ba;

@end

#endif
