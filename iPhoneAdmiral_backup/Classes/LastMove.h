//
//  LastMove.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class Ship;
@class Hex;

@interface LastMove : NSObject 
{
	Ship * _ship;					//whom to move
    int _MPCost;                    //restore this many MPs
    int _NTurns;                    //restore number of turns to this
	Hex * _originalHex;				//move back here
	HexDirection _originalCourse;	//set this course
	
	//beaching and boarding should not be cancellable i think - maybe add some warning before
	//allowing the ui to order this move.
}

@property (nonatomic, assign) Ship * _ship;
@property (nonatomic, assign) int _MPCost;
@property (nonatomic, assign) int _NTurns;
@property (nonatomic, assign) Hex * _originalHex;
@property (nonatomic, assign) HexDirection _originalCourse;


//undoes last move, and returns ship id so the interface knows whom to move
- (Ship *) undoMove;

@end
