//
//  AIDefines.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//************ ENGAGEMENT VALUE **************
#define AI_ENG_VALUE_BASE_BONUS				30
#define AI_ENG_VALUE_CLASS_MATCH_BONUS		30
#define AI_ENG_VALUE_HIGHER_CLASS_BONUS		10
#define AI_ENG_VALUE_DMG_BONUS				25
#define AI_ENG_VALUE_HVY_DMG_BONUS			25
#define AI_ENG_VALUE_CRIT_DMG_BONUS			10
#define AI_ENG_VALUE_BOARDING_PENALTY		60
#define AI_ENG_VALUE_SOL_ON_SMALL_PENALTY	25
#define AI_ENG_VALUE_CLOSE_RANGE_BONUS		30
#define AI_ENG_VALUE_FLAGSHIP_BONUS         15
#define AI_ENG_VALUE_CARGOSHIP_BONUS        60

//************* POSITION VALUE ***************
#define AI_POS_VALUE_BRD_STR_MODIFIER		20 //boarding strength gets multiplied by this as to be on par with FIREPOWER hints
#define AI_POS_VALUE_BEST_TARGET_IN_F_ARC	5
#define AI_POS_VALUE_AGGR_AI_IGNORE_MOD		2
#define AI_POS_VALUE_COWARD_AI_IGNORE_MOD	0.5

#define AI_POS_VALUE_PENALTY_FOR_SENTINEL   -100 //non-sentinel AI ignore this, sentinels will not stray from defensive positions
#define AI_POS_VALUE_STRATEGIC_POS_BONUS    10  //non-sentinel AI ignore this, sentinels have incentive to sit right on the objective

#define AI_FIGHTING_DISTANCE				7
#define AI_SEEKING_DISTANCE					25
