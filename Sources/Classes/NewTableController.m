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
@synthesize schemasView;
@synthesize tableNameField;
@synthesize connection;

- (void) dealloc
{
	[schemasView release];
	[schemaContents release];
	[createButton release];
	[tableNameField release];
	[connection release];
	[super dealloc];
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
					onServer:(HyperTable *)connection
{
	[self indicateBusy];
	[self setMessage:@"Creating table..."];
	
	NSLog(@"Creating new table \"%s\" on %s\n", [tableName UTF8String],
		  [[connection ipAddress] UTF8String]);
	
	int rc = new_table([connection thriftClient], 
						  [tableName UTF8String], 
						  [schemaContent UTF8String]);
	[self indicateDone];
	
	if (rc != T_OK) {
		[self setMessage:[HyperTable errorFromCode:rc]];
		return;
	}
	//success
	[self setMessage:[NSString stringWithFormat:@"New table %s was successfully created",
					  [tableName UTF8String]]];
	//refresh tables on connection
	FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFrom:connection];
	[fetchTablesOp setCompletionBlock: ^ {
		NSLog(@"Refreshing tables on \"%s\"\n", [[[connection connInfo] address] UTF8String] );
		
		[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
		[[[NSApp delegate] serversView] deselectAll:self];
	}];
	
	//start fetching tables
	[[[NSApp delegate] operations] addOperation: fetchTablesOp];
	[fetchTablesOp release];
}

@end
