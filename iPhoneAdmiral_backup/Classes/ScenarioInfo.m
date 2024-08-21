//
//  ScenarioInfo.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScenarioInfo.h"


@implementation ScenarioInfo

@synthesize _ScenarioName;
@synthesize _MapFileName;
@synthesize _MiniatureImageName;
@synthesize _ScenarioDescription;

- (id) initWithCoder:(NSCoder *) coder
{
	self = [super init];
	
	_ScenarioName = [[coder decodeObjectForKey:@"_ScenarioName"] retain];
	_MapFileName = [[coder decodeObjectForKey:@"_MapFileName"] retain];
	_MiniatureImageName = [[coder decodeObjectForKey:@"_MiniatureImageName"] retain];
	_ScenarioDescription = [[coder decodeObjectForKey:@"_ScenarioDescription"] retain];	
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
	[coder encodeObject:_ScenarioName forKey:@"_ScenarioName"];
	[coder encodeObject:_MapFileName forKey:@"_MapFileName"];
	[coder encodeObject:_MiniatureImageName forKey:@"_MiniatureImageName"];
	[coder encodeObject:_ScenarioDescription forKey:@"_ScenarioDescription"];	
}

@end
