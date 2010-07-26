//
//  ThriftConnection.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <ThriftConnection.h>


@implementation ThriftConnection

@synthesize connInfo;
@synthesize thriftClient;
@synthesize hqlClient;

- (NSMutableArray *)tables 
{ 
	return tables;
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
			return @"No data returned from query, where is was expected too.";
			break;
		case T_ERR_TIMEOUT:
			return @"Operation timeout. Check HyperTable is running correctly.";
			break;
		case T_ERR_APPLICATION:
			return @"System error occured. Either your HyperTable server \
			is incompatible with this client application or it had experienced problem service the request";
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
