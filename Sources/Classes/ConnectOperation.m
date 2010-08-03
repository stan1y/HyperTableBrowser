//
//  ConnectOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ConnectOperation.h"

@implementation ConnectOperation

@synthesize connectionInfo;
@synthesize connection;
@synthesize errorCode;

+ connectWithInfo:(ThriftConnectionInfo *)info
{
	ConnectOperation * conOp = [[ConnectOperation alloc] init];
	[conOp setConnectionInfo:info];
	return conOp;
}

- (void)dealloc 
{
	[connectionInfo release];
	[connection release];
	
	[super dealloc];
}

- (void)main
{
	if (connection) {
		[connection release];
	}
	connection = [[ThriftConnection alloc] init];
	NSLock * theLock = [[NSLock alloc] init];
	[connection setConnectionLock:theLock];
	[theLock release];
	
	NSLog(@"Opening connection thread to %s: port:%d\n", 
		  [[connectionInfo address] UTF8String], 
		  [connectionInfo port]);
	HTHRIFT th;
	int rc = create_thrift_client(&th, [[connectionInfo address] UTF8String], [connectionInfo port]);
	[self setErrorCode:rc];
	if (rc != T_OK) {
		NSLog(@"connectTo: error: create_thrift_client returned %d", rc);
	}
	else {
		HTHRIFT_HQL hql;
		rc = create_hql_client(&hql, [[connectionInfo address] UTF8String], [connectionInfo port]);
		[self setErrorCode:rc];
		
		if (rc != T_OK) {
			NSLog(@"Failed to connect with code %d, %s\n", rc,
				  [[ThriftConnection errorFromCode:rc] UTF8String]);
		}
		else {
			[connection setHqlClient:hql];
			[connection setThriftClient:th];
			[connection setConnInfo:connectionInfo];
			NSLog(@"Connected!\n");
		}
	}
}

@end
