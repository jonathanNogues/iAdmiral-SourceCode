//
//  ShipSelectorView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShipSelectorView.h"
#import "RoundButton.h"
#import "Ship.h"

#define SELECTOR_WIDTH				450.0
#define SELECTOR_HEIGTH				450.0
#define NAVICON_DIST_FROM_CENTER	40.0

#define NAVICON_DIM                 40.0

@implementation ShipSelectorView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/* init with default values for everything */
- (id) initWithMapViewPointer:(MapView *) pMap
{
	CGRect defaultFrame = CGRectMake(0, 0, SELECTOR_WIDTH, SELECTOR_HEIGTH);
	
	self = [self initWithFrame:defaultFrame];
	
	[self setBackgroundColor: [UIColor clearColor]];
	
	//********* SELECTOR RING ***********
	_SelectorRing = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"selector.png"]];
	_SelectorRing.center = CGPointMake(SELECTOR_WIDTH / 2, SELECTOR_HEIGTH / 2);
	_SelectorRing.alpha = 0.0;
	[self addSubview:_SelectorRing];
	
	//********* GO BUTTON ***********
	_GoButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	UIImage * go_image = [UIImage imageNamed:@"go_arrow.png"];
	[_GoButton setFrame:CGRectMake(0, 0, NAVICON_DIM, NAVICON_DIM)];
	[_GoButton setBackgroundImage:go_image forState:UIControlStateNormal & UIControlStateSelected];
	[_GoButton setAlpha:0.0];
	[_GoButton setEnabled:NO];
	[_GoButton addTarget:pMap
				  action:@selector(handleGoButton)
		forControlEvents:UIControlEventTouchUpInside];	
	[_GoButton setCenter: CGPointMake((SELECTOR_WIDTH / 2) - NAVICON_DIST_FROM_CENTER, SELECTOR_HEIGTH / 2)];
	
	[self addSubview:_GoButton];
	
	//********* TURN LEFT BUTTON ***********
	_TurnLeftButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	UIImage * tl_image = [UIImage imageNamed:@"turn_left_arrow.png"];
	[_TurnLeftButton setFrame:CGRectMake(0, 0, NAVICON_DIM, NAVICON_DIM)];
	[_TurnLeftButton setBackgroundImage:tl_image forState:UIControlStateNormal & UIControlStateSelected];
	[_TurnLeftButton setAlpha:0.0];
	[_TurnLeftButton setEnabled:NO];
	[_TurnLeftButton addTarget:pMap
						action:@selector(handleTurnLeftButton)
			  forControlEvents:UIControlEventTouchUpInside];
	[_TurnLeftButton setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2) + NAVICON_DIST_FROM_CENTER)];

	[self addSubview:_TurnLeftButton];
	
	//********* TURN RIGHT BUTTON ***********
	_TurnRightButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	UIImage * tr_image = [UIImage imageNamed:@"turn_right_arrow.png"];
	[_TurnRightButton setFrame:CGRectMake(0, 0, NAVICON_DIM, NAVICON_DIM)];
	[_TurnRightButton setBackgroundImage:tr_image forState:UIControlStateNormal & UIControlStateSelected];
	[_TurnRightButton setAlpha:0.0];
	[_TurnRightButton setEnabled:NO];
	[_TurnRightButton addTarget:pMap
						 action:@selector(handleTurnRightButton)
			   forControlEvents:UIControlEventTouchUpInside];
	[_TurnRightButton setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2) - NAVICON_DIST_FROM_CENTER)];

	[self addSubview:_TurnRightButton];
	
	//********* ANCHOR BUTTON ***********
	_AnchorButton = [RoundButton buttonWithType:UIButtonTypeCustom];
	UIImage * anc_image = [UIImage imageNamed:@"anchor_icon.png"];
	[_AnchorButton setFrame:CGRectMake(0, 0, NAVICON_DIM, NAVICON_DIM)];
	[_AnchorButton setBackgroundImage:anc_image forState:UIControlStateNormal & UIControlStateSelected];
	[_AnchorButton setAlpha:0.0];
	[_AnchorButton setEnabled:NO];
	[_AnchorButton addTarget:pMap
			   action:@selector(handleAnchorButton)
	 forControlEvents:UIControlEventTouchUpInside];
	[_AnchorButton setCenter: CGPointMake((SELECTOR_WIDTH / 2) + NAVICON_DIST_FROM_CENTER, SELECTOR_HEIGTH / 2)];

	[self addSubview:_AnchorButton];
	
	//********* LEFT FIRING ARC ***********
	_LeftFiringArc = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"fire_arc_left_5.png"]]; 
	[_LeftFiringArc setAlpha:0.0];				//hide it initially
	CGFloat fl_y_diff = _LeftFiringArc.frame.size.height / 2 + 12.5;
	[_LeftFiringArc setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2) + fl_y_diff)];
	
	[self addSubview: _LeftFiringArc];			//add as subview

	//********* RIGHT FIRING ARC ***********
	_RightFiringArc = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"fire_arc_right_5.png"]]; 
	[_RightFiringArc setAlpha:0.0];				//hide it initially
	CGFloat fr_y_diff = _RightFiringArc.frame.size.height / 2 + 12.5;
	[_RightFiringArc setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2) - fr_y_diff)];	

	[self addSubview: _RightFiringArc];			//add as subview

    //********* FORT FIRING ARC ***********
	_FortFiringArc = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"fort_fire_arc.png"]]; 
	[_FortFiringArc setAlpha:0.0];				//hide it initially
	[_FortFiringArc setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2))];	
    
	[self addSubview: _FortFiringArc];			//add as subview

	return self;
}

- (void) adjustIconPositionForShip:(Ship *) selectee
{
    CGFloat distance_go_anchor = NAVICON_DIST_FROM_CENTER;
    CGFloat distance_turns = NAVICON_DIST_FROM_CENTER;
    CGFloat scale_x = 1.0;
    CGFloat scale_y = 1.0;
    
    switch (selectee._Type) 
    {
        case brig:
        case pinnace:
        case small_fort:
            break;
            
        case schooner:
            scale_x = 1.05;
            distance_go_anchor = distance_go_anchor * scale_x;
            break;
            
        case fluyt:
        case frigate:
        case galleon:
            scale_x = 1.1;
            distance_go_anchor = distance_go_anchor * scale_x;
            break;
            
        case fast_galleon:
        case ship_of_the_line:
            scale_y = 1.1;
            distance_turns = distance_turns * scale_y;            
            
            scale_x = 1.3;
            distance_go_anchor = distance_go_anchor * scale_x;
            break;

        case med_fort:
        case big_fort:
        case town:
            scale_y = 1.1;
            scale_x = 1.1;
            distance_go_anchor = distance_go_anchor * scale_x;
            break;
            
        default:
            NSAssert(NO, @"Unrecognized shiptype!");
            break;
    }
    
    [_GoButton setCenter: CGPointMake((SELECTOR_WIDTH / 2) - distance_go_anchor, SELECTOR_HEIGTH / 2)];
	[_TurnLeftButton setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2) + distance_turns)];
	[_TurnRightButton setCenter: CGPointMake(SELECTOR_WIDTH / 2, (SELECTOR_HEIGTH / 2) - distance_turns)];
	[_AnchorButton setCenter: CGPointMake((SELECTOR_WIDTH / 2) + distance_go_anchor, SELECTOR_HEIGTH / 2)];
    
    _SelectorRing.transform = CGAffineTransformMakeScale(scale_x, scale_y);
}

/* set visibility and accesibility of different selector elements */
- (void) setVisibilityForSelector:(bool) sel_vis
						 goButton:(bool) go_vis
						 tlButton:(bool) tl_vis
						 trButton:(bool) tr_vis
					 anchorButton:(bool) anc_vis
{
	if (sel_vis) _SelectorRing.alpha = 1.0;
	else _SelectorRing.alpha = 0.0;
	
	if (go_vis)
	{
		[_GoButton setAlpha: 1.0];
		[_GoButton setEnabled: YES];
	}
	else
	{
		[_GoButton setAlpha: 0.0];
		[_GoButton setEnabled: NO];		
	}

	if (tl_vis)
	{
		[_TurnLeftButton setAlpha: 1.0];
		[_TurnLeftButton setEnabled: YES];
	}
	else
	{
		[_TurnLeftButton setAlpha: 0.0];
		[_TurnLeftButton setEnabled: NO];		
	}

	if (tr_vis)
	{
		[_TurnRightButton setAlpha: 1.0];
		[_TurnRightButton setEnabled: YES];
	}
	else
	{
		[_TurnRightButton setAlpha: 0.0];
		[_TurnRightButton setEnabled: NO];		
	}

	if (anc_vis)
	{
		[_AnchorButton setAlpha: 1.0];
		[_AnchorButton setEnabled: YES];
	}
	else
	{
		[_AnchorButton setAlpha: 0.0];
		[_AnchorButton setEnabled: NO];		
	}
}

/* set visibility of different combat aid elements */
- (void) setVisibilityForSelector:(bool) sel_vis
					leftFiringArc:(bool) larc_vis
				   rightFiringArc:(bool) rarc_vis
                    fortFiringArc:(bool) farc_vis
{
	if (sel_vis) _SelectorRing.alpha = 1.0;
	else _SelectorRing.alpha = 0.0;

	if (larc_vis) _LeftFiringArc.alpha = 0.8;
	else _LeftFiringArc.alpha = 0.0;

	if (rarc_vis) _RightFiringArc.alpha = 0.8;
	else _RightFiringArc.alpha = 0.0;
    
	if (farc_vis) _FortFiringArc.alpha = 0.8;
	else _FortFiringArc.alpha = 0.0;    

}

- (void) dealloc
{
	NSLog(@"WARNING: ShipSelectorView is being dealloc'd!");

	[_SelectorRing release];
	[_LeftFiringArc release];
	[_RightFiringArc release];
	[_FortFiringArc release];
    
	[_GoButton removeFromSuperview];
	_GoButton = nil;
	
	[_TurnLeftButton removeFromSuperview];
	_TurnLeftButton = nil;
	
	[_TurnRightButton removeFromSuperview];
	_TurnRightButton = nil;
	
	[_AnchorButton removeFromSuperview];
	_AnchorButton = nil;
	
	[super dealloc];
	
	NSLog(@"ShipSelectorView dealloc finishes ok!");
}


@end
