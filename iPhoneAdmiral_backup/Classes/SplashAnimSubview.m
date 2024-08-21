//
//  SplashAnimSuview.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SplashAnimSubview.h"

#import "Ship.h"

#define MISS_ANIM_VIEW_WIDTH 100
#define MISS_ANIM_VIEW_HEIGHT 100

#define SPLASH_NUMBER       10

#define ANIM_IN_TIME        0.4
#define ANIM_OUT_TIME       0.4

#define SPLASH_SCALE_DOWN    0.5
#define SPLASH_SCALE_UP      1.0

@implementation SplashAnimSubview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {

        _Splashes = [[NSMutableArray alloc] initWithCapacity: SPLASH_NUMBER];
        
        for (int i = 0; i < SPLASH_NUMBER; i++)
        {
            UIImageView * temp = [[UIImageView alloc] initWithImage:[ UIImage imageNamed:@"Splash.png" ]];
            
            [temp setAlpha: 0.0];
            [temp setTag: i];
            
            [_Splashes addObject: temp];
            [self addSubview: temp];
            
            [temp release];
        }
        
        _SplashRange.location = 0;
        _SplashRange.length = 0;
        
        [self setUserInteractionEnabled: NO];
        
    }
    return self;
}

/* init with default values */
- (id) initWithDefaultFrame
{
    CGRect frame = CGRectMake(0, 0, MISS_ANIM_VIEW_WIDTH, MISS_ANIM_VIEW_HEIGHT);
    
    return [self initWithFrame: frame];
}

/* places the splashes at appropriate positions */
- (void) prepareWithShip:(Ship *) victim
            andFirepower:(int) firepow
{
    int normalized_firepow = firepow / 10;
    
    switch (normalized_firepow) 
    {
        case 0:
            _SplashRange.length = 4;
            
            [[_Splashes objectAtIndex: 0] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 30, MISS_ANIM_VIEW_HEIGHT / 2 + 15)];
            [[_Splashes objectAtIndex: 1] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 10, MISS_ANIM_VIEW_HEIGHT / 2 + 25)];
            [[_Splashes objectAtIndex: 2] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 20, MISS_ANIM_VIEW_HEIGHT / 2 + 30)];
            [[_Splashes objectAtIndex: 3] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 5, MISS_ANIM_VIEW_HEIGHT / 2 - 20)];

            break;

        case 1:
            _SplashRange.length = 6;

            [[_Splashes objectAtIndex: 0] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 30, MISS_ANIM_VIEW_HEIGHT / 2 + 15)];
            [[_Splashes objectAtIndex: 1] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 10, MISS_ANIM_VIEW_HEIGHT / 2 + 25)];
            [[_Splashes objectAtIndex: 2] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 20, MISS_ANIM_VIEW_HEIGHT / 2 + 30)];
            [[_Splashes objectAtIndex: 3] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 5, MISS_ANIM_VIEW_HEIGHT / 2 - 20)];
            [[_Splashes objectAtIndex: 4] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 15, MISS_ANIM_VIEW_HEIGHT / 2 - 15)];
            [[_Splashes objectAtIndex: 5] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 15, MISS_ANIM_VIEW_HEIGHT / 2 + 20)];

            break;

        case 2:
            _SplashRange.length = 8;
            
            [[_Splashes objectAtIndex: 0] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 30, MISS_ANIM_VIEW_HEIGHT / 2 + 15)];
            [[_Splashes objectAtIndex: 1] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 10, MISS_ANIM_VIEW_HEIGHT / 2 + 25)];
            [[_Splashes objectAtIndex: 2] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 20, MISS_ANIM_VIEW_HEIGHT / 2 + 30)];
            [[_Splashes objectAtIndex: 3] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 5, MISS_ANIM_VIEW_HEIGHT / 2 - 20)];
            [[_Splashes objectAtIndex: 4] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 15, MISS_ANIM_VIEW_HEIGHT / 2 - 15)];
            [[_Splashes objectAtIndex: 5] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 15, MISS_ANIM_VIEW_HEIGHT / 2 + 20)];
            [[_Splashes objectAtIndex: 6] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 30, MISS_ANIM_VIEW_HEIGHT / 2 - 20)];
            [[_Splashes objectAtIndex: 7] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 5, MISS_ANIM_VIEW_HEIGHT / 2 + 10)];

            break;

        default:    //(3 or more)
            _SplashRange.length = 10;
            
            [[_Splashes objectAtIndex: 0] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 30, MISS_ANIM_VIEW_HEIGHT / 2 + 15)];
            [[_Splashes objectAtIndex: 1] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 10, MISS_ANIM_VIEW_HEIGHT / 2 + 25)];
            [[_Splashes objectAtIndex: 2] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 20, MISS_ANIM_VIEW_HEIGHT / 2 + 30)];
            [[_Splashes objectAtIndex: 3] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 5, MISS_ANIM_VIEW_HEIGHT / 2 - 20)];
            [[_Splashes objectAtIndex: 4] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 15, MISS_ANIM_VIEW_HEIGHT / 2 - 15)];
            [[_Splashes objectAtIndex: 5] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 15, MISS_ANIM_VIEW_HEIGHT / 2 + 20)];
            [[_Splashes objectAtIndex: 6] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 30, MISS_ANIM_VIEW_HEIGHT / 2 - 20)];
            [[_Splashes objectAtIndex: 7] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 5, MISS_ANIM_VIEW_HEIGHT / 2 + 10)];
            [[_Splashes objectAtIndex: 8] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 - 30, MISS_ANIM_VIEW_HEIGHT / 2 - 10)];
            [[_Splashes objectAtIndex: 9] setCenter:CGPointMake(MISS_ANIM_VIEW_WIDTH / 2 + 15, MISS_ANIM_VIEW_HEIGHT / 2 + 10)];            
            
            break;
    }
    
    //rotate to fit
    self.transform = CGAffineTransformMakeRotation(victim._Course * 60 * M_PI / 180);
}

/* performs the prepared animation */
- (void) performAnimation
{
    for (UIImageView * uiv in [_Splashes subarrayWithRange:_SplashRange])
    {
        uiv.transform = CGAffineTransformMakeScale(SPLASH_SCALE_DOWN, SPLASH_SCALE_DOWN);
        [uiv setAlpha:1.0];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(animFinished:finished:context:)];
    [UIView setAnimationDuration: ANIM_IN_TIME];
    
    for (UIImageView * uiv in [_Splashes subarrayWithRange: _SplashRange])
    {
        uiv.transform = CGAffineTransformMakeScale(SPLASH_SCALE_UP, SPLASH_SCALE_UP);
    }
    
    [UIView commitAnimations];
}

/* fades out the splashes */
- (void) animFinished:(NSString *)animationID
             finished:(NSNumber *)finished
              context:(void *)context
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: ANIM_OUT_TIME];
    
    for (UIImageView * uiv in [_Splashes subarrayWithRange: _SplashRange])
    {
        [uiv setAlpha:0.0];
    }
    
    [UIView commitAnimations];
}


- (void)dealloc
{
    [_Splashes release];
    
    [super dealloc];
}

@end
