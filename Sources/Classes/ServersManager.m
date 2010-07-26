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
	NSLog(@"Reconnecting server \"%s\"\n", [[server valueForKey:@"ipAddress"] UTF8String]);
	
	//show connection dialog
	[[[NSApp delegate] connectionSheetController] showSheet:self 
							 toHost:[server valueForKey:@"ipAddress"] 
							andPort:38080];
}

- (NSArray *)getServers {
	NSLog(@"Reading saved servers\n");
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
	NSLog(@"There are %d servers stored.\n", [serversArray count]);
	return serversArray;
}

- (HyperTableServer *)getServer:(NSString *)ipAddress {
	NSLog(@"Looking for server \"%s\"", [ipAddress UTF8String]);
	for (id srv in [self getServers]) {
		NSLog(@"Checking %s", [[srv valueForKey:@"ipAddress"] UTF8String]);
		if (strcmp([[srv valueForKey:@"ipAddress"] UTF8String],  [ipAddress UTF8String]) == 0) {
			NSLog(@"Found.");
			return srv;
		}
	}
	NSLog(@"Server not found.");
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
			forServer:(NSManagedObject*)server
{
	if (!connectionsCache) {
		NSLog(@"Initializing connections cache");
		connectionsCache = [[NSMutableDictionary alloc] init];
	}
	id ipAddress = [server valueForKey:@"ipAddress"];
	[connectionsCache setObject:connection forKey:ipAddress];
	NSLog(@"Updaing cache with connection \"%s:%d\" for server \"%s\"", [connection.connInfo.address UTF8String], 
		  connection.connInfo.port, 
		  [[server valueForKey:@"ipAddress"] UTF8String]);
}

@end
