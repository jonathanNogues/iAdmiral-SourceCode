//
//  InstructionsView.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionsView : UIView <UIScrollViewDelegate>
{
	UIScrollView * _InstructionSlidesScrollView;
    UIPageControl * _PageControl;
}

@property (nonatomic, retain) IBOutlet UIScrollView * _InstructionSlidesScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl * _PageControl;

- (IBAction) handlePagingEvents:(id) sender;

@end
