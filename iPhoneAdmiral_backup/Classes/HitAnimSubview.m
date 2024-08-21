//
//  HitAnimSubview.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HitAnimSubview.h"
#import "Ship.h"

#define HIT_ANIM_VIEW_WIDTH 100
#define HIT_ANIM_VIEW_HEIGHT 100

#define CLOUDS_NUMBER       5

#define ANIM_IN_TIME        0.3
#define ANIM_OUT_TIME       1.2

#define CLOUD_ROTATION      (M_PI / 4)
#define CLOUD_SCALE_DOWN    0.5
#define CLOUD_SCALE_UP      1.0

@implementation HitAnimSubview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _Clouds = [[NSMutableArray alloc] initWithCapacity: CLOUDS_NUMBER];
        
        for (int i = 0; i < CLOUDS_NUMBER; i++)
        {
            UIImageView * temp = [[UIImageView alloc] initWithImage:[ UIImage imageNamed:@"GreySmoke.png" ]];
            
            [temp setAlpha: 0.0];
            [temp setTag: i];
            
            [_Clouds addObject: temp];
            [self addSubview: temp];
            
            [temp release];
        }
        
        _CloudRange.location = 0;
        _CloudRange.length = 0;
        
        [self setUserInteractionEnabled: NO];
    }
    return self;
}

/* init with default values */
- (id) initWithDefaultFrame
{
    CGRect frame = CGRectMake(0, 0, HIT_ANIM_VIEW_WIDTH, HIT_ANIM_VIEW_HEIGHT);
    
    return [self initWithFrame: frame];
}

/* places the clouds at appropriate positions */
- (void) prepareWithShip:(Ship *) victim
{
    //position the hit markers
    switch (victim._Type)
    {
        case pinnace:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 6, HIT_ANIM_VIEW_HEIGHT / 2 + 1)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 9, HIT_ANIM_VIEW_HEIGHT / 2)];
            
            _CloudRange.length = 2;
            break;

        case brig:
        case schooner:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 15, HIT_ANIM_VIEW_HEIGHT / 2 + 1)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2     , HIT_ANIM_VIEW_HEIGHT / 2 - 3)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 15, HIT_ANIM_VIEW_HEIGHT / 2 + 3)];
            
            _CloudRange.length = 3;
            break;
            
        case fluyt:
        case galleon:
        case frigate:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 15, HIT_ANIM_VIEW_HEIGHT / 2 + 3)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 5, HIT_ANIM_VIEW_HEIGHT / 2 - 1)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 5, HIT_ANIM_VIEW_HEIGHT / 2 + 1)];
            [[_Clouds objectAtIndex: 3] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 20, HIT_ANIM_VIEW_HEIGHT / 2 - 3)];

            _CloudRange.length = 4;
            break;
            
        case fast_galleon:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 25, HIT_ANIM_VIEW_HEIGHT / 2 + 1)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 10, HIT_ANIM_VIEW_HEIGHT / 2 - 3)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2     , HIT_ANIM_VIEW_HEIGHT / 2 + 5)];
            [[_Clouds objectAtIndex: 3] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 15, HIT_ANIM_VIEW_HEIGHT / 2 - 6)];
            [[_Clouds objectAtIndex: 4] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 25, HIT_ANIM_VIEW_HEIGHT / 2 + 3)];
            
            _CloudRange.length = 5;
            break;
            
        case ship_of_the_line:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 30, HIT_ANIM_VIEW_HEIGHT / 2 + 3)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 15, HIT_ANIM_VIEW_HEIGHT / 2 - 3)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2     , HIT_ANIM_VIEW_HEIGHT / 2 + 7)];
            [[_Clouds objectAtIndex: 3] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 15, HIT_ANIM_VIEW_HEIGHT / 2 - 7)];
            [[_Clouds objectAtIndex: 4] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 30, HIT_ANIM_VIEW_HEIGHT / 2 + 3)];

            _CloudRange.length = 5;
            break;
            
        case small_fort:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 2, HIT_ANIM_VIEW_HEIGHT / 2 + 6)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 7, HIT_ANIM_VIEW_HEIGHT / 2 - 8)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 9, HIT_ANIM_VIEW_HEIGHT / 2 - 7)];
            
            _CloudRange.length = 3;            
            break;

        case med_fort:
        case big_fort:
        case town:
            [[_Clouds objectAtIndex: 0] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 5, HIT_ANIM_VIEW_HEIGHT / 2 + 11)];
            [[_Clouds objectAtIndex: 1] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 - 10, HIT_ANIM_VIEW_HEIGHT / 2 - 8)];
            [[_Clouds objectAtIndex: 2] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 8, HIT_ANIM_VIEW_HEIGHT / 2 - 7)];
            [[_Clouds objectAtIndex: 3] setCenter:CGPointMake(HIT_ANIM_VIEW_WIDTH / 2 + 5, HIT_ANIM_VIEW_HEIGHT / 2 + 2)];
            
            _CloudRange.length = 4;            
            break;
            
        default:
            NSAssert(NO, @"Unrecognized shiptype!");
            break;
    }
    
    //rotate to place
    self.transform = CGAffineTransformMakeRotation(victim._Course * 60 * M_PI / 180);
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
    [UIView setAnimationDidStopSelector:@selector(animFinished:finished:context:)];
    [UIView setAnimationDuration: ANIM_IN_TIME];
    
    for (UIImageView * uiv in [_Clouds subarrayWithRange: _CloudRange])
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(CLOUD_ROTATION);
        uiv.transform = CGAffineTransformScale(trans, CLOUD_SCALE_UP, CLOUD_SCALE_UP);
    }
    
    [UIView commitAnimations];

}

/* fades out the clouds */
- (void) animFinished:(NSString *)animationID
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
