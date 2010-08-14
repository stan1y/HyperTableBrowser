//
//  ClustersBrowserToolbarController.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClustersBrowserToolbarController.h"

@implementation ClustersBrowserToolbarController

@synthesize clustersBrowser;

- (IBAction)showPreferences:(id)sender
{	
	NSLog(@"Initializing preferences controllers.");
	//prepare preferences windows
	TablesBrowserSettings * tables = [[TablesBrowserSettings alloc] initWithNibName:@"TablesBrowserPreferences" 
																			 bundle:nil];
	ClustersBrowserSettings * clusters = [[ClustersBrowserSettings alloc] initWithNibName:@"ClustersBrowserPreferences" 
																				   bundle:nil];
	UpdateSettings * updates = [[UpdateSettings alloc] initWithNibName:@"UpdatesPreferences" 
																bundle:nil];
	
	
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:tables,
															clusters,
															updates,
															nil]];
	[tables release];
	[clusters release];
	[updates release];
	
	[[MBPreferencesController sharedController] showWindow:sender];
}

- (IBAction)showTablesBrowser:(id)sender
{
	[[[NSApp delegate] tablesBrowser] updateConnections:sender];
	[[[NSApp delegate] tablesBrowserWindow] orderFront:sender];
}

- (IBAction)showHqlInterpreter:(id)sender
{
	[[[NSApp delegate] hqlController] updateConnections:sender];
	[[[NSApp delegate] hqlWindow] orderFront:sender];
}

@end
