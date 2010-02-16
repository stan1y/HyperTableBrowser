//
//  ServersManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ServersManager.h"


@implementation ServersManager

- (void)reconnectServer:(HyperTableServer *)server {
	//remove tables from datestore
	NSSet * tables = [server valueForKey:@"tables"];
	for (id table in tables) {
		NSLog(@"Removing table %s", [[table valueForKey:@"name"] UTF8String]);
		[[[NSApp delegate] managedObjectContext] deleteObject:table];
	}
	//save removed items
	NSError * error = nil;
	[[[NSApp delegate] managedObjectContext] save:&error];
	if (error) {
		[[NSApp delegate] setMessage:@"Failed to remove tables from persistent store"];
	}
	
	//show connection dialog
	[[[NSApp delegate] connectionSheetController] showSheet:self 
							 toHost:[server valueForKey:@"hostname"] 
							andPort:38080];
}

- (NSArray *)getServers {
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[HyperTableServer entityDescription]];
	NSError * err = nil;
	NSArray * serversArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	[r release];
	if (err) {
		NSString * msg = @"getServers: Failed to get servers from datastore";
		NSLog(@"Error: %s", [msg UTF8String]);
		[err release];
		return nil;
	}
	[err release];
	return serversArray;
}

- (HyperTableServer *)getServer:(NSString *)hostname {
	NSLog(@"Looking for server %s", [hostname UTF8String]);
	for (id srv in [self getServers]) {
		if ([srv valueForKey:@"hostname"] == hostname) {
			NSLog(@"Found.");
			return srv;
		}
	}
	NSLog(@"Not found.");
	return nil;
}

- (ThriftConnection *)getConnection:(NSString *)hostname {
	if (!connectionsCache) {
		return nil;
	}
	return [connectionsCache objectForKey:hostname];
}
- (ThriftConnection *)getConnectionForServer:(HyperTableServer *)server {
	return [self getConnection:[server valueForKey:@"hostname"]];
}

- (void)setConnection:(ThriftConnection *)connection 
			forServer:(HyperTableServer*)server
{
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
