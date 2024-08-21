//
//  FireAnimSubview.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FireAnimSubview.h"
#import "Ship.h"

@implementation FireAnimSubview

#define VIEW_WIDTH 80.0
#define VIEW_HEIGHT 40.0

//initialize with ship
- (id) initWithCourse:(HexDirection) course
                 Size:(FireSize) size
{
    CGRect defaultframe = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
    
    self = [super initWithFrame:defaultframe];
        
    UIImage * black_smoke = [UIImage imageNamed:@"BlackSmoke.png"];
        
    UIImageView * _FireStern = [[UIImageView alloc] initWithImage: black_smoke];
    [_FireStern setCenter:CGPointMake(VIEW_WIDTH / 2 + 20.0, VIEW_HEIGHT / 2)];
    [_FireStern setAlpha:0.0];
    [self addSubview:_FireStern];
    
    UIImageView * _FireBow = [[UIImageView alloc] initWithImage: black_smoke];
    [_FireBow setCenter:CGPointMake(VIEW_WIDTH / 2 - 20.0, VIEW_HEIGHT / 2)];
    [_FireBow setAlpha:0.0];
    [self addSubview:_FireBow];
    
    UIImageView * _FireAmidships = [[UIImageView alloc] initWithImage: black_smoke];
    [_FireAmidships setCenter:CGPointMake(VIEW_WIDTH / 2, VIEW_HEIGHT / 2)];
    [_FireAmidships setAlpha:0.0];
    [self addSubview:_FireAmidships];
    
    //save fires for later manipulation
    _FiresOnBoard = [[NSArray alloc] initWithObjects: _FireStern, _FireBow, _FireAmidships, nil];
    [_FireStern release];
    [_FireBow release];
    [_FireAmidships release];
    
    //set orientation
    self.transform = CGAffineTransformMakeRotation(course * 60 * M_PI / 180);

    //start animation
    [self updateToFireSize:size];
    
    return self;
}

//update to new fire size
- (void) updateToFireSize:(FireSize) newsize
{
    NSRange active_fire_range;
    active_fire_range.location = 0;
    active_fire_range.length = newsize;
    
    NSArray * active_fires = [_FiresOnBoard subarrayWithRange:active_fire_range];

    //stop animations
    [self stopAnimating];
    
    //prepare for animation
    for (UIImageView * uiv in active_fires)
    {
        //prepare for animation (scale down)
        uiv.transform = CGAffineTransformMakeScale(0.3, 0.3);
        uiv.alpha = 0.3;
    }
    
    //launch new animations
    [UIView animateWithDuration:3.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat
                     animations:
                        ^{
                            for (UIImageView * fire_view in active_fires)
                            {
                                //fade in
                                fire_view.alpha = 1.0;
                                
                                //back to normal size
                                CGAffineTransform trans = CGAffineTransformMakeScale(0.9, 0.9);

                                //rotate
                                fire_view.transform = CGAffineTransformRotate(trans, M_PI);
                            }
                        }
                     completion:nil];
}

//zap all animations
- (void) stopAnimating
{
    for (UIImageView * uiv in _FiresOnBoard)
    {
        [[uiv layer] removeAllAnimations];
        [uiv setAlpha:0.0];
    }
}


- (void)dealloc
{
    [self stopAnimating];
    
    [_FiresOnBoard release];
    
    [super dealloc];
}

@end
