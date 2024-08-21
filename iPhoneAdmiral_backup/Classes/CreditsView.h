//
//  CreditsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DQReadyControl;

@interface CreditsView : UIImageView 
{
    DQReadyControl * _versionDQRlabel;
}

@property (nonatomic, retain) IBOutlet DQReadyControl * _versionDQRlabel;

@end
