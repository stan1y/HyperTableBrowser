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
		return allowNewTable;
    } else if ( [toolbarItem isEqual:dropTableBtn]) {
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
	NSString * selectedTable = [[[NSApp delegate] serversDelegate] selectedTable];
	NSString * selectedServerAddress = [[[NSApp delegate] serversDelegate] selectedServer];
	NSLog([NSString stringWithFormat:@"Dropping table \"%s\" from server \"%s\".", 
		   [selectedTable UTF8String],
		   [selectedServerAddress UTF8String]]);
	
	id connection = [[[NSApp delegate] serversManager] getConnection:selectedServerAddress];
	if (!connection) {
		[[NSApp delegate] setMessage:@"Cannot drop table. Server is NOT connected."];
		return;
	}
	[[NSApp delegate] indicateBusy];
	int rc = drop_table([connection thriftClient], [selectedTable UTF8String]);

	if (rc != T_OK) {
		[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Failed to drop table \"%s\". %s",
									  [selectedTable UTF8String],
									  [[ThriftConnection errorFromCode:rc] UTF8String]]];
		[[NSApp delegate] indicateDone];
	}
	else {
		NSString * msg = [NSString stringWithFormat:@"Table \"%s\" was dropped.",
						  [selectedTable UTF8String]];
	
		//refresh tables on connection
		FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:connection];
		[fetchTablesOp setCompletionBlock: ^ {
			NSLog(@"Refreshing tables on \"%s\"\n", [[[connection connInfo] address] UTF8String] );
			
			[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
			[[[NSApp delegate] serversView] deselectAll:self];
			
			[[NSApp delegate] setMessage:msg];
			[[NSApp delegate] indicateDone];
		}];
		
		//start fetching tables
		[[[NSApp delegate] operations] addOperation: fetchTablesOp];
		[fetchTablesOp release];
	}
	
	[selectedTable release];
	[selectedServerAddress release];
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
