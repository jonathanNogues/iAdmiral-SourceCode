//
//  Common.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "Ship.h"
#import "AIDefines.h"

#define NORM_FP_MAX_DIST 7
static const float FirepowerModifier[8] =  {0.00,       //0 hex range - ???
                                            2.00,       //1 hex range - shock and awe!
                                            1.50,       //2 hex range - deadly!
                                            1.25,       //3 hex range - still dangerous!
                                            1.00,       //4 hex range - normal
                                            0.9,        //5 hex range - slightly weaker
                                            0.5,        //6 hex range - hypothethical range for HexAIHintsCalculation
                                            0.5};       //7 hex range - hypothethical range for HexAIHintsCalculation


#define SPEC_FP_MAX_DIST 5
static const float FirepowerModifierSpecialAmmo[6] =    {0.00,          //0 hex range - ???
                                                        1.50,           //1 hex range - stronger
                                                        1.00,           //2 hex range - normal
                                                        0.60,           //3 hex range - slightly weaker
                                                        0.33,           //4 hex range - much weaker
                                                        0.10};          //5 hex range - almost no effect
    

NSString * translateFilePath(NSString * filename)
{
	NSFileManager *filemgr;
	filemgr = [NSFileManager defaultManager];
	
	//get path to documents, this will have to be changed
	NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * fullpath = [NSString stringWithFormat:@"%@/%@", 
						   [dirPaths objectAtIndex:0], 
						   filename];
	
	return fullpath;
}

NSString * courseToString(HexDirection dir)
{
	switch (dir)
	{
		case LEFT:
			return @"LL";
			
		case LEFT_UP:
			return @"LU";
			
		case LEFT_DOWN:
			return @"LD";
			
		case RIGHT:
			return @"RR";
			
		case RIGHT_UP:
			return @"RU";
			
		case RIGHT_DOWN:
			return @"RD";
			
		default:
			return @"??";
	}
}

int normalizedFirepowerValue(int firepower_value)
{
	if (firepower_value <= 0) return 0;
	else 
	{
		if (firepower_value < 10) return 10;
		else return (firepower_value - (firepower_value % 10));
	}
}

int normalizedFirePowerValue(int gun_count, int distance, AmmunitionType ammo_type)
{
    int retval = 0;
    
    //try as you might, you won't do any damage with no cannons
    if (gun_count == 0) return 0;
    
    switch (ammo_type)
    {
        case AmmoRoundShot:
            if (distance <= NORM_FP_MAX_DIST)
            {
                retval = gun_count * FirepowerModifier[distance];
                retval = ((retval / 10) * 10) + 10;
            }
            break;
            
        case AmmoChainShot:
        case AmmoGrapeShot:
            if (distance <= SPEC_FP_MAX_DIST)
            {
                retval = gun_count * FirepowerModifierSpecialAmmo[distance];
                retval = ((retval / 10) * 10) + 10;
            }
            break;
            
        case AmmoHotShot:
            NSLog(@"Hot Shot Not Implemented Yet");
            break;
    }
    
    return retval;
}

int normalizedBoardingStrength(Ship * ship)
{
	int bstr = (ship._Class - 1) + ship._Soldiers;
	if (ship._FlagshipAfloat) bstr++;

	if (ship._BoardingsCount > 1) bstr = bstr / ship._BoardingsCount;
	
	return (bstr * AI_POS_VALUE_BRD_STR_MODIFIER);
}
