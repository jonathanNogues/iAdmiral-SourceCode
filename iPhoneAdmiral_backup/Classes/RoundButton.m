//
//  RoundButton.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoundButton.h"

#define SQR(X) (X * X)

@implementation RoundButton

//works ok
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( !CGRectContainsPoint([self bounds], point) ) 
		return nil;
    else 
    {
		//basically we need to check if the 'point' would hit the circle
		//check if distance from point to center is lower than radius
				
		CGFloat center_x = self.frame.size.width / 2;	
		CGFloat center_y = self.frame.size.height / 2;		//should actually be the same,
		
		CGFloat radius = center_x;

		CGFloat distance = sqrt( ((center_x - point.x) * (center_x - point.x)) + 
								 ((center_y - point.y) * (center_y - point.y)) );
		
		//NSLog(@"Radius %f <? %f Distance?\n", radius, distance);
		
		if (radius < distance ) 
		{
			//NSLog(@"Button missed!\n");
			return nil;
		}
    }
	
	//NSLog(@"RoundButton hit!\n");
    return self;
}

@end
