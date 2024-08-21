//
//  CreditsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreditsView.h"
#import "UICommon.h"
#import "DQReadyControl.h"

@implementation CreditsView

@synthesize _versionDQRlabel;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    [_versionDQRlabel set_TextSize:25.0];
    [_versionDQRlabel set_Text:[NSString stringWithFormat:@"version %@", version]];
}

- (void) touchesEnded:(NSSet *)touches 
			withEvent:(UIEvent *)event
{	
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_POP_ME_ANIMATED object:nil];
}

-(void) dealloc
{
    [super dealloc];
    
    [_versionDQRlabel release];
}

@end
