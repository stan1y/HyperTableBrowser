//
//  DeleteRowOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "DeleteRowOperation.h"


@implementation DeleteRowOperation

@synthesize hypertable;
@synthesize rowKey;
@synthesize tableName;
@synthesize errorCode;


+ deleteRow:(NSString *)rowKey inTable:(NSString*)tableName onServer:(HyperTable *)hypertable;
{
	DeleteRowOperation * op = [[DeleteRowOperation alloc] init];
	[op setHypertable:hypertable];
	[op setTableName:tableName];
	[op setRowKey:rowKey];
	return op;
}

- (void) dealloc
{
	[hypertable release];
	[tableName release];
	[rowKey release];
	
	[super dealloc];
}

- (void)main
{
	[[hypertable connectionLock] lock];
	[self setErrorCode:0];
	//delete row
	int rc = delete_row_by_key([hypertable thriftClient], [[self rowKey] UTF8String], [[self tableName] UTF8String]);
	[self setErrorCode:rc];
	[[hypertable connectionLock] unlock];
}

@end
