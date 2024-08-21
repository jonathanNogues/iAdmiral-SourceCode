//
//  MapView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "RoundButton.h"

@class HexBoard;
@class InterfaceView;
@class OptionsView;
@class Ship;
@class ShipSelectorView;
@class UIBoardingNfo;
@class ShootingAnimSubview;
@class HitAnimSubview;
@class SplashAnimSubview;
@class OptionsView;
@class BIAlertView;

@class AIPlayer;

typedef enum
{
	DDT_Normal,				//normal non blocking display type
	DDT_BOT_Update,			//zooming to each new coordinates and ui block
	DDT_AI_Turn_Firing,		//freezing AI and relaunching warpath on completion
	DDT_AI_Turn_Moving,		//damage from moving / boarding notif. - no need to relaunch warpath
} DamageDisplayType;

typedef enum
{
    drawTerrain,
    drawBG,
    drawTerrainOverBG,
    drawAI,
    
}   DrawingMode;

#ifdef MAPCREATOR
@class MapCreator;
#endif

@interface MapView : UIView <UIAlertViewDelegate>
{
	///background map
	UIImage * _BGImage;
	NSString * _BGImageName;
	
	//take note, that all individual shipviews are generated dynamically
	//and can be accessed via TAGs (3000 + SHIP._ID) only!
	
	///scale which the background has to be shrinked by to fit on screen in mapmode
	CGFloat _zoomScale;
	
	//flag for being in firing mode
	bool _inFiringMode;
	
	///pointer to encapsulating scrollview (needed for zooming right now)
	///correct way would probably be to move double tap recognition to rootview class?
	///or extend scrollview
	UIScrollView * _pEncapsulatingScrollView;
	InterfaceView * IBOutlet _pInterfaceView;
    
    OptionsView * _pOptionsView;
	bool _OptionsViewVisible;
	
	///hexboard data
	int _HexesPerRow;
	int _RowCount;
	
	//the actual hexboard with all ship, terrain, etc data
	HexBoard * _HexBoard;
	
	///last tapped point
	CGPoint _LastTapLocation;
	
	//selected ship
	Ship * _SelectedShip;		//nil for no ship selected
	
	//Ship Selector and Navigation Icons view
	ShipSelectorView * _ShipSelectorSubview;
	
	//current side of conflict
	SideOfConflict _CurrentSide;
	
	//ANIMATION SUBVIEWS
	
    //subview that handles animation of cannon firing
    ShootingAnimSubview * _ShootAnimView;
    
    //subview that handles animation of cannon hit
    HitAnimSubview * _HitAnimView;
    
	//subview that handles miss animation
	SplashAnimSubview * _MissAnimView;

	//AI PLAYERS
	
	AIPlayer * _RedPlayerAI;
	AIPlayer * _BluePlayerAI;
	
	bool _AIsTurn;		//set to YES when AI is making a move, NO for human turn
		
	//damage display type
	DamageDisplayType _DDT;
	
	//set to yes for freezing of the UI
	bool _GameOverDetected;
    	
    //drawing mode - bg image / terrain / terrain over bg / ai
    DrawingMode _DrawingMode;
    
    //handling pause
    BOOL _BattlePaused;
    BOOL _NeedsDamageUpdateAfterRestart;
    
    //alert view currently displayed
    BIAlertView * _CurrentBIAlert;
    
#ifdef MAPCREATOR
	MapCreator * _pMapCreator;
#endif
}

@property (nonatomic, retain) OptionsView * _pOptionsView;
@property (nonatomic, retain) IBOutlet InterfaceView *  _pInterfaceView;
@property (nonatomic, retain) UIScrollView * _pEncapsulatingScrollView;
@property (nonatomic, assign) SideOfConflict _CurrentSide;
@property (nonatomic, readonly) CGFloat _zoomScale;

@property (nonatomic, assign) Ship * _SelectedShip;

#ifdef MAPCREATOR
@property (nonatomic, assign) MapCreator * _pMapCreator;
#endif

				/**************
				 *	Creation  *
				 **************/

///initialize with hexboardinfo
- (id) initWithHexBoard:(HexBoard *) hb
		BGImageFileName:(NSString *) imageFileName;

///creates and loads all utilities subviews
- (void) loadUtilSubviews;

///creates and loads all ship subviews
- (void) loadShipSubviews;

///creates and loads animation subviews
- (void) loadAnimSubviews;

				/***************
				 *	Utilities  *
				 ***************/

/// Used to draw terrain
- (void) drawTerrain:(CGFloat) terrainAlpha;

/// Used to draw hexes
- (void) drawHexes;

/// Used to draw AI values
- (void) drawAIValues;

///draw single hex
- (void) drawHexInContext:(CGContextRef) context
			   withCenter:(CGPoint) center 
					 size:(CGFloat) hexsize;

/* centers the view at given coordinates */
- (void) zoomToX:(CGFloat) x
			   Y:(CGFloat) y;

/* zooms to coordinates of given ship */
- (void) zoomToShip:(Ship *) ship;

				/******************
				 *	Calculations  *
				 ******************/

/* self explanatory */
- (CGPoint) calculateCenterForRow:(int) row
						 HexInRow:(int) hir;

/* returns coordinates of the center of currently visible rect */
- (CGPoint) calculateCenterOfVisibleRect;

				/***********************
				 *	Animation Related  *
				 ***********************/

/* a function to deal with different animation finishing, 
 to avoid functions with meaningless parameters */
- (void) animationCentral:(NSString *)animationID
				 finished:(NSNumber *)finished
				  context:(void *)context;

- (void) performScrollSequence:(NSTimer *) timer;

				/****************************
				 *	UI Elements Visibility  *
				 ****************************/

/* set navigational items visibility */
- (void) setNavAidVisibilitySelector:(bool) sel_vis
								move:(bool) m_vis
								turn:(bool) t_vis
							  anchor:(bool) a_vis;

/* set combat aid items visibility */
- (void) setCombatAidVisibilitySelector:(bool) sel_vis
						  leftFiringArc:(bool) l_vis
						 rightFiringArc:(bool) r_vis
                          fortFiringArc:(bool) f_vis
                          ammoChoiceBox:(bool) ammo_vis;

/* shows / hides the options menu */
- (void) setOptionsMenuVisibile:(bool) vis
               byUndoMoveButton:(bool) umb
                    undoingShip:(Ship *) undoed_ship;

//animate single boarding update
- (void) animateBoarding:(UIBoardingNfo *) bai;

				/******************
				 *	Touch Events  *
				 ******************/

///handle touches ended event
- (void) touchesEnded:(NSSet *)touches 
			withEvent:(UIEvent *)event;

///handle single tap, meaning hex selection
- (void) handleSingleTap;

///handle double tap, meaning zooming
- (void) handleDoubleTap; 

				/**************************
				 *	Controller Functions  *
				 **************************/

- (void) handleShipSelected;

/* selected ship fires at given target */
- (void) handleShipToShipFire:(Ship *) target;

/* go button clicked - it almost always launches the perform move function */
- (void) handleGoButton;

- (void) performMove;

/* convenience function for turning */
- (void) handleTurnLeftButton;

/* convenience function for turning */
- (void) handleTurnRightButton;

- (void) handleTurnButton:(TurnDirection) td;

- (void) handleAnchorButton;

- (void) handleUndoButton;

- (void) performUndo:(Ship *) undoed_ship;

- (void) handleDamage;

/* called when something finishes sinking */
- (void) checkForVictoryThenHandleDamage;

- (void) checkAndHandleVictory;

				/************************************
				 *		 INTERFACE RESPONDERS		*
				 ************************************/

- (void) handleNextShip;

- (void) handleEndTurn;

- (void) startTurn;

- (void) handleFire;

- (void) handleOptions;		//wind button!

				/************************************
				 *		 WRAPPERS FOR HEXBOARD		*
				 ************************************/

- (void) handleAmmoChangeTo:(AmmunitionType) at;

/* used by the interface to get initial wind direction */
- (HexDirection) getWindDirection;

/* save current map */
- (void) saveMap:(NSString *) filename;

- (void) forceWindUpdate;

                        /********************
                         *    MAPCREATOR    *
                         ********************/

#ifdef MAPCREATOR

- (void) setWindDirection:(HexDirection) dir;

- (void) setSideOfConflict:(SideOfConflict) side;

#endif

- (void) switchDrawingMode;

                        /***********************
                         *    APP LIFECYCLE    *
                         ***********************/

- (void) setGamePause:(BOOL) pause;

- (void) quitGame;



@end
