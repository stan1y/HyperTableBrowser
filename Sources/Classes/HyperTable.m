//
//  HyperTable.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HyperTable.h"
#import <FetchTablesOperation.h>
#import <ConnectOperation.h>

@implementation HyperTable

@synthesize thriftClient;
@synthesize hqlClient;
@synthesize connectionLock;

@synthesize ipAddress;
@synthesize port;

- (NSArray *)tables
{
	if (!tables) {
		NSLog(@"Tables were not updated ever yet.");
		return [NSArray array];
	}
	//make sure tables were updated right after conenction
	[connectionLock lock];
	NSArray * copy = [NSArray arrayWithArray:tables];
	[copy retain];
	[connectionLock unlock];
	return copy;
}

- (void) setTables:(NSArray *)array
{
	if ([connectionLock tryLock]) {
		NSLog(@"Connection is not locked for tables update!");
		return;
	}
	[tables release];
	tables = [NSMutableArray arrayWithArray:array];
	[tables retain];
}

+ (HyperTable *) hypertableAt:(NSString *)addr onPort:(int)aPort
{
	HyperTable * ht = [[HyperTable alloc] init];
	[ht setIpAddress:addr];
	[ht setPort:aPort];
	return ht;
}

- (id) init
{
	if (self = [super init] ) {
		connectionLock = [[NSLock alloc] init];
	}
	return self;
}

- (void) disconnect
{
	if ( ![self isConnected] ) {
		NSLog(@"disconnect: Not connected to %s:%d.", [ipAddress UTF8String], port);
		return;
	}
	destroy_thrift_client(thriftClient);
	destroy_hql_client(hqlClient);
}

- (void) refresh:(void (^)(void))codeBlock
{
	FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:self];
	[fetchTablesOp setCompletionBlock:codeBlock];
	
	NSLog(@"Refreshing tables...\n");
	//start fetching tables
	[[[NSApp delegate] operations] addOperation: fetchTablesOp];
	[fetchTablesOp release];
}

- (void) reconnect:(void (^)(void))codeBlock
{
	if ( [self isConnected] ) {
		NSLog(@"reconnect: Already connected to %s:%d.", [ipAddress UTF8String], port);
		return;
	}
	// check if auto reconnect enabled
	id tbrowserPrefs = [[[NSApp delegate] settingsManager] getSettingsByName:@"TablesBrowserPrefs"];
	if (!tbrowserPrefs) {
		[[NSApp delegate] showErrorDialog:1 
								  message:@"Failed to read Tabales Browser settings from storage." 
							   withReason:@"Please recreate HyperTableBrowser.xml"];
		return;
	}
	int autoReconnectBroker =  [[tbrowserPrefs valueForKey:@"autoReconnectBroker"] intValue];
	[tbrowserPrefs release];
	
	if ( autoReconnectBroker ) {
		//reconnect server with saved values
		NSLog(@"Automatic reconnect: Opening connection to HyperTable at %s:%d...", [ipAddress UTF8String], port);		
		ConnectOperation * connectOp = [ConnectOperation connect:self toBroker:ipAddress onPort:port];
		[connectOp setCompletionBlock:codeBlock];
		//add operation to queue
		[[[NSApp delegate] operations] addOperation: connectOp];
		[connectOp release];
	}
	else {
		NSLog(@"Automatic reconnect: Disabled.");
	}
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
	[super dealloc];
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
