//
//  UIDmgNfo.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class DamadgeInfo;

@interface UIDmgNfo : NSObject 
{
	NSMutableArray * _MSGs;
	int _DamadgedShipID;
    
    bool _FatalDamage;
    
    int _HPLoss;
    bool _fireUpdateNeeded;
	FireSize _VictimFireNow;
}

@property (nonatomic, readonly) NSMutableArray * _MSGs;
@property (nonatomic, readonly) int _DamadgedShipID;

@property (nonatomic, readonly) bool _FatalDamage;

@property (nonatomic, readonly) bool _fireUpdateNeeded;
@property (nonatomic, readonly) FireSize _VictimFireNow;
@property (nonatomic, readonly) int _HPLoss;

- (id) initWithDamadgeInfo:(DamadgeInfo *) dmginf;

@end
