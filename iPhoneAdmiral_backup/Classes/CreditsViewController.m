//
//  CreditsViewController.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreditsViewController.h"
#import "CreditsView.h"
#import "UICommon.h"
#import "SoundCenter.h"

@implementation CreditsViewController

@synthesize _CreditsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    _CreditsView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL) animated
{
    [globalSoundCenter playEffect:SOUND_SCREEN_CHANGE];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL) animated
{
    if (animated) [globalSoundCenter playEffect:SOUND_SCREEN_CHANGE];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    static BOOL first_run = YES;
    
    if (first_run)
    {
        [_CreditsView setImage:[UIImage imageNamed:@"CreditsBG.png"]];
        first_run = NO;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
