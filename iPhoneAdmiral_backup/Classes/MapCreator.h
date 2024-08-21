//
//  MapCreator.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Ship.h"

#ifdef MAPCREATOR

@class MapView;

typedef enum
{
	PlaceShips,
	PlaceTerrain,
	Erasor,
	Info,
} PlacerType;

typedef enum
{
    NormalShip,
    FlagShip,
    CargoShip,
    Sentinel,
    HunterKiller,
    PriorityTarget,
    
    SHIP_FEATURE_MAX,
} ShipFeature;

@interface MapCreator : UIView {
	PlacerType		_MyPlacer;
	UIButton * _PlacerTypeButton;

	//placing ships
	ShipType		_PlacerShipType;
	SideOfConflict	_PlacerSoC;
	HexDirection	_PlacerCourse;
	ShipFeature		_PlacerShipFeature;
	
	UIButton * _ShipTypeButton;
	UIButton * _SideOfConflictButton;
	UIButton * _HexDirectionButton;
	UIButton * _ShipFeatureButton;
	
	//placing terrain
	TerrainType		_PlacerTerrain;
	UIButton * _TerrainTypeButton;
	
	//close the mapcreator
	UIButton * _CloseButton;
	
	//scenario
	HexDirection	_PlacerWindDirection;
	UIButton *		_WindDirButton;
	
	SideOfConflict	_PlacerCurrentSide;
	UIButton *		_CurrentSideButton;
	
	//-----
	MapView * _pMapView;
}

@property(nonatomic, readonly) PlacerType _MyPlacer;

@property(nonatomic, readonly) ShipType	_PlacerShipType;
@property(nonatomic, readonly) SideOfConflict _PlacerSoC;
@property(nonatomic, readonly) HexDirection _PlacerCourse;
@property(nonatomic, readonly) TerrainType _PlacerTerrain;
@property(nonatomic, readonly) ShipFeature _PlacerShipFeature;

@property(nonatomic, readonly) HexDirection	_PlacerWindDirection;
@property(nonatomic, readonly) SideOfConflict _PlacerCurrentSide;

@property(nonatomic, retain) MapView * _pMapView;

- (id) initWithDefaultFrame;

- (void) handle_PlacerTypeButton:(id) sender;

- (void) handle_ShipTypeButton;
- (void) handle_SideOfConflictButton;
- (void) handle_HexDirectionButton;
- (void) handle_TerrainTypeButton;
- (void) handle_ShipFeatureButton;

- (void) handle_WindDirectionButton;
- (void) handle_CurrentSideButton;

- (void) handle_CloseButton;

@end

#endif
