//
//  UICommon.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//notification name strings
#define NOTIF_NAME_SWITCH_TO_STATS			@"SwitchFromBIToStatisticsView"
#define NOTIF_NAME_POP_ME					@"PopThisViewController"
#define NOTIF_NAME_POP_ME_ANIMATED			@"PopThisViewControllerAnimated"
#define NOTIF_NAME_POP_AND_DESTROY_ME		@"PopAndDestroyThisViewController"
#define NOTIF_NAME_SWITCH_TO_BI             @"SwitchFromScenarioPickerToBI"

#define NOTIF_NAME_PAUSE_BI                 @"BattleInterfacePAUSE"
#define NOTIF_NAME_UNPAUSE_BI               @"BattleInterfaceCONTINUE"
#define NOTIF_NAME_QUIT_BI                  @"BattleInterfaceSAVEandQUIT"

#define NOTIF_NAME_SHOW_ADMIRALOPEDIA       @"ShowAdmiralopediaOverTutorials"

#define BurgundyColor ([UIColor colorWithRed:0.619 green:0.043 blue:0.058 alpha:1.0])

typedef enum
{
	StateVisible,
	StateIconOnly,
	StateHidden,
} AmmoChooserUIState;
