//
//  DeleteRowOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "DeleteRowOperation.h"


@implementation DeleteRowOperation

@synthesize hypertable;
@synthesize row;
@synthesize tableName;
@synthesize errorCode;


+ deleteRow:(DataRow *)row inTable:(NSString*)tableName onServer:(HyperTable *)hypertable
{
	DeleteRowOperation * op = [[DeleteRowOperation alloc] init];
	[op setHypertable:hypertable];
	[op setTableName:tableName];
	[op setRow:row];
	return op;
}

- (void) dealloc
{
	[hypertable release];
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
	[[hypertable connectionLock] lock];
	[self setErrorCode:0];
	//delete row
	int rc = delete_row([hypertable thriftClient], [self row], [[self tableName] UTF8String]);
	[self setErrorCode:rc];
	[[hypertable connectionLock] unlock];
}

@end
