//
//  InstructionsView.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstructionsView.h"
#import "BattleInterfaceAppDelegate.h"

@implementation InstructionsView

@synthesize _InstructionSlidesScrollView;
@synthesize _PageControl;

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint cof = scrollView.contentOffset;
    
    int page = cof.x / 480.0;
    
    [_PageControl setCurrentPage:page];
}

- (IBAction) handlePagingEvents:(id) sender
{
    CGFloat xofset = _PageControl.currentPage * 480.0;
    
    CGRect rect = CGRectMake(xofset, 0.0, 480.0, 320.0);
    
    [_InstructionSlidesScrollView scrollRectToVisible:rect animated:YES];
}

- (void)dealloc 
{
    [_InstructionSlidesScrollView release];
    _InstructionSlidesScrollView = nil;
    
    [_PageControl release];
    _PageControl = nil;
    
    [super dealloc];
}


@end
