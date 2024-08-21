//
//  ShootingAnimSubview.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShootingAnimSubview.h"
#import "Ship.h"

#define CLOUDS_MAX_NUMBER   4
#define SHOOT_VIEW_WIDTH    100
#define SHOOT_VIEW_HEIGHT   100

#define ANIM_IN_TIME        0.8
#define ANIM_OUT_TIME       1.2

#define CLOUD_ROTATION      (M_PI / 4)
#define CLOUD_SCALE_DOWN    0.5
#define CLOUD_SCALE_UP      1.0

@implementation ShootingAnimSubview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _Clouds = [[NSMutableArray alloc] initWithCapacity: CLOUDS_MAX_NUMBER];
    
        for (int i = 0; i < CLOUDS_MAX_NUMBER; i++)
        {
            UIImageView * temp = [[UIImageView alloc] initWithImage:[ UIImage imageNamed:@"WhiteSmoke.png" ]];
            
            [temp setAlpha: 0.0];
            [temp setTag: i];
            
            [_Clouds addObject: temp];
            [self addSubview: temp];
            
            [temp release];
            
            _CloudRange.location = 0;
            _CloudRange.length = 0;
        }

        [self setUserInteractionEnabled:NO];
        
    }
    return self;
}

/* the default setup method */
- (id) initWithDefaultFrame
{
    CGRect frame = CGRectMake(0, 0, SHOOT_VIEW_WIDTH, SHOOT_VIEW_HEIGHT);
    
    return [self initWithFrame:frame];
}

/* prepares appropriate number of clouds at their starting positions*/
- (void) prepareWithShip:(Ship *) striker
               firingArc:(FiringArc) firearc
{
    //parameter to offset cluods on firing arc selection
    int ship_width;
    
    //adjust sizes and initial positions (as if ship is heading LEFT)
    switch (striker._Type)
    {
        case pinnace:
            _CloudRange.length = 1;
            
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 2, SHOOT_VIEW_HEIGHT / 2)];
            
            ship_width = 7;
            break;
            
        case brig:
        case schooner:
            _CloudRange.length = 2;

            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 8, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 8, SHOOT_VIEW_HEIGHT / 2)];
            
            ship_width = 10;
            break;

            
        case fluyt:
            _CloudRange.length = 2;
            
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 2, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 16, SHOOT_VIEW_HEIGHT / 2)];
            
            ship_width = 10;
            break;

        case galleon:
            _CloudRange.length = 3;

            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 12, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 12, SHOOT_VIEW_HEIGHT / 2)];

            ship_width = 14;
            break;

        case fast_galleon:
        case frigate:
            _CloudRange.length = 3;

            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 12, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 12, SHOOT_VIEW_HEIGHT / 2)];

            ship_width = 10;
            break;

        case ship_of_the_line:
            _CloudRange.length = 4;

            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 21, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 8, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 8, SHOOT_VIEW_HEIGHT / 2)];
            [[_Clouds objectAtIndex: 3] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 21, SHOOT_VIEW_HEIGHT / 2)];
            ship_width = 14;

            break;
            
        case small_fort:
        case med_fort:
        case big_fort:
            _CloudRange.length = 4;
            
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 16, SHOOT_VIEW_HEIGHT / 2 + 6)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 - 16, SHOOT_VIEW_HEIGHT / 2 - 6)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 16, SHOOT_VIEW_HEIGHT / 2 + 6)];
            [[_Clouds objectAtIndex: 3] setCenter:CGPointMake(SHOOT_VIEW_WIDTH / 2 + 16, SHOOT_VIEW_HEIGHT / 2 - 6)];
            
            ship_width = 0;
            break;
            
        default:
            NSAssert(NO, @"Unrecognized shiptype!");
            break;
    }
    
    //modify the centers according to firing arc
    if (firearc == ArcLeft)
    {
        for (UIImageView * uiv in [_Clouds subarrayWithRange:_CloudRange])
        {
            [uiv setCenter:CGPointMake(uiv.center.x, uiv.center.y + ship_width) ];
        }
    }
    else
    {
        for (UIImageView * uiv in [_Clouds subarrayWithRange:_CloudRange])
        {
            [uiv setCenter:CGPointMake(uiv.center.x, uiv.center.y - ship_width) ];
        }
    }
        
    //rotate the view to match the ship's course
    self.transform = CGAffineTransformMakeRotation(striker._Course * 60 * M_PI / 180);
    
}

/* performs the prepared animation */
- (void) performAnimation
{    
    for (UIImageView * uiv in [_Clouds subarrayWithRange:_CloudRange])
    {
        uiv.transform = CGAffineTransformMakeScale(CLOUD_SCALE_DOWN, CLOUD_SCALE_DOWN);
        [uiv setAlpha:1.0];
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(shootingFinished:finished:context:)];
    [UIView setAnimationDuration: ANIM_IN_TIME];

    for (UIImageView * uiv in [_Clouds subarrayWithRange: _CloudRange])
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(CLOUD_ROTATION);
        uiv.transform = CGAffineTransformScale(trans, CLOUD_SCALE_UP, CLOUD_SCALE_UP);
    }
    
    [UIView commitAnimations];
}

/* cleans after animation */
- (void) shootingFinished:(NSString *)animationID
				 finished:(NSNumber *)finished
				  context:(void *)context
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: ANIM_OUT_TIME];

    for (UIImageView * uiv in [_Clouds subarrayWithRange: _CloudRange])
    {
        [uiv setAlpha:0.0];
    }
    
    [UIView commitAnimations];
}

- (void)dealloc
{
    [_Clouds release];
    
    [super dealloc];
}

@end
