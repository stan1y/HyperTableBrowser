//
//  ConnectionSheetController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/10/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ConnectionSheetController.h"

@implementation ConnectionSheetController

- (IBAction)cancelConnect:(id)sender {
	//initial sheet state
	[indicator setHidden:YES];
	[connectButton setTitle:@"Connect"];
	[statusField setHidden:YES];
	
	//remove server from view if it
	//was an attempt to reconnect
	NSString * address = [addressField stringValue];
	id srv = [[[NSApp delegate] serversManager] getServer:address ];
	if (srv) {
		NSLog(@"Removing server %s from view. Reconnect was canceled.", [address UTF8String]);
		
		NSError * error = nil;
		[[[NSApp delegate] managedObjectContext] deleteObject:srv];
		[[[NSApp delegate] managedObjectContext] save:&error];
		if (error) {
			[[NSApp delegate] setMessage:@"Failed to remove server from persistent store"];
		}
		
		//reload servers view
		[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
	}

	
	//close sheet
	[[NSApp delegate] setMessage:@"Connection canceled."];
	[connectionSheet orderOut:nil];
	[NSApp endSheet:connectionSheet];
}

- (IBAction)showSheet:(id)sender 
			   toHost:(NSString *)host 
			  andPort:(int)port
{
	[addressField setStringValue:host];
	[portField setIntValue:port];
	
	[self showSheet:self];
}

- (IBAction)showSheet:(id)sender {
	//initial sheet state
	[indicator setHidden:YES];
	[statusField setHidden:YES];
	[connectButton setEnabled:YES];
	[connectButton setTitle:@"Connect"];
	
	NSLog(@"Displaying connection dialog to %s:%d", 
		  [[addressField stringValue] UTF8String],
		  [portField intValue]);
	
    [NSApp beginSheet:connectionSheet modalForWindow:[[NSApp delegate] window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)performConnect:(id)sender {
	NSLog(@"Connection sheet: Performing connection...\n");
	
	//update controls
	[connectButton setEnabled:NO];
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	[statusField setHidden:NO];
	[statusField setStringValue:@"Connecting..."];
	
	//trying to connect
	NSString * address = [addressField stringValue];
	int port = [portField intValue];
	
	ThriftConnectionInfo * serverInfo = [ThriftConnectionInfo infoWithAddress:address andPort:port];
	ConnectOperation * connectOp = [ConnectOperation connectWithInfo:serverInfo];

	[connectOp setCompletionBlock: ^ {
		
		NSLog(@"Connection sheet: operation completed.\n");
		if ( ![[connectOp connection] isConnected] ) {
			NSLog(@"Connect: Connection failed!\n");
			
			//failed
			[statusField setTextColor:[NSColor redColor]];
			[statusField setStringValue:[ThriftConnection errorFromCode:[connectOp errorCode]]];
			
			[indicator stopAnimation:self];
			[connectButton setEnabled:YES];
			[connectButton setTitle:@"Retry"];
		}
		else {
			NSLog(@"Connect: Connection successful!");
			
			[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"HyperTable Browser @ %s", [address UTF8String]] ];
			[[NSApp delegate] setMessage: [NSString stringWithFormat:@"Connected to %s.", 
										   [address UTF8String]]];
			
			//new server or existing?
			id connectedServer = [[[NSApp delegate] serversManager] getServer:address];
			if (connectedServer != nil) {
				NSLog(@"Connect: Updating connection to server %s", [address UTF8String]);
				//update settings
				[connectedServer setValue:address forKey:@"ipAddress"];
				NSNumber * portNum = [NSNumber numberWithInt:port];
				[connectedServer setValue:portNum forKey:@"port"];
			}
			else {
				NSLog(@"Connect: Adding new server %s", [address UTF8String]);
				
				//add new server
				connectedServer = [HyperTableServer serverWithDefaultContext];
				[connectedServer setValue:address forKey:@"ipAddress"];
				NSNumber * portNum = [NSNumber numberWithInt:port];
				[connectedServer setValue:portNum forKey:@"port"];
				[[[NSApp delegate] managedObjectContext] insertObject:connectedServer];
				[[NSApp delegate] saveAction:self];
			}
			//set connection
			[[[NSApp delegate] serversManager] setConnection:[connectOp connection] forServer:connectedServer];
			
			//close sheet
			[connectionSheet orderOut:nil];
			[NSApp endSheet:connectionSheet];
			
			//fetch tables for new connection
			FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:[connectOp connection]];
			[fetchTablesOp setCompletionBlock: ^ {
				NSLog(@"Updaing servers & tables tree...\n");
				[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
				int serverIndex = [[[NSApp delegate] serversView] rowForItem:connectedServer];
				[[[NSApp delegate] serversView] selectRowIndexes:[NSIndexSet indexSetWithIndex:serverIndex]
											byExtendingSelection:NO];
				[[[NSApp delegate] toolBarController] setAllowNewTable:1];
				[[[[NSApp delegate] toolBarController] toolBar] validateVisibleItems];
			}];
			
			//start fetching tables
			[[[NSApp delegate] operations] addOperation: fetchTablesOp];
			[fetchTablesOp release];
		}
	} ];
	
	//add operation to queue
	[[[NSApp delegate] operations] addOperation: connectOp];
	[connectOp release];
}

/* ComboBox auto-complete */

//Returns the first item from the pop-up list that starts with the text the user has typed.
- (NSString *)comboBox:(NSComboBox *)aComboBox
	   completedString:(NSString *)uncompletedString
{
}

//Returns the index of the combo box item matching the specified string.
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
}

/* ComboBox datasource */

//Returns the object that corresponds to the item at the specified index in the combo box.
- (id)comboBox:(NSComboBox *)aComboBox
objectValueForItemAtIndex:(NSInteger)index
{
}

//Returns the number of items that the data source manages for the combo box.
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
}

@end
