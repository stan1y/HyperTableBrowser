//
//  ServersSource.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 1/13/10.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ServersSource.h"

@implementation ServersSource

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if (item) {
		NSLog(@"Displaying table %d of server %s", index, [[item valueForKey:@"hostname"] UTF8String]);
		//displaying tables
		NSSet * tables = [item valueForKey:@"tables"];
		int i = 0;
		for (id table in tables) {
			if (i == index ) {
				return table;
			}
			i++;
		}
		NSLog(@"Error: Failed to find table with index %d", index);
		return nil;
	}
	else {
		//displaying servers
		id servers = [[[NSApp delegate] serversManager] getServers];
		id srv = [servers objectAtIndex:index];
		NSLog(@"Displaying server at index %d", index);
		return srv;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	//server class is expandable
	if (item && [item entity] == [HyperTableServer entityDescription]) {
		NSLog(@"Server is expandable");
		return YES;
	}
	else {
		NSLog(@"Table is not expandable");
		return NO;
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
	NSLog(@"Reading number of servers/tables");
	@try {
		//request for item
		if (item) {
			NSLog(@"Getting tables of server %s", [[item valueForKey:@"hostname"] UTF8String]);
			//return number of tables in server item
			int tablesCount = 0;
			tablesCount = [[item valueForKey:@"tables"] count];
			if (tablesCount <= 0) {
				NSLog(@"Requesting tables list");
				
				//get tables
				DataRow * row = row_new("Tables");
				id connection = [ [[NSApp delegate] serversManager] getConnectionForServer:item];
				if (!connection || ![connection isConnected]) {
					NSLog(@"Error: Connection is NOT READY for tables list update");
					[[[NSApp delegate] serversManager] reconnectServer:item];
					return 0;
				}
				
				//read tables
				get_tables_list([connection thriftClient], row);
				DataCellIterator * ci = cell_iter_new(row);
				DataCell * cell = NULL;
				do {
					cell = cell_iter_next_cell(ci);
					if (cell) {
						HyperTable * newTable = [HyperTable tableWithDefaultContext];
						[newTable setValue:[NSString stringWithCString:cell->cellValue 
															  encoding:NSUTF8StringEncoding] 
									forKey:@"name"];
						[newTable setValue:item forKey:@"server"];
						[[[NSApp delegate] managedObjectContext] insertObject:newTable];
					}
				} while (cell);
				free(ci);
				
				NSLog(@"Saving tables list");
				NSError * error = nil;
				[[[NSApp delegate] managedObjectContext] save:&error];
				if (error) {
					[[NSApp delegate] setMessage:@"Failed to save tables to persistent store"];
					return 0;
				}
				//get number of added tables
				tablesCount = [[item valueForKey:@"tables"] count];
			}
			NSLog(@"%d tables found on server %s", tablesCount, [[item valueForKey:@"hostname"] UTF8String]);
			return tablesCount;
		}
		//request for list of servers
		int serversCount = [ [ [[NSApp delegate] serversManager] getServers] count];
		NSLog(@"Servers in datastore %d", serversCount);
		//return number of servers
		return serversCount;
	}
	@catch(NSException * ex) {
		NSLog(@"Failed to query tables from datastore");
		return 0;
	}
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item
{
	NSLog(@"Getting object value");
	if (item) {
		//return hostname of server or name of table
		if ([item entity] == [HyperTableServer entityDescription]) {
			NSLog(@"Server object value");
			NSLog(@"%s", [[item valueForKey:@"hostname"] UTF8String]);
			return [item valueForKey:@"hostname"];
		}
		else if ([item entity] == [HyperTable entityDescription]) {
			NSLog(@"Table object value");
			NSLog(@"%s", [[item valueForKey:@"name"] UTF8String]);
			return [item valueForKey:@"name"];
		}
		else
			return @"Unknown";
	}
	return @"Nothing";
}

@end
