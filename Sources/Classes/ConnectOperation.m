//
//  ConnectOperation.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ConnectOperation.h"

@implementation ConnectOperation

@synthesize thriftClient;
@synthesize hqlClient;

@synthesize ipAddress;
@synthesize port;

@synthesize errorCode;

+ connectTo:(NSString *)address onPort:(int)port;
{
	ConnectOperation * conOp = [[ConnectOperation alloc] init];
	[conOp setAddress:address];
	[conOp setPort:port];
	return conOp;
}

- (void)dealloc 
{
	[ipAddress release];
	[super dealloc];
}

- (void)main
{
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
			hqlClient = hql;
			thriftClient = th;
		}
	}
}

@end
