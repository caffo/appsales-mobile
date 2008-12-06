//
//  AppSalesMobileAppDelegate.m
//  AppSalesMobile
//
//  Created by Ole Zorn on 30.10.08.
//  Copyright omz:software 2008. All rights reserved.
//

#import "AppSalesMobileAppDelegate.h"
#import "RootViewController.h"


@implementation AppSalesMobileAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
	
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
