//
//  DeleteRowOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "DeleteRowOperation.h"


@implementation DeleteRowOperation

@synthesize connection;
@synthesize row;
@synthesize tableName;
@synthesize errorCode;


+ deleteRow:(DataRow *)row inTable:(NSString*)tableName withConnection:(ThriftConnection *)con
{
	DeleteRowOperation * op = [[DeleteRowOperation alloc] init];
	[op setConnection:con];
	[op setTableName:tableName];
	[op setRow:row];
	return op;
}

- (void) dealloc
{
	[connection release];
	[tableName release];
	
	if (row) {
		row_clear(row);
		free(row);
		row = nil;
	}
	
	[super dealloc];
}

- (void)main
{
	[[connection connectionLock] lock];
	[self setErrorCode:0];
	//delete row
	int rc = delete_row([connection thriftClient], [self row], [[self tableName] UTF8String]);
	[self setErrorCode:rc];
	[[connection connectionLock] unlock];
}

@end
