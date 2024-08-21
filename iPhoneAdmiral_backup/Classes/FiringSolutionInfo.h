//
//  FiringSolutionInfo.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

/*
 class for storing information on firing,
 that will be used by the mapview for setting
 up animations.
 */


@interface FiringSolutionInfo : NSObject 
{
    int _StrikerID;
    int _VictimID;
    
    bool _FiringSuccesfull;
    bool _DamageDealt;
    
    int _Distance;
    FiringArc _FiringArc;
    NSString * _Reason;
}

@property (nonatomic, assign) int _StrikerID;
@property (nonatomic, assign) int _VictimID;

@property (nonatomic, assign) bool _FiringSuccesfull;
@property (nonatomic, assign) bool _DamageDealt;

@property (nonatomic, assign) int _Distance;
@property (nonatomic, assign) FiringArc _FiringArc;
@property (nonatomic, assign) NSString * _Reason;


@end
