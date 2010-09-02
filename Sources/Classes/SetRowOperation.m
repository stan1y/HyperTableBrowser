//
//  SetRowOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/7/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "SetRowOperation.h"

@implementation SetCellOperation

@synthesize hypertable;
@synthesize cellValue;
@synthesize rowKey;
@synthesize columnName;
@synthesize errorCode;
@synthesize tableName;

+ setCellValue:(id)newValue forRow:(NSString *)rowKey andColumn:(NSString *)columnName inTable:(NSString *)tableName onServer:(HyperTable *)onHypertable
{
	SetCellOperation * op = [[SetCellOperation alloc] init];
	[op setHypertable:onHypertable];
	[op setTableName:tableName];
	[op setRowKey:rowKey];
	[op setColumnName:columnName];
	[op setCellValue:newValue];
	return op;
}

- (void) dealloc
{
	[hypertable release];
	[tableName release];
	[cellValue release];
	[columnName release];
	[rowKey release];
	
	[super dealloc];
}

- (void)main
{
	[[hypertable connectionLock] lock];
	[self setErrorCode:0];
	
	DataRow * row = row_new([[self rowKey] UTF8String]);
	DataCell * cell = cell_new(nil, nil);
	
	//find family and qualifier
	NSRange r = [[self columnName] rangeOfString:@":"];
	if (r.location == NSNotFound) {
		NSLog(@"Bad column name specified. Family and qualifier expected.");
		return;
	}
	NSRange familyRange = NSMakeRange(0, r.location);
	NSRange qualifierRange = NSMakeRange(r.location + 1, [[self columnName] length] - r.location - 1);
	
	cell_set(cell, [[[self columnName] substringWithRange:familyRange] UTF8String], [[[self columnName] substringWithRange:qualifierRange] UTF8String], [[self cellValue] UTF8String], 0);
	row_append(row, cell);
	
	int rc = set_row([hypertable thriftClient], row, [tableName UTF8String]);
	[self setErrorCode:rc];
	[[hypertable connectionLock] unlock];
}

@end
