//
//  UIBoardingNfo.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIBoardingNfo.h"
#import "Ship.h"
#import "Hex.h"

@implementation UIBoardingNfo

@synthesize _BoardingID, _BoardingState, shipA_row, shipA_hrw, shipB_row, shipB_hrw;

- (id) initWithID:(int) bid
			shipA:(Ship *) sha
			shipB:(Ship *) shb
{
	_BoardingID = bid;
	_BoardingState = BoardingCreated;
	
	shipA_row = sha._CurrentHex._Row;
	shipA_hrw = sha._CurrentHex._HexInRow;
	shipB_row = shb._CurrentHex._Row;
	shipB_hrw = shb._CurrentHex._HexInRow;
	
	return self;
}

- (id) initWithID:(int) bid
{
	_BoardingID = bid;
	_BoardingState = BoardingFinished;

	return self;	
}


@end
