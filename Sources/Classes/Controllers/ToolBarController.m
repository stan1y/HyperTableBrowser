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
    if ([toolbarItem isEqual:newTableBtn]) {
		NSLog(@"allowNewTable: %d\n", allowNewTable);
		return allowNewTable;
    } else if ( [toolbarItem isEqual:dropTableBtn]) {
		NSLog(@"allowDropTable: %d\n", allowDropTable);
		return allowDropTable;
    }
	
	return YES;
}

- (void)awakeFromNib
{
	NSLog(@"Initializing ToolBar buttons\n");
	//prepare preferences window
	GeneralPreferencesController * general = [[GeneralPreferencesController alloc] initWithNibName:@"PreferencesGeneral" bundle:nil];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, nil]];
	[general release];
}


- (IBAction)newTable:(id)sender
{
	id pnl = [[NSApp delegate] newTablePnl];
	if ([pnl isVisible]) {
		[pnl orderOut:sender];
	}
	else {
		id cntl = [[NSApp delegate] newTableController];
		[cntl updateConnections:sender];
		[pnl orderFront:sender];
	}
	[pnl release];
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
	id pnl = [[NSApp delegate] hqlInterpreterPnl];
	if ([pnl isVisible]) {
		[[[NSApp delegate] hqlInterpreterPnl] orderOut:sender];
	}
	else {
		id cntrl = [[NSApp delegate] hqlController];
		[cntrl updateConnections:sender];
		[[[NSApp delegate] hqlInterpreterPnl] orderFront:sender];
	}
	[pnl release];
}

@end
