//
//  BIAlertView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AYETAG  1
#define NAYTAG  0
#define OKTAG   0

typedef enum
{
    AlertTypeTurnBegins,
    AlertTypeShallowWater,
    AlertTypeShootingFail,
    AlertTypeRealismOn,
    
}   UIAlertType;

@interface BIAlertView : UIAlertView 
{
    UIButton * _AyeButton;
    UIButton * _NayButton;
    
    UIImage * _BGImage;
}

- (id) initWithAlertType:(UIAlertType) type
                 message:(NSString *) msg
                delegate:(id) del
             cancelDelay:(NSTimeInterval) interval;

/* auto cancel function */
- (void) dismissAfterDelay;

@end
