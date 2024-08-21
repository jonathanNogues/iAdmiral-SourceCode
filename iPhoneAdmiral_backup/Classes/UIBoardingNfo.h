//
//  UIBoardingNfo.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ship;

typedef enum
{
	BoardingCreated,
	BoardingContinues,
	BoardingFinished,
} BoardingState;

@interface UIBoardingNfo : NSObject 
{
	int _BoardingID;
		
	BoardingState _BoardingState;
	
	int shipA_row;
	int shipA_hrw;
	
	int shipB_row;
	int shipB_hrw;
}

@property (nonatomic, readonly) int _BoardingID;
@property (nonatomic, readonly) BoardingState _BoardingState;
@property (nonatomic, readonly) int shipA_row;
@property (nonatomic, readonly) int shipA_hrw;
@property (nonatomic, readonly) int shipB_row;
@property (nonatomic, readonly) int shipB_hrw;

- (id) initWithID:(int) bid
			shipA:(Ship *) sha
			shipB:(Ship *) shb;

- (id) initWithID:(int) bid; 

@end
