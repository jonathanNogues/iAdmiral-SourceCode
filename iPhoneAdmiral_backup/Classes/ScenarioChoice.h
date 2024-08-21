//
//  ScenarioChoice.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScenarioChoice : NSObject 
{
    NSString *  _MapFileName;
    bool        _AutoSave;
    bool        _Multiplayer;
}

@property (nonatomic, retain) NSString * _MapFileName;
@property (nonatomic, assign) bool _AutoSave;
@property (nonatomic, assign) bool _Multiplayer;

@end
