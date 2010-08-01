//
//  ServersDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ServersDelegate.h"

@implementation ServersDelegate

@synthesize objectsPageSource;
@synthesize selectedServer;
@synthesize selectedTable;
@synthesize connectionController;

- (void)dealloc
{
	[objectsPageSource release];
	[connectionController release];
	[selectedServer release];
	[selectedTable release];
}

- (BOOL)outlineView:(NSOutlineView *)ov 
   shouldSelectItem:(id)item 
{	
	ToolBarController * toolbar = [[NSApp delegate] toolBarController];
	[item retain];
	BOOL doSelection = NO;
	
	if ([item class] == [NSManagedObject class]){
		NSLog(@"Server \"%s\" was selected\n", [[item valueForKey:@"ipAddress"] UTF8String]);
		//server node selected
		[self setSelectedServer:[item valueForKey:@"ipAddress"]];
		ThriftConnection * connection = [[[NSApp delegate] serversManager] getConnection:selectedServer];
		//allow new table
		if (connection) {
			NSLog(@"Connection to server is ready.\n");
			
			toolbar.allowNewTable = 1;
			toolbar.allowDropTable = 0;
			[[toolbar toolBar] validateVisibleItems];
			
			[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"HyperTable Browser @ %s", 
												 [[self selectedServer] UTF8String]] ];
			
			doSelection = YES;
		}
		else {
			NSLog(@"Server \"%s\" is NOT connected!\n", [[item valueForKey:@"ipAddress"] UTF8String]);
			
			toolbar.allowNewTable = 0;
			toolbar.allowDropTable = 0;
			[[toolbar toolBar] validateVisibleItems];
			
			doSelection = NO;
		}
	}
	else {
		NSString * serverAddress = [[ov parentForItem:item] valueForKey:@"ipAddress"];
		[self setSelectedServer:serverAddress];
		NSLog(@"Table \"%s\" from server \"%s\" was selected.\n", [item UTF8String],
			  [serverAddress UTF8String]);
		ThriftConnection * connection = [[[NSApp delegate] serversManager] getConnection:serverAddress];
		if (connection) {
			//table selected, so allow buttons in toolbar
			toolbar.allowNewTable = 1;
			toolbar.allowDropTable = 1;
			[self setSelectedTable:item];
			[self setSelectedServer:serverAddress];
			[[toolbar toolBar] validateVisibleItems];
			
			NSLog(@"Displaying first page of table %s\n", [item UTF8String]);
			[objectsPageSource showFirstPageFor:item fromConnection:connection];
			doSelection = YES;
		} else {
			NSLog(@"No connection to display data for table %s\n", [item UTF8String]);
			doSelection = NO;
		}
	}
	[item release];
	NSLog(@"Should select item: %d\n", doSelection);
	return doSelection;
}

@end
