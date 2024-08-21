//
//  InstructionsViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstructionsView;

@interface InstructionsViewController : UIViewController {
	InstructionsView * _InstructionsView;
}

@property (nonatomic, retain) IBOutlet InstructionsView * _InstructionsView;

/* back to main menu function */
- (IBAction) handleBack:(id) sender;


@end
