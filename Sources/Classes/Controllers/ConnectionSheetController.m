//
//  ConnectionSheetController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/10/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ConnectionSheetController.h"

@implementation ConnectionSheetController

@synthesize serversView;

- (IBAction)cancelConnect:(id)sender {
	//initial sheet state
	[indicator setHidden:YES];
	[connectButton setTitle:@"Connect"];
	[statusField setHidden:YES];
	
	//reload servers view
	[serversView reloadItem:nil reloadChildren:YES];
	
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
	NSLog(@"Performing connection...");
	
	//update controls
	[connectButton setEnabled:NO];
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	[statusField setHidden:NO];
	[statusField setStringValue:@"Connecting..."];
	
	//trying to connect
	NSString * hostname = [addressField stringValue];
	int port = [portField intValue];
	
	//show progress and message
	
	//create or get server object
	ThriftConnection * connection = [[ThriftConnection alloc] init];
	ThriftConnectionInfo * serverInfo = [ThriftConnectionInfo infoWithAddress:hostname andPort:port];

	//connect
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		id msg = [connection connectTo:serverInfo];
		[serverInfo release];
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([connection thriftClient] == nil) {
				NSLog(@"Connection failed!");
				
				//failed
				[statusField setTextColor:[NSColor redColor]];
				[statusField setStringValue:msg];
				
				[indicator stopAnimation:self];
				[connectButton setEnabled:YES];
				[connectButton setTitle:@"Retry"];
			}
			else {
				NSLog(@"Connection successful!");
				
				[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"Objects Browser - %s", [hostname UTF8String]] ];
				[[NSApp delegate] setMessage: [NSString stringWithFormat:@"Connected to %s.", 
														 [hostname UTF8String]]];
				
				//new server or existing?
				HyperTableServer * connectedServer = [[[NSApp delegate] serversManager] getServer:hostname];
				
				if (connectedServer != nil) {
					NSLog(@"Updating connection to server %s", [hostname UTF8String]);
					//remove server from datestore
					[[[NSApp delegate] managedObjectContext] deleteObject:connectedServer];
					//save 
					NSError * error = nil;
					[[[NSApp delegate] managedObjectContext] save:&error];
					if (error) {
						[[NSApp delegate] setMessage:@"Failed to remove server from persistent store"];
					}
				}
				else {
					NSLog(@"Adding new server %s", [hostname UTF8String]);
				}
				
				connectedServer = [HyperTableServer serverWithDefaultContext];
				[[[NSApp delegate] managedObjectContext] insertObject:connectedServer];
				
				//update settings
				[connectedServer setValue:hostname forKey:@"hostname"];
				NSNumber * portNum = [NSNumber numberWithInt:port];
				[connectedServer setValue:portNum forKey:@"port"];
				[[[NSApp delegate] managedObjectContext] insertObject:connectedServer];
				
				//set connection
				[[[NSApp delegate] serversManager] setConnection:connection forServer:connectedServer];
				
				//save
				NSLog(@"Saving server");
				NSError * error = nil;
				[[[NSApp delegate] managedObjectContext] save:&error];
				if (error) {
					[[NSApp delegate] setMessage:@"Failed to add server to persistent store"];
				}
				
				//close sheet
				[connectionSheet orderOut:nil];
				[NSApp endSheet:connectionSheet];
				
				//read tables
				[connection refreshTables];
				
				//reload servers view
				[serversView reloadItem:nil reloadChildren:YES];
			}
		});
	});
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
