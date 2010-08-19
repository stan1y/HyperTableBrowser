//
//  ConnectOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ConnectOperation.h"

@implementation ConnectOperation

@synthesize ipAddress;
@synthesize port;

@synthesize hypertable;
@synthesize errorCode;

+ connect:(HyperTable *)hypertable toBroker:(NSString *)address onPort:(int)port;
{
	ConnectOperation * conOp = [[ConnectOperation alloc] init];
	[conOp setIpAddress:address];
	[conOp setPort:port];
	[conOp setHypertable:hypertable];
	return conOp;
}

- (void)dealloc 
{
	[ipAddress release];
	[super dealloc];
}

- (BOOL) isConnected
{
	return [hypertable isConnected];
}

- (void)main
{
	[[hypertable connectionLock] lock];
	HTHRIFT th;
	int rc = create_thrift_client(&th, [ipAddress UTF8String], port);
	[self setErrorCode:rc];
	
	if (rc != T_OK) {
		NSLog(@"Error: create_thrift_client returned %d", rc);
	}
	else {
		HTHRIFT_HQL hql;
		
		rc = create_hql_client(&hql, [ipAddress UTF8String], port);
		[self setErrorCode:rc];
		
		if (rc != T_OK) {
			NSLog(@"Error: create_hql_client returned %d", rc);
		}
		else {
			[hypertable setHqlClient:hql];
			[hypertable setThriftClient:th];
		}
	}
	[[hypertable connectionLock]  unlock];
}

@end
