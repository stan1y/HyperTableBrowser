//
//  NewTableController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 25/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "NewTableController.h"

@implementation NewTableController

@synthesize schemaContents;
@synthesize createButton;
@synthesize serverSelector;
@synthesize schemasView;
@synthesize indicator;
@synthesize statusField;
@synthesize tableNameField;

- (void)windowWillClose:(NSNotification *)notification
{
	//save schemas if any
	[[NSApp delegate] saveAction:self];
	//reload servers and tables
	[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
}

- (void)setMessage:(NSString*)message {
	NSLog(@"New Table: %s\n", [message UTF8String]);
	[statusField setTitleWithMnemonic:message];
}

- (void)indicateBusy {
	[indicator setHidden:NO];
	[indicator startAnimation:self];
}

- (void)indicateDone {
	[indicator stopAnimation:self];
	[indicator setHidden:YES];
}

- (IBAction)createTable:(id)sender
{
	if ([[schemaContents stringValue] length] <= 0) {
		[self indicateDone];
		[self setMessage:@"Empty schema!"];
		return;
	}
	
	id con = [self getSelectedConnection];
	if (!con) {
		[self setMessage:@"You are not connected to selected server. Please reconnect."];
		[self indicateDone];
		return;
	}
	[self createTableWithName:[tableNameField stringValue]
					   andSchema:[schemaContents stringValue]
					 onServer:con];
}

- (void) createTableWithName:(NSString *)tableName
				   andSchema:(NSString*)schemaContent
					onServer:(ThriftConnection *)connection
{
	[self indicateBusy];
	[self setMessage:@"Creating table..."];
	
	NSLog(@"Creating new table \"%s\" on %s\n", [tableName UTF8String],
		  [connection.connInfo.address UTF8String]);
	
	int rc = new_table([connection thriftClient], 
						  [tableName UTF8String], 
						  [schemaContent UTF8String]);
	[self indicateDone];
	
	if (rc != T_OK) {
		[self setMessage:[ThriftConnection errorFromCode:rc]];
		return;
	}
	//success
	[self setMessage:[NSString stringWithFormat:@"New table %s was successfully created",
					  [tableName UTF8String]]];
	//refresh tables on connection
	FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:connection];
	[fetchTablesOp setCompletionBlock: ^ {
		NSLog(@"Refreshing tables on \"%s\"\n", [[[connection connInfo] address] UTF8String] );
		
		[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
		[[[NSApp delegate] serversView] deselectAll:self];
	}];
	
	//start fetching tables
	[[[NSApp delegate] operations] addOperation: fetchTablesOp];
	[fetchTablesOp release];
}

- (IBAction)updateConnections:(id)sender
{
	[self setMessage:@"Updating connections..."];
	[self indicateBusy];
	//populate selector
	id serversArray = [[[NSApp delegate] serversManager] getServers];
	[serverSelector removeAllItems];
	for (id server in serversArray) {
		id serverLabel = nil;
		if ( [server valueForKey:@"name"] ) {
			serverLabel = [server valueForKey:@"name"];
		}
		else {
			serverLabel = [server valueForKey:@"ipAddress"];
		}

		[serverSelector addItemWithTitle:serverLabel];
	}
	if ([serversArray count] <= 0) {
		[self setMessage:@"No servers available. Please connect to at least one server."];
		[serverSelector setEnabled:NO];
		[createButton setEnabled:NO];
	}
	else {
		[serverSelector setEnabled:YES];
		[createButton setEnabled:YES];
		[self setMessage:[NSString stringWithFormat:@"%d server(s) available", [serversArray count]] ];
	}
	[self indicateDone];
	[serversArray release];
}

- (id)getSelectedConnection 
{
	if (![[serverSelector itemArray] count] < 0) {
		[self setMessage:@"There are no connected servers. You need to establish connection before creating new tables."];
		return nil;
	}
	
	return [ [[NSApp delegate] serversManager] getConnection:[[serverSelector selectedItem] title] ];
}

@end
