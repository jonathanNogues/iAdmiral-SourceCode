//
//  BattleInterfaceAppDelegate.m
//  BattleInterface
//
//  Created by Piotr Sarnowski on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BattleInterfaceAppDelegate.h"
#import "MainMenuViewController.h"
#import "SettingsContainer.h"
#import "Common.h"
#import "SoundCenter.h"

@implementation BattleInterfaceAppDelegate

@synthesize window;
@synthesize _MainMenuController;
@synthesize _NavigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	//hide status bar
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
    //and navigation bar
	[_NavigationController setNavigationBarHidden:YES];	
	[_NavigationController.navigationBar setTranslucent:YES];
	
	//create settings
	AppWideSettings = [[SettingsContainer alloc] init];
	[AppWideSettings restoreFromUserDefaults];
    [AppWideSettings saveToUserDefaults];
    
    //create the sound center
	globalSoundCenter = [[SoundCenter alloc] initWithMusic: AppWideSettings._PlayMusic
												  andSound: AppWideSettings._PlaySounds ];
	
    // Add the view controller's view to the window and display.
	[self.window addSubview:_NavigationController.view];
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    NSLog(@"iAdmiral: Will resign active!");
    
    //this should pause the game - and is called before the app quits
    //and when breaks happen - like when there is a phone call
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_PAUSE_BI object:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    NSLog(@"iAdmiral: Did Enter Background!");
    
    //this gets called of pressing the home button - so this probably be the place to unload battleinterface...
    //after saving the data
    //and enter main menu!
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_QUIT_BI object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */

    NSLog(@"iAdmiral: will enter foreground!");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSLog(@"iAdmiral: did become active!");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NAME_UNPAUSE_BI object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    NSLog(@"iAdmiral: will terminate!");
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[_MainMenuController release];
	[_NavigationController release];
	
	[AppWideSettings release];
	
    [window release];
    [super dealloc];
}


@end
