//
//  ScenarioInfo.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScenarioInfo : NSObject <NSCoding>
{
	NSString * _ScenarioName;
	NSString * _MapFileName;
	NSString * _MiniatureImageName;
	
	NSString * _ScenarioDescription;
}

@property (nonatomic, retain) NSString * _ScenarioName;
@property (nonatomic, retain) NSString * _MapFileName;
@property (nonatomic, retain) NSString * _MiniatureImageName;
@property (nonatomic, retain) NSString * _ScenarioDescription;

@end
