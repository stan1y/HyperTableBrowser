//
//  HyperTable.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HyperTable.h"
#import <FetchTablesOperation.h>

@implementation HyperTable

@synthesize thriftClient;
@synthesize hqlClient;
@synthesize connectionLock;

@synthesize ipAddress;
@synthesize port;

+ (HyperTable *) hypertableAt:(NSString *)addr onPort:(in)aPort
{
	HyperTable * ht = [[HyperTable alloc] init];
	[ht setIpAddress:addr];
	[ht setPort:aPort];
	[ht reconnect];
}

- (id) init
{
	[super init];
	connectionLock = [[NSLock alloc] init];
	return self;
}

- (void) reconnect
{
	// check if auto reconnect enabled
	id generalPrefs = [[[NSApp delegate] settingsManager] getSettingsByName:@"GeneralPrefs"];
	if (!generalPrefs) {
		[[NSApp delegate] showErrorDialog:1 
								  message:@"Failed to read general preferences from storage." 
							   withReason:@"Please recreate HyperTableBrowser.xml"];
		return;
	}
	int autoReconnectServer =  [[generalPrefs valueForKey:@"autoReconnectServer"] intValue];
	[generalPrefs release];
	
	if ( autoReconnectServer ) {
		//reconnect server with saved values
		NSLog(@"Automatic reconnect: Opening connection to HyperTable at %s:%d...", [ipAddress UTF8String], port);		
		ConnectOperation * connectOp = [ConnectOperation connectTo:ipAddress onPort:port];
		[connectOp setCompletionBlock: ^ {
			NSLog(@"Automatic reconnect: Operation complete.\n");
			if ( ![[connectOp connection] isConnected] ) {
				[[NSApp delegate] indicateDone];
				NSLog(@"Automatic reconnect: Reconnect failed!\n");
			}
			else {
				NSLog(@"Automatic reconnect: Connection successful!");
				
				//update tables
				FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:[connectOp connection]];
				[fetchTablesOp setCompletionBlock: ^ {
					if ([fetchTablesOp errorCode] != 0) {
						NSLog(@"Error: Failed to update tables from Hypertable!");
					}
					else {
						NSLog(@"Automatic reconnect: Updated tables sucessfully.");
						/*
						[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
						int serverIndex = [[[NSApp delegate] serversView] rowForItem:server];
						[[[NSApp delegate] serversView] selectRowIndexes:[NSIndexSet indexSetWithIndex:serverIndex]
													byExtendingSelection:NO];
						[[[NSApp delegate] toolBarController] setAllowNewTable:1];
						[[[NSApp delegate] toolBarController] setAllowRefresh:1];
						[[[[NSApp delegate] toolBarController] toolBar] validateVisibleItems];
						*/
					}
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
		NSLog(@"Automatic reconnect: Disabled.");
	}
}

- (NSMutableArray *)tables 
{ 
	return tables;
}

- (void) dealloc
{
	[tables release];
	[connectionLock release];
	
	if (thriftClient) {
		free(thriftClient);
		thriftClient = nil;
	}
	
	if (hqlClient) {
		free(hqlClient);
		hqlClient = nil;
	}
}

-(void) setTables:(NSMutableArray *)newTables
{
	if (newTables) {
		[tables release];
		tables = newTables;
	}
}

+ (NSString *)errorFromCode:(int)code {
	switch (code) {
		case T_ERR_CLIENT:
			return @"Failed to execute. Check syntax.";
			break;
		case T_ERR_TRANSPORT:
			return @"Connection failed. Check Thrift broker is running.";
			break;
		case T_ERR_NODATA:
			return @"No data returned from query, where is was expected to.";
			break;
		case T_ERR_TIMEOUT:
			return @"Operation timeout. Check HyperTable is running correctly.";
			break;
		case T_ERR_APPLICATION:
			return @"System error occured. Either your HyperTable server is incompatible with this client application or it had experienced problem service the request";
			break;
			
		case T_OK:
		default:
			return @"Executed successfuly.";
			break;
	}
}

- (BOOL)isConnected {
	return ( (thriftClient != nil) && (hqlClient != nil) );
}

@end
