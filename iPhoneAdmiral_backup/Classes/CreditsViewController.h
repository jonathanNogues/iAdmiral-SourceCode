//
//  CreditsViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreditsView;

@interface CreditsViewController : UIViewController {
    CreditsView * _CreditsView;
}

@property (nonatomic, retain) IBOutlet CreditsView * _CreditsView;

@end
