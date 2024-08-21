//
//  TutorialsAndInstructionsViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TutorialsAndInstructionsView;

@interface TutorialsAndInstructionsViewController : UIViewController {
	TutorialsAndInstructionsView * _InstructionsRootView;
}

@property (nonatomic, retain) IBOutlet TutorialsAndInstructionsView * _InstructionsRootView; 

@end
