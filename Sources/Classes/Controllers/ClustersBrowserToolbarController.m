//
//  ClustersBrowserToolbarController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClustersBrowserToolbarController.h"

@implementation ClustersBrowserToolbarController

@synthesize clustersBrowser;

- (IBAction)showPreferences:(id)sender
{	
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

//- (IBAction)showInspector:(id)sender;
//- (IBAction)showUserGroupManager:(id)sender;
//- (IBAction)refreshClusters:(id)sender;

- (IBAction)showConnectionSheet:(id)sender
{
	[[[self clustersBrowser] connectionSheetController] showSheet:sender 
														 modalFor:[[self clustersBrowser] window]];
}

@end
