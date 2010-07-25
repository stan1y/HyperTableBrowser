//
//  ToolBarController.m
//
//  Created by Stanislav Yudin on 29/3/2010.
//  Copyright 2010 AwesomeStanlyLabs. All rights reserved.
//

#import "ToolBarController.h"

@implementation ToolBarController

@synthesize newTableBtn;
@synthesize dropTableBtn;

@synthesize toolBar;

@synthesize allowNewTable;
@synthesize allowDropTable;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	NSLog(@"validating toolbar item \"%s\"\n", [[toolbarItem label] UTF8String]);
    if ([toolbarItem isEqual:newTableBtn]) {
		return allowNewTable;
    } else if ( [toolbarItem isEqual:dropTableBtn]) {
		return allowDropTable;
    }
	else {
		return YES;
	}
}

- (void)awakeFromNib
{
	NSLog(@"Initializing ToolBar buttons\n");
	//prepare preferences window
	GeneralPreferencesController * general = [[GeneralPreferencesController alloc] initWithNibName:@"PreferencesGeneral" bundle:nil];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, nil]];
	[general release];
}

- (IBAction)showHideNewTable:(id)sender
{
	if ([[[NSApp delegate] newTablePnl] isVisible]) {
		[[[NSApp delegate] newTablePnl] orderOut:sender];
	}
	else {
		[[[NSApp delegate] newTableController] updateConnections:sender];
		[[[NSApp delegate] newTablePnl] orderFront:sender];
	}
}

- (IBAction)newTable:(id)sender
{
	if ([[[NSApp delegate] newTablePnl] isVisible]) {
		[[[NSApp delegate] newTablePnl] orderOut:sender];
	}
	else {
		[[[NSApp delegate] newTableController] updateConnections:sender];
		[[[NSApp delegate] newTablePnl] orderFront:sender];
	}
}


- (IBAction)dropTable:(id)sender
{
	NSLog(@"Going to drop table\n");
}

- (IBAction)showPreferences:(id)sender
{	
	[[MBPreferencesController sharedController] showWindow:sender];
}

- (IBAction)showHideHQL:(id)sender
{	
	if ([[[NSApp delegate] hqlInterpreterPnl] isVisible]) {
		[[[NSApp delegate] hqlInterpreterPnl] orderOut:sender];
	}
	else {
		[[[NSApp delegate] hqlController] updateConnections:sender];
		[[[NSApp delegate] hqlInterpreterPnl] orderFront:sender];
	}	
}

@end
