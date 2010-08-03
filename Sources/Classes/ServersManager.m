//
//  ServersManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ServersManager.h"


@implementation ServersManager

- (void)dealloc
{
	[connectionsCache release];
	[super dealloc];
}

- (id)init
{
	[super init];
	NSLog(@"Initializing connections cache");
	connectionsCache = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)reconnectServer:(NSManagedObject *)server {
	[server retain];
	NSString * address = [server valueForKey:@"ipAddress"];
	int port  = [[server valueForKey:@"port"] intValue];
	
	id generalPrefs = [[NSApp delegate] getSettingsByName:@"GeneralPrefs"];
	if (!generalPrefs) {
		[[NSApp delegate] setMessage:@"Failed to read general preferences from storage. Please recreate HyperTableBrowser.xml"];
		return;
	}
	int autoReconnectServer =  [[generalPrefs valueForKey:@"autoReconnectServer"] intValue];
	[generalPrefs release];
	if ( autoReconnectServer ) {
		//reconnect server with saved values
		NSLog(@"Autoreconnecting server \"%s:%d\"\n", [address UTF8String], port);
		[[NSApp delegate] indicateBusy];
		[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Reconnecting to server %s...",
									  [address	UTF8String]]];
		
		ThriftConnectionInfo * serverInfo = [ThriftConnectionInfo infoWithAddress:address
																		  andPort:port];
		ConnectOperation * connectOp = [ConnectOperation connectWithInfo:serverInfo];
		[connectOp setCompletionBlock: ^ {
			[[NSApp delegate] indicateDone];
			NSLog(@"Automatic reconnect: Operation complete.\n");
			if ( ![[connectOp connection] isConnected] ) {
				[[NSApp delegate] indicateDone];
				NSLog(@"Automatic reconnect: Connection failed!\n");
				[[NSApp delegate] setMessage: @"Failed to automatically reconnect to server."];
				
				//maybe user wants to connect with other port or address
				//show connection sheet for that
				[[[NSApp delegate] connectionSheetController] showSheet:self
																 toHost:address
																andPort:port];
			}
			else {
				NSLog(@"Automatic reconnect: Connection successful!");
				
				[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"HyperTable Browser @ %s", [address UTF8String]] ];
				[[NSApp delegate] setMessage: [NSString stringWithFormat:@"Connected to %s.", 
											   [address UTF8String]]];
				
				//set connection
				[[[NSApp delegate] serversManager] setConnection:[connectOp connection] forServer:server];
				
				//fetch tables for new connection
				FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:[connectOp connection]];
				[fetchTablesOp setCompletionBlock: ^ {
					NSLog(@"Automatic reconnect: Updaing servers & tables tree...\n");
					[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
					int serverIndex = [[[NSApp delegate] serversView] rowForItem:server];
					[[[NSApp delegate] serversView] selectRowIndexes:[NSIndexSet indexSetWithIndex:serverIndex]
												byExtendingSelection:NO];
					[[[NSApp delegate] toolBarController] setAllowNewTable:1];
					[[[NSApp delegate] toolBarController] setAllowRefresh:1];
					[[[[NSApp delegate] toolBarController] toolBar] validateVisibleItems];
				}];
				
				NSLog(@"Automatic reconnect: Refreshing tables...\n");
				//start fetching tables
				[[[NSApp delegate] operations] addOperation: fetchTablesOp];
				[fetchTablesOp release];
			}
		} ];
		
		//add operation to queue
		[[[NSApp delegate] operations] addOperation: connectOp];
		[connectOp release];
	}
	else {
		NSLog(@"Reconnecting server \"%s\"\n", [address UTF8String]);
		//show connection dialog
		[[[NSApp delegate] connectionSheetController] showSheet:self
														 toHost:address
														andPort:port];
	}
	[server release];
}

- (NSArray *)getServers {
	NSLog(@"Reading saved servers\n");
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[NSEntityDescription entityForName:@"HyperTableServer" 
							 inManagedObjectContext:[[NSApp delegate] managedObjectContext]]];
	[r setIncludesPendingChanges:YES];
	NSError * err = nil;
	NSArray * serversArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSString * msg = @"getServers: Failed to get servers from datastore";
		NSLog(@"Error: %s", [msg UTF8String]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	NSLog(@"There are %d servers stored.\n", [serversArray count]);
	return [serversArray retain];
}

- (NSManagedObject *)getServer:(NSString *)ipAddress {
	NSArray * servers = [self getServers];
	for (id srv in servers) {
		if (strcmp([[srv valueForKey:@"ipAddress"] UTF8String],  [ipAddress UTF8String]) == 0) {
			[srv retain];
			[servers release];
			return srv;
		}
	}
	[servers release];
	NSLog([NSString stringWithFormat:@"Server \"%s\" not found.",
		   [ipAddress UTF8String]]);
	return nil;
}

- (ThriftConnection *)getConnection:(NSString *)ipAddress {
	if (!connectionsCache) {
		return nil;
	}
	return [connectionsCache objectForKey:ipAddress];
}
- (ThriftConnection *)getConnectionForServer:(NSManagedObject *)server {
	return [self getConnection:[server valueForKey:@"ipAddress"]];
}

- (void)setConnection:(ThriftConnection *)connection 
			forServer:(NSManagedObject *)server
{
	id ipAddress = [server valueForKey:@"ipAddress"];
	[connectionsCache setObject:connection forKey:ipAddress];
	NSLog(@"Updaing cache with connection \"%s:%d\" for server \"%s\"", [connection.connInfo.address UTF8String], 
		  connection.connInfo.port, 
		  [[server valueForKey:@"ipAddress"] UTF8String]);
}

@end
