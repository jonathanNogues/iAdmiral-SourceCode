//
//  ShipHealthView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ShipHealthView.h"
#import "Ship.h"

#define VIEW_WIDTH			50.0
#define VIEW_HEIGTH			50.0

#define DOTS_RADIUS_SMALL	18.0
#define DOTS_RADIUS_NORM	25.0

#define DOTS_DEGREE_SMALL	19.0
#define DOTS_DEGREE_NORM	13.0

@implementation ShipHealthView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id) initWithShip:(Ship *) ship
{
	CGRect defaultFrame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGTH);
	
	self = [super initWithFrame: defaultFrame];
	
	//no user ineractions, just display so it does not interfere with nav icons
	[self setUserInteractionEnabled:NO];
	
	_CurrentHP = ship._HitPointsLeft;
	_NewHP = _CurrentHP;
	
	CGFloat radius;
	if (ship._BigShip)
	{
		radius = DOTS_RADIUS_NORM;
	}
	else 
	{
		radius = DOTS_RADIUS_SMALL;
	}	
	
	_HPSubviews = [[NSMutableArray alloc] initWithCapacity:_CurrentHP];
			
	NSString * dot_name;
	
	if (ship._Side == RedSide) dot_name = @"green_dot.png";
	else dot_name = @"red_dot.png";
	
    //NSLog(@"Calculating hp blips positions for %@", ship);
    
	for (int i = 0; i < _CurrentHP; i++)
	{
		UIImageView * dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dot_name]];
		
        CGPoint dot_center = [self calculateCenterFor: i
                                           totalBlips: _CurrentHP
#ifdef SPECIAL_AI_MARKERS
                                      withSpecialIcon: (ship._IAmCargoShip || ship._IAmFlagship || ship._Sentinel || ship._HunterKiller || ship._IAmPriorityTarget)
#else
                                      withSpecialIcon: (ship._IAmCargoShip || ship._IAmFlagship || ship._IAmPriorityTarget)
#endif
                                          bigSizeShip: ship._BigShip ];
        
		dot.center = dot_center;
		[self addSubview:dot];
		[_HPSubviews addObject:dot];
        
        [dot release];
	}
    
    NSString * specialIconName = nil;
    
    if (ship._IAmFlagship) specialIconName = @"FlagIcon.png";
	if (ship._IAmCargoShip) specialIconName = @"BarrellIcon.png";
    if (ship._IAmPriorityTarget) specialIconName = @"TargetIcon.png";
    
#ifdef SPECIAL_AI_MARKERS
    if (ship._HunterKiller) specialIconName = @"skullicon.png";
    if (ship._Sentinel) specialIconName = @"Shield.png";
#endif
    
    if (specialIconName != nil)
    {
		_SpecialIcon = [[UIImageView alloc] initWithImage: [UIImage imageNamed:specialIconName]];
		CGFloat x = VIEW_WIDTH / 2;
		CGFloat y = VIEW_HEIGTH / 2 + radius;
		
		_SpecialIcon.center = CGPointMake(x, y);
		[self addSubview:_SpecialIcon];
    }

	//set appropriate position
	if (ship._Type == town) 
        [self setHPBarPositionForCourse: LEFT];
    else 
        [self setHPBarPositionForCourse: ship._Course];
    
    //rotate
	[self rotateHPBarToPosition];	
	
	return self;
}

- (CGPoint) calculateCenterFor:(int) hp_blip_num
                    totalBlips:(int) hp_blip_total
               withSpecialIcon:(bool) spi
                   bigSizeShip:(bool) big
{
    CGFloat blip_radius, blip_angle_dist;
    int cutoff = 8;
    
    if (big)
    {
        blip_radius = DOTS_RADIUS_NORM;
        blip_angle_dist = DOTS_DEGREE_NORM;
    }
    else
    {
        blip_radius = DOTS_RADIUS_SMALL;
        blip_angle_dist = DOTS_DEGREE_SMALL;
        if (spi) cutoff = 4;
    }
        
    //calculate first blips degree
    CGFloat this_blip_degree, coefficient = 1.0;

    if (hp_blip_num % 2 == 1) coefficient = -1.0;
    
    if (hp_blip_num < cutoff)
    {                
        //calculate blip distance
        this_blip_degree = 180.0 + ((hp_blip_num / 2) * blip_angle_dist * coefficient);
        
        //initial offset
        this_blip_degree += (blip_angle_dist * 0.6) * coefficient;

        //take special icons into accout
        if (spi) this_blip_degree += 1.0 * blip_angle_dist * coefficient;
    }
    else
    {
        blip_radius = blip_radius - 6.5;
        blip_angle_dist = blip_angle_dist * 1.4;
        
        hp_blip_num = hp_blip_num - cutoff;
        
        this_blip_degree = 180.0 + ((hp_blip_num / 2) * blip_angle_dist * coefficient);
        
        //initial offset
        this_blip_degree += (blip_angle_dist * 0.6) * coefficient;
    }
    
    
    CGFloat x = VIEW_WIDTH/2 + sin(this_blip_degree * M_PI / 180) * blip_radius;
    CGFloat y = VIEW_HEIGTH/2 - cos(this_blip_degree * M_PI / 180) * blip_radius;
    
    //NSLog(@"%d/%d: (%f, %f)", hp_blip_num, hp_blip_total, x, y);
    
    return CGPointMake(x, y);
}

- (void) setHPBarPositionForCourse:(HexDirection) course
{
	switch(course)
	{
		case LEFT:
		case RIGHT:
			_HPBarPosition = HPPos_Below;
			break;
			
		case LEFT_UP:
		case RIGHT_DOWN:
			_HPBarPosition = HPPos_Left;
			break;
			
		case LEFT_DOWN:
		case RIGHT_UP:
			_HPBarPosition = HPPos_Right;
			break;
            
        case DIRECTION_MAX:
            default:
            NSLog(@"WARNING: something fishy is going on!");
            break;
	}
}

- (void) rotateHPBarToPosition
{
	switch (_HPBarPosition)
	{
		case HPPos_Below:
			_SpecialIcon.transform = CGAffineTransformMakeRotation( 0 * M_PI / 180);
			self.transform = CGAffineTransformMakeRotation( 0 * M_PI / 180);
			break;
			
		case HPPos_Left:
			_SpecialIcon.transform = CGAffineTransformMakeRotation( 300 * M_PI / 180);			
			self.transform = CGAffineTransformMakeRotation( 60 * M_PI / 180);
			break;
			
		case HPPos_Right:
			_SpecialIcon.transform = CGAffineTransformMakeRotation( 60 * M_PI / 180);
			self.transform = CGAffineTransformMakeRotation( 300 * M_PI / 180);
			break;
	}
}


- (void) updateShipHPBy:(int) hp_loss;
{
	NSLog(@"SHV: updateShipHPTo: Run!");
	_NewHP = _CurrentHP - hp_loss;
}

- (void) animateHPChange:(double) animDuration
{
    NSRange blips_to_drop;
    blips_to_drop.length = -(_NewHP - _CurrentHP);
    blips_to_drop.location = _CurrentHP - blips_to_drop.length;
    
    NSArray * blips = [_HPSubviews subarrayWithRange:blips_to_drop];
    
    //NSLog(@"Range: loc: %d; len: %d; subarray count: %d", blips_to_drop.location, blips_to_drop.length, [blips count]);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(blipsRemoved:finished:context:)];
    [UIView setAnimationDuration: 1.5];
    
    for (UIImageView * uiv in blips) [uiv setAlpha:0.0]; 
    if (_NewHP == 0) [_SpecialIcon setAlpha:0.0];
    
    [UIView commitAnimations];
}

- (void) blipsRemoved:(NSString *)animationID
             finished:(NSNumber *)finished
              context:(void *)context
{
    NSRange blips_to_drop;
    blips_to_drop.length = -(_NewHP - _CurrentHP);
    blips_to_drop.location = _CurrentHP - blips_to_drop.length;
    
    [_HPSubviews removeObjectsInRange:blips_to_drop];
    
    //update hp
    _CurrentHP = _NewHP;
}

- (void)dealloc 
{
    //should prevent crashes on ship sinking...
    [[self layer] removeAllAnimations];
    for (CALayer * sublayer in [[self layer] sublayers]) [sublayer removeAllAnimations];
    
	[_HPSubviews release];
	
	[_SpecialIcon release];

    [super dealloc];
}


@end
