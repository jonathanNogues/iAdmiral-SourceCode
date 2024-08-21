//
//  StatisticsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsView.h"
#import "StatisticsContainer.h"
#import "Ship.h"
#import "Common.h"
#import "DQReadyControl.h"

#define ANIMATION_STEP 0.4

@implementation StatisticsView

@synthesize _BlueSurvivingSOLs;
@synthesize _BlueSurvivingEscorts;
@synthesize _BlueSurvivingPickets;
@synthesize _BlueCrippledSOLs;
@synthesize _BlueCrippledEscorts;
@synthesize _BlueCrippledPickets;
@synthesize _BlueLostSOLs;
@synthesize _BlueLostEscorts;
@synthesize _BlueLostPickets;
@synthesize _RedSurvivingSOLs;
@synthesize _RedSurvivingEscorts;
@synthesize _RedSurvivingPickets;
@synthesize _RedCrippledSOLs;
@synthesize _RedCrippledEscorts;
@synthesize _RedCrippledPickets;
@synthesize _RedLostSOLs;
@synthesize _RedLostEscorts;
@synthesize _RedLostPickets;

@synthesize _TextResultLabel;
@synthesize _PlayerLabel;
@synthesize _EnemyLabel;
@synthesize _SurvivorsLabel;
@synthesize _CrippledLabel;
@synthesize _LostLabel;

- (void) awakeFromNib
{
    [_TextResultLabel set_TextCentered:YES];
    [_TextResultLabel set_TextSize:54.0];
    [_TextResultLabel set_TextColor: BurgundyColor];
    
    [_PlayerLabel set_TextSize:40.0];
    [_PlayerLabel set_TextCentered:YES];
    [_EnemyLabel set_TextSize:40.0];
    [_EnemyLabel set_TextCentered:YES];
    
    [_SurvivorsLabel set_TextSize:30.0];
    [_SurvivorsLabel set_TextIndent:1];
    [_SurvivorsLabel set_Text:@"Survived"];
    
    [_CrippledLabel set_TextSize:30.0];
    [_CrippledLabel set_TextIndent:1];
    [_CrippledLabel set_Text:@"Crippled"];

    [_LostLabel set_TextSize:30.0];
    [_LostLabel set_TextIndent:1];
    [_LostLabel set_Text:@"Lost"];
    
    [self setImage: [UIImage imageNamed:@"ResultsBG.png"]];
}

- (void) touchesEnded:(NSSet *)touches 
			withEvent:(UIEvent *)event
{	
    //first touch - zap the animation and show all labels
    //second touch - quit to main menu
	
    if ( !_thisIsAsecondTouch )
    {
        [_AnimationTimer invalidate];
        _AnimationTimer = nil;
        
        NSMutableArray * animSequence = [NSMutableArray arrayWithObjects:
                                         _RedSurvivingPickets, _RedSurvivingEscorts, _RedSurvivingSOLs,
                                         _BlueSurvivingPickets, _BlueSurvivingEscorts, _BlueSurvivingSOLs,
                                         _RedCrippledPickets, _RedCrippledEscorts, _RedCrippledSOLs,
                                         _BlueCrippledPickets, _BlueCrippledEscorts, _BlueCrippledSOLs,
                                         _RedLostPickets, _RedLostEscorts, _RedLostSOLs,
                                         _BlueLostPickets, _BlueLostEscorts, _BlueLostSOLs,
                                         nil];
        
        //set all labels invisible
        for (UILabel * uil in animSequence) [uil setAlpha: 1.0];    

        _thisIsAsecondTouch = YES;
    }
    else
    {
        if ([_AnimationTimer isValid]) [_AnimationTimer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_POP_AND_DESTROY_ME object:@"SVC"];
    }
}

- (void) prepareForAnimationWithStats:(StatisticsContainer *) _lastBattleStats
{
    _thisIsAsecondTouch = NO;
	
    //side naming and victory msg choice
    if (_lastBattleStats._WasMultiplayerGame)
    {
        [_PlayerLabel set_Text:@"English"];
        [_EnemyLabel set_Text:@"Spanish"];
        
        if (_lastBattleStats._winnerIs == ResultRedSideWon) [_TextResultLabel set_Text:@"English Victory"];
        else [_TextResultLabel set_Text:@"Spanish Victory"];
    }
    else
    {
        [_PlayerLabel set_Text:@"Player"];
        [_EnemyLabel set_Text:@"Enemy"];

        if (_lastBattleStats._winnerIs == ResultRedSideWon) [_TextResultLabel set_Text:@"Victory"];
        else [_TextResultLabel set_Text:@"Defeat"];
    }
        
    if (_lastBattleStats._winnerIs == ResultDraw) [_TextResultLabel set_Text:@"Draw"];
    
	[_BlueSurvivingSOLs		setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassCapital State:Surviving] ];
	[_BlueSurvivingEscorts	setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassEscort State:Surviving] ];
	[_BlueSurvivingPickets	setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassPicket State:Surviving] ];
	
	[_BlueCrippledSOLs		setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassCapital State:Crippled] ];
	[_BlueCrippledEscorts	setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassEscort State:Crippled] ];
	[_BlueCrippledPickets	setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassPicket State:Crippled] ];
	
	[_BlueLostSOLs			setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassCapital State:Lost] ];
	[_BlueLostEscorts		setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassEscort State:Lost] ];
	[_BlueLostPickets		setText: [_lastBattleStats retrieveStrNumForSide:BlueSide Class:ClassPicket State:Lost] ];
	
	
	[_RedSurvivingSOLs		setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassCapital State:Surviving] ];
	[_RedSurvivingEscorts	setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassEscort State:Surviving] ];
	[_RedSurvivingPickets	setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassPicket State:Surviving] ];
	
	[_RedCrippledSOLs		setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassCapital State:Crippled] ];
	[_RedCrippledEscorts	setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassEscort State:Crippled] ];
	[_RedCrippledPickets	setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassPicket State:Crippled] ];
    
	[_RedLostSOLs			setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassCapital State:Lost] ];
	[_RedLostEscorts		setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassEscort State:Lost] ];
	[_RedLostPickets		setText: [_lastBattleStats retrieveStrNumForSide:RedSide Class:ClassPicket State:Lost] ];
	
	//prepare for animation
	
	NSMutableArray * animSequence = [NSMutableArray arrayWithObjects:
									 _RedSurvivingPickets, _RedSurvivingEscorts, _RedSurvivingSOLs,
									 _BlueSurvivingPickets, _BlueSurvivingEscorts, _BlueSurvivingSOLs,
									 _RedCrippledPickets, _RedCrippledEscorts, _RedCrippledSOLs,
									 _BlueCrippledPickets, _BlueCrippledEscorts, _BlueCrippledSOLs,
									 _RedLostPickets, _RedLostEscorts, _RedLostSOLs,
									 _BlueLostPickets, _BlueLostEscorts, _BlueLostSOLs,
									 nil];
	
	//set all labels invisible
	for (UILabel * uil in animSequence) [uil setAlpha:0.0];    
}

- (void) animateView
{
	NSMutableArray * animSequence = [NSMutableArray arrayWithObjects:
									 _RedSurvivingPickets, _RedSurvivingEscorts, _RedSurvivingSOLs,
									 _BlueSurvivingPickets, _BlueSurvivingEscorts, _BlueSurvivingSOLs,
									 _RedCrippledPickets, _RedCrippledEscorts, _RedCrippledSOLs,
									 _BlueCrippledPickets, _BlueCrippledEscorts, _BlueCrippledSOLs,
									 _RedLostPickets, _RedLostEscorts, _RedLostSOLs,
									 _BlueLostPickets, _BlueLostEscorts, _BlueLostSOLs,
									 nil];
		
	_AnimationTimer = [NSTimer scheduledTimerWithTimeInterval: ANIMATION_STEP
													   target: self
													 selector: @selector(performAnimation:)
													 userInfo: animSequence
													  repeats: YES];
}

- (void) performAnimation:(NSTimer *) timer
{
	NSMutableArray * animseq = (NSMutableArray *)[timer userInfo];
	
	if ([animseq count] == 0)
	{
		_AnimationTimer = nil;
		[timer invalidate];
        
        //first touch should now quit to main menu
        _thisIsAsecondTouch = YES;
	}
	else
	{
		//play sound
		[[animseq objectAtIndex: 0] setAlpha: 1.0];
		[animseq removeObjectAtIndex: 0];
	}
}

- (void)dealloc 
{
    [_AnimationTimer invalidate];
    _AnimationTimer = nil;

	[_BlueSurvivingSOLs		release];
	[_BlueSurvivingEscorts	release];
	[_BlueSurvivingPickets	release];
	
	[_BlueCrippledSOLs		release];
	[_BlueCrippledEscorts	release];
	[_BlueCrippledPickets	release];
	
	[_BlueLostSOLs			release];
	[_BlueLostEscorts		release];
	[_BlueLostPickets		release];
	
	[_RedSurvivingSOLs		release];
	[_RedSurvivingEscorts	release];
	[_RedSurvivingPickets	release];
	
	[_RedCrippledSOLs		release];
	[_RedCrippledEscorts	release];
	[_RedCrippledPickets	release];
		
	[_RedLostSOLs			release];
	[_RedLostEscorts		release];
	[_RedLostPickets		release];
	
    [_TextResultLabel release];
    [_PlayerLabel release];
    [_EnemyLabel release];

    [_SurvivorsLabel release];
    [_CrippledLabel release];
    [_LostLabel release];

    [super dealloc];
}


@end
