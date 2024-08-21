//
//  InstructionsViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstructionsViewController.h"
#import "InstructionsView.h"
#import "BattleInterfaceAppDelegate.h"
#import "UICommon.h"
#import "SoundCenter.h"

#define NUM_SLIDES		13
#define SLIDE_WIDTH		480.0
#define SLIDE_HEIGTH	320.0

@implementation InstructionsViewController

@synthesize _InstructionsView;

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	//removing mysterious subviews from the scrollview
	int i = 0;
	for (UIView * sss in [_InstructionsView._InstructionSlidesScrollView subviews])
	{
		NSLog(@"Removing scrollview subview: %i", i++);
		[sss removeFromSuperview];
	}

	//prepare scrollview for usage
	[_InstructionsView._InstructionSlidesScrollView setBackgroundColor:[UIColor blackColor]];
	[_InstructionsView._InstructionSlidesScrollView setCanCancelContentTouches:NO];
	_InstructionsView._InstructionSlidesScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	_InstructionsView._InstructionSlidesScrollView.clipsToBounds = YES;
	_InstructionsView._InstructionSlidesScrollView.scrollEnabled = YES;
	_InstructionsView._InstructionSlidesScrollView.pagingEnabled = YES;
	
    [_InstructionsView._InstructionSlidesScrollView setDelegate: _InstructionsView];
    
#ifdef LITE_ADMIRAL
    _InstructionsView._PageControl.numberOfPages = NUM_SLIDES + 1;
    
	//load num_slides
	NSUInteger I = 0;    
	for (; I <= NUM_SLIDES; I++)
	{
		NSString	*imageName = [NSString stringWithFormat:@"instr%d.png", I];
		UIImage		*image = [UIImage imageNamed:imageName];
		UIImageView *uiv = [[UIImageView alloc] initWithImage:image];
		
		CGRect frame = [uiv frame];
		CGPoint new_origin = CGPointMake(I * SLIDE_WIDTH, 0.0);
		CGSize new_size = CGSizeMake(SLIDE_WIDTH, SLIDE_HEIGTH);
		frame.origin = new_origin;
		frame.size = new_size;
		[uiv setFrame:frame];
		
		[_InstructionsView._InstructionSlidesScrollView addSubview:uiv];
		[uiv release];
	}	
	NSLog(@"%d instruction slides loaded", I);

    CGSize scrollSize = CGSizeMake(((NUM_SLIDES + 1) * SLIDE_WIDTH), SLIDE_HEIGTH);

#else       //********* FULL VERSION **********

    _InstructionsView._PageControl.numberOfPages = NUM_SLIDES;

	//load num_slides
	NSUInteger I = 1;    
	for (; I <= NUM_SLIDES; I++)
	{
		NSString	*imageName = [NSString stringWithFormat:@"instr%d.png", I];
		UIImage		*image = [UIImage imageNamed:imageName];
		UIImageView *uiv = [[UIImageView alloc] initWithImage:image];
		
		CGRect frame = [uiv frame];
		CGPoint new_origin = CGPointMake((I - 1) * SLIDE_WIDTH, 0.0);
		CGSize new_size = CGSizeMake(SLIDE_WIDTH, SLIDE_HEIGTH);
		frame.origin = new_origin;
		frame.size = new_size;
		[uiv setFrame:frame];
		
		[_InstructionsView._InstructionSlidesScrollView addSubview:uiv];
		[uiv release];
	}	
	NSLog(@"%d instruction slides loaded", I - 1);

    CGSize scrollSize = CGSizeMake((NUM_SLIDES * SLIDE_WIDTH), SLIDE_HEIGTH);
#endif

    //resize the scrollview to appropriate width
	[_InstructionsView._InstructionSlidesScrollView setContentSize:scrollSize];
	
}
 

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) handleBack:(id) sender
{
	NSLog(@"BackButton");
    
    [globalSoundCenter playEffect:SOUND_CLICK];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_NAME_POP_ME_ANIMATED
														object: nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}


@end
