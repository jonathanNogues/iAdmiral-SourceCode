//
//  StatisticsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StatisticsContainer;
@class DQReadyControl;

@interface StatisticsView : UIImageView 
{
	UILabel * _BlueSurvivingSOLs;
	UILabel * _BlueSurvivingEscorts;
	UILabel * _BlueSurvivingPickets;

	UILabel * _BlueCrippledSOLs;
	UILabel * _BlueCrippledEscorts;
	UILabel * _BlueCrippledPickets;
	
	UILabel * _BlueLostSOLs;
	UILabel * _BlueLostEscorts;
	UILabel * _BlueLostPickets;
	
	
	UILabel * _RedSurvivingSOLs;
	UILabel * _RedSurvivingEscorts;
	UILabel * _RedSurvivingPickets;
	
	UILabel * _RedCrippledSOLs;
	UILabel * _RedCrippledEscorts;
	UILabel * _RedCrippledPickets;
	
	UILabel * _RedLostSOLs;
	UILabel * _RedLostEscorts;
	UILabel * _RedLostPickets;
    
    DQReadyControl * _TextResultLabel;
    DQReadyControl * _PlayerLabel;
    DQReadyControl * _EnemyLabel;
    
    DQReadyControl * _SurvivorsLabel;
    DQReadyControl * _CrippledLabel;
    DQReadyControl * _LostLabel;
    
	NSTimer * _AnimationTimer;
    
    BOOL _thisIsAsecondTouch;
}

@property(nonatomic, retain) IBOutlet UILabel * _BlueSurvivingSOLs;
@property(nonatomic, retain) IBOutlet UILabel * _BlueSurvivingEscorts;
@property(nonatomic, retain) IBOutlet UILabel * _BlueSurvivingPickets;

@property(nonatomic, retain) IBOutlet UILabel * _BlueCrippledSOLs;
@property(nonatomic, retain) IBOutlet UILabel * _BlueCrippledEscorts;
@property(nonatomic, retain) IBOutlet UILabel * _BlueCrippledPickets;

@property(nonatomic, retain) IBOutlet UILabel * _BlueLostSOLs;
@property(nonatomic, retain) IBOutlet UILabel * _BlueLostEscorts;
@property(nonatomic, retain) IBOutlet UILabel * _BlueLostPickets;

@property(nonatomic, retain) IBOutlet UILabel * _RedSurvivingSOLs;
@property(nonatomic, retain) IBOutlet UILabel * _RedSurvivingEscorts;
@property(nonatomic, retain) IBOutlet UILabel * _RedSurvivingPickets;

@property(nonatomic, retain) IBOutlet UILabel * _RedCrippledSOLs;
@property(nonatomic, retain) IBOutlet UILabel * _RedCrippledEscorts;
@property(nonatomic, retain) IBOutlet UILabel * _RedCrippledPickets;

@property(nonatomic, retain) IBOutlet UILabel * _RedLostSOLs;
@property(nonatomic, retain) IBOutlet UILabel * _RedLostEscorts;
@property(nonatomic, retain) IBOutlet UILabel * _RedLostPickets;

@property(nonatomic, retain) IBOutlet DQReadyControl * _TextResultLabel;
@property(nonatomic, retain) IBOutlet DQReadyControl * _PlayerLabel;
@property(nonatomic, retain) IBOutlet DQReadyControl * _EnemyLabel;
@property(nonatomic, retain) IBOutlet DQReadyControl * _SurvivorsLabel;
@property(nonatomic, retain) IBOutlet DQReadyControl * _CrippledLabel;
@property(nonatomic, retain) IBOutlet DQReadyControl * _LostLabel;

- (void) prepareForAnimationWithStats:(StatisticsContainer *) _lastBattleStats;

- (void) animateView;

@end
