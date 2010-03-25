//
//  ServersManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ServersManager.h"


@implementation ServersManager

- (void)reconnectServer:(NSManagedObject *)server {
	NSLog(@"Servers Manager : reconnectServer");
	
	//show connection dialog
	[[[NSApp delegate] connectionSheetController] showSheet:self 
							 toHost:[server valueForKey:@"hostname"] 
							andPort:38080];
}

- (NSArray *)getServers {
	NSLog(@"Servers Manager : getServers");
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[HyperTableServer entityDescription]];
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
	NSLog(@"Servers Manager : executeFetchRequest returned %d items", [serversArray count]);
	return serversArray;
}

- (HyperTableServer *)getServer:(NSString *)hostname {
	NSLog(@"Looking for server %s", [hostname UTF8String]);
	for (id srv in [self getServers]) {
		NSLog(@"Checking %s", [[srv valueForKey:@"hostname"] UTF8String]);
		if (strcmp([[srv valueForKey:@"hostname"] UTF8String],  [hostname UTF8String]) == 0) {
			NSLog(@"Found.");
			return srv;
		}
	}
	NSLog(@"Server not found.");
	return nil;
}

- (ThriftConnection *)getConnection:(NSString *)hostname {
	if (!connectionsCache) {
		return nil;
	}
	return [connectionsCache objectForKey:hostname];
}
- (ThriftConnection *)getConnectionForServer:(NSManagedObject *)server {
	return [self getConnection:[server valueForKey:@"hostname"]];
}

- (void)setConnection:(ThriftConnection *)connection 
			forServer:(NSManagedObject*)server
{
	NSLog(@"Servers Manager : setConnection");
	if (!connectionsCache) {
		NSLog(@"Initializing connections cache");
		connectionsCache = [[NSMutableDictionary alloc] init];
	}
	id hostname = [server valueForKey:@"hostname"];
	[connectionsCache setObject:connection forKey:hostname];
	NSLog(@"Set connection %s:%d for server: %s", [connection.connInfo.address UTF8String], 
		  connection.connInfo.port, 
		  [[server valueForKey:@"hostname"] UTF8String]);
}

@end
