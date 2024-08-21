//
//  IntegratedShipView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IntegratedShipView.h"
#import "Ship.h"
#import "ShipHealthView.h"
#import "FireAnimSubview.h"

#import "SoundCenter.h"

#import "UIDmgNfo.h"

//for messaging the mapview when animations finish
#import "MapView.h"

//THIS MUST MATCH THE MAPVIEW's VALUE
#define SHIPVIEW_TAG_PREFIX             3000

//duration of ship sinkign animation
#define SHIP_SINK_DURATION				2.0

//dmg label related stuff:
//how long does it take for a label to appear
#define DMGLABEL_APPEAR_TIME            0.2
//how long each label is visible
#define DMGLABEL_VISIBILITY_TIME		2.7
//delay between launchig nex label
#define DMGLABEL_DELAY					1.3
//dmg label dimensions
#define DMGLABEL_INITIAL_Y_OFFSET		30
#define DMGLABEL_MAX_Y_OFFSET			80
#define DMGLABEL_HEIGHT					30
#define DMGLABEL_WIDTH					140

//delay to first label appearance
#define INITIAL_LABEL_DELAY             0.8

//helper function to update course
HexDirection update_course(HexDirection current, TurnDirection td);

@implementation IntegratedShipView

@synthesize _MyCourse;

                /**********************
                 *   INITIALIZATION   *
                 **********************/
- (id) initWithShip:(Ship *) ship
{
    //create ship image name
    NSString * ShipImageName;
    
    NSLog(@"Creating isv for %@, (type: %d)", ship, ship._Type);
    
    //decide on a type
    switch([ship _Type])
    {
        case pinnace:
            ShipImageName = @"Pinnace.png";
            break;
            
        case brig:
            ShipImageName = @"Brig.png";
            break;
            
        case schooner:
            ShipImageName = @"Schooner.png";
            break;
            
        case fluyt:
            ShipImageName = @"Fluyt.png";
            break;
            
        case galleon:
            ShipImageName = @"Galleon.png";
            break;
            
        case fast_galleon:
            ShipImageName = @"FastGalleon.png";
            break;
            
        case frigate:
            ShipImageName = @"Frigate.png";
            break;
            
        case ship_of_the_line:
            ShipImageName = @"Manowar.png";
            break;
            
        case small_fort:
            ShipImageName = @"SmallFort.png";
            break;
            
        case med_fort:
            ShipImageName = @"MedFort.png";
            break;

        case big_fort:
            ShipImageName = @"BigFort.png";
            break;

        case town:
            ShipImageName = @"Town.png";
            break;
            
        default:
            NSAssert(NO, @"Unrecognized shiptype!");
            break;
    }
    
    //load ship image and put it into appropriate view
    _MyShipImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:ShipImageName] ];
    self = [super initWithFrame: _MyShipImage.frame ];
    
    [self addSubview:_MyShipImage];
    _MyShipImage.center = self.center;
    
    //set tag
    [self setTag:SHIPVIEW_TAG_PREFIX + [ship _ID]];
    
    
    //				SHIP HEALTH SUBVIEW PART
    _MyHealthView = [[ShipHealthView alloc] initWithShip: ship];
    [self addSubview: _MyHealthView];
    [_MyHealthView setCenter: self.center];
    
    
    //				SHIP FIRE ANIMATION PART
    //start fire animation if ship on fire
    if (ship._FireOnBoard > FireNone) [self updateFireSizeTo: ship._FireOnBoard];

    
    //              ROTATE TO CURRENT HEADING
    _MyCourse = ship._Course;

    _MyShipImage.transform = CGAffineTransformMakeRotation(_MyCourse * 60.0 * M_PI / 180.0);
    
    NSLog(@"IntegratedShipSubview created for ship: %@.", ship);
    
    return self;
}

                /******************
                 *   NAVIGATION   *
                 ******************/
- (void) animateMoveTo:(CGPoint) destination 
       completionBlock:(CompletionBlock_t) comp_block
{
    UIView * pSSV = [[self superview] viewWithTag: 200];        //(200 = SHIPSELECTORTAG)

    //animation block - move ship view along with the selector
    void (^anim_block)(void) = ^{
        self.center = destination;
        pSSV.center = destination;
    };
    
    [UIView animateWithDuration: 0.5
                     animations: anim_block
                     completion: comp_block ];
}


- (void) animateTurn:(TurnDirection) td
     completionBlock:(CompletionBlock_t) comp_block
{
    UIView * pSSV = [[self superview] viewWithTag: 200];        //(200 = SHIPSELECTORTAG)
        
    //set new course
    _MyCourse = update_course(_MyCourse, td);
    
    //update hp
    [_MyHealthView setHPBarPositionForCourse: _MyCourse];
    
    //prepare transormation for new course
    CGAffineTransform tr = CGAffineTransformMakeRotation(_MyCourse * 60.0 * M_PI / 180.0);
    
    //animation block turn the ship image, selector, and adjust the healthbar
    void (^anim_block)(void) = ^{
        _MyShipImage.transform = tr;
        pSSV.transform = tr;
        [_MyHealthView rotateHPBarToPosition];
    };
    
    [UIView animateWithDuration: 0.5
                     animations: anim_block
                     completion: comp_block ];

}

- (void) undoShipCourseTo:(HexDirection) hd
{
    //backup course
    _MyCourse = hd;
    
    //update hp
    [_MyHealthView setHPBarPositionForCourse: _MyCourse];
    [_MyHealthView rotateHPBarToPosition];

    //rotate image
    _MyShipImage.transform = CGAffineTransformMakeRotation(_MyCourse * 60.0 * M_PI / 180.0);
}

                /**************
                 *   DAMAGE   *
                 **************/
- (void) animateDamageWithUiDmgNfo:(UIDmgNfo *) uidmg;
{
    //NSLog(@"Animating damage messages!");
    NSLog(@"%d messages to be animated", [uidmg._MSGs count]);
    
    CGPoint center_in_superview = [[[self superview] viewWithTag:[self tag]] center];
    CGPoint starting_center = CGPointMake(center_in_superview.x, center_in_superview.y - DMGLABEL_INITIAL_Y_OFFSET);
    CGPoint target = CGPointMake( center_in_superview.x, center_in_superview.y - DMGLABEL_MAX_Y_OFFSET );
    NSTimeInterval label_delay = INITIAL_LABEL_DELAY;
    int counter = 1;
    const int count_max = [uidmg._MSGs count];
    
    //animate messages
    for (NSString * msg in uidmg._MSGs)
    {
        NSLog(@"Animating message %d: %@", counter, msg);
        
        //create label
        CGRect rect = CGRectMake( 0, 0, DMGLABEL_WIDTH, DMGLABEL_HEIGHT);
		
		UILabel * dmglabel = [[UILabel alloc] initWithFrame:rect];
		
		[dmglabel setText: msg];
		[dmglabel setFont:[UIFont fontWithName: @"Cochin-BoldItalic" size: 18] ];
		[dmglabel setTextColor: [UIColor redColor]];
		[dmglabel setBackgroundColor: [UIColor clearColor]];
		[dmglabel setTextAlignment: UITextAlignmentCenter];
        [dmglabel setAlpha: 0.0];

        //add and position the label in superview
        [[self superview] addSubview: dmglabel];
        [dmglabel setCenter: starting_center];
        
        //animation is divided into two parts
        //first the label_appear_anim_block block happens, with label appearing on the ship
        //then, as stated in label_appear_comp_block, second animation begins, which is defined by
        //label_move_n_fade_anim_block, which moves and fades the label, and then,
        //in label_final_comp_block it removes the label, and launches all_damage_comp_block if
        //this was the last message
        
        //first animation
        AnimationBlock_t label_appear_anim_block = 
        ^{
            [dmglabel setAlpha: 1.0];
        };
        
        //second animation
        AnimationBlock_t label_move_n_fade_anim_block =
        ^{
            [dmglabel setAlpha: 0.0];
            [dmglabel setCenter:target];
        };
        
        //second animation completion block
        CompletionBlock_t label_final_comp_block = 
        ^(BOOL fin){
            [dmglabel removeFromSuperview];
            [dmglabel release];
        };

        
        //allow user interaction on last message - but only on last
        int anim_options;
        
        if (counter == count_max){
            anim_options = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction;
        }
        else
        {
            anim_options = UIViewAnimationOptionCurveEaseIn;
        }
        
        //first animation completion block
        CompletionBlock_t label_appear_comp_block = 
        ^(BOOL fin){
            [UIView animateWithDuration: DMGLABEL_VISIBILITY_TIME 
                                  delay: 0.0 
                                options: anim_options
                             animations: label_move_n_fade_anim_block
                             completion: label_final_comp_block ];
        };
        
        NSLog(@"Will animate with delay :%f", label_delay);
        
        //launch FIRST animation (it will launch the SECOND one by itself)
        [UIView animateWithDuration: DMGLABEL_APPEAR_TIME
                              delay: label_delay
                            options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations: label_appear_anim_block
                         completion: label_appear_comp_block ];
        
        label_delay += DMGLABEL_DELAY;
        counter++;
    }
    
    //inform the mapview that damage appeared
    MapView * pMapView = (MapView *)[self superview];
    if (uidmg._FatalDamage)
    {
        [self performSelector:@selector(animateSinking) 
                   withObject:nil 
                   afterDelay:label_delay];
        
        label_delay += DMGLABEL_DELAY;
        
        //check if victory occured, then proceed to next damage
        [pMapView performSelector: @selector(checkForVictoryThenHandleDamage) 
                       withObject: nil 
                       afterDelay: label_delay ];
    }
    else
    {
        //just check for next damage
        [pMapView performSelector: @selector(handleDamage) 
                       withObject: nil 
                       afterDelay: label_delay ];
    }
    
    //animate HP loss
    [_MyHealthView updateShipHPBy: uidmg._HPLoss];
    [_MyHealthView animateHPChange: 2.0];
    
    //animate fire
    if (uidmg._fireUpdateNeeded) [self updateFireSizeTo:uidmg._VictimFireNow];
}

- (void) updateFireSizeTo:(FireSize) fs
{
    //check if the fire was extinguished
    if (fs == FireNone)
    {
        NSLog(@"Fire extinguished!");
        [_MyFireView stopAnimating];
        [_MyFireView removeFromSuperview];
        [_MyFireView release];
        _MyFireView = nil;
        
        //nothing more to do
        return;
    }
    
    //we're here, meaning that there is some fire
    
    if (_MyFireView == nil) //new fire
    {
        NSLog(@"New fire!");
        _MyFireView = [[FireAnimSubview alloc] initWithCourse:LEFT Size:fs];
        
        //set center
        [_MyFireView setCenter: _MyShipImage.center];
        
        //add to ship image view
        [_MyShipImage addSubview:_MyFireView];				
    }
    else    //firesize changes
    {
        NSLog(@"Fire changes size!");
        [_MyFireView updateToFireSize:fs];
    }    
}

- (void) animateSinking;
{
    //healthbar should already be gone but
    [_MyHealthView removeFromSuperview];
    [_MyFireView stopAnimating];
    [_MyFireView removeFromSuperview];
    
    AnimationBlock_t anim_block = 
    ^{
        [_MyShipImage setAlpha:0.0];
    };
    
    CompletionBlock_t comp_block = 
    ^(BOOL fin){
        [self removeFromSuperview]; //should be enough to cause a dealloc
        //[self release];
    };
    
    [UIView animateWithDuration: SHIP_SINK_DURATION
                     animations: anim_block
                     completion: comp_block ];
    
    [globalSoundCenter playEffect: SOUND_SHIP_SINK];
    
}

                /****************
                 *   RESPONSE   *
                 ****************/

/*
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"IntegratedShipSubview for ship no. %d was clicked!", self.tag - 3000);
}
*/

                /***************
                 *   CLEANUP   *
                 ***************/

- (void)dealloc
{
    NSLog(@"IntegratedShipSubview %d is being dealloc'd!", self.tag);

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_MyHealthView release];
    [_MyFireView stopAnimating];
    [_MyFireView release];
    [_MyShipImage release];
    
    [super dealloc];
}

@end

//helper functions
HexDirection update_course(HexDirection current, TurnDirection td)
{
    int change;
    if (td == TurnLeft) change = -1;
    else change = 1;
    current = current + change;
    if (current == -1) current = 5;
    if (current == 6) current = 0;
    
    return current;
};
