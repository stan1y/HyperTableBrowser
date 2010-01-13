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
	
	//close sheet
	[[NSApp delegate] setMessage:@"Connection canceled."];
	[connectionSheet orderOut:nil];
	[NSApp endSheet:connectionSheet];
}

- (IBAction)showConnectionSheet:(id)sender {
	//initial sheet state
	[indicator setHidden:YES];
	[statusField setHidden:YES];
	[connectButton setEnabled:YES];
	[connectButton setTitle:@"Connect"];
	
    [NSApp beginSheet:connectionSheet modalForWindow:[[NSApp delegate] window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)performConnect:(id)sender {
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
				//failed
				[statusField setTextColor:[NSColor redColor]];
				[statusField setStringValue:msg];
				
				[indicator stopAnimation:self];
				[connectButton setEnabled:YES];
				[connectButton setTitle:@"Retry"];
			}
			else {
				[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"Objects Browser - %s", [hostname UTF8String]] ];
				[[NSApp delegate] setMessage: [NSString stringWithFormat:@"Connected to %s.", 
														 [hostname UTF8String]]];
				
				//add connection
				[[[NSApp delegate] connectionsDict] setObject:connection forKey:hostname];
				
				//new server
				Server * newServer = [Server serverWithDefaultContext];
				[newServer setValue:hostname forKey:@"hostname"];
				NSNumber * portNum = [NSNumber numberWithInt:port];
				[newServer setValue:portNum forKey:@"port"];
				[[[NSApp delegate] managedObjectContext] insertObject:newServer];
				
				//get tables
				DataRow * row = row_new("Tables");
				get_tables_list([connection thriftClient], row);
				DataCellIterator * ci = cell_iter_new(row);
				DataCell * cell = NULL;
				do {
					cell = cell_iter_next_cell(ci);
					if (cell) {
						Table * newTable = [Table tableWithDefaultContext];
						[newTable setValue:[NSString stringWithCString:cell->cellValue 
															  encoding:NSUTF8StringEncoding] 
									forKey:@"name"];
						[newTable setValue:newServer forKey:@"server"];
						[[[NSApp delegate] managedObjectContext] insertObject:newTable];
					}
				} while (cell);
				free(ci);
				
				//save
				NSError * error = nil;
				[[[NSApp delegate] managedObjectContext] save:&error];
				if (error) {
					[[NSApp delegate] setMessage:@"Failed to add server to persistent store"];
				}
				
				//close sheet
				[connectionSheet orderOut:nil];
				[NSApp endSheet:connectionSheet];
				
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
