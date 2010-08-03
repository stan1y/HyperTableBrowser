//
//  FetchTablesOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "FetchTablesOperation.h"


@implementation FetchTablesOperation

@synthesize connection;
@synthesize errorCode;

+ fetchTablesFromConnection:(ThriftConnection *)conn
{
	FetchTablesOperation * ftOp = [[FetchTablesOperation alloc] init];
	[ftOp setConnection:conn];
	return ftOp;
}

- (void) dealloc
{
	[connection release];
	[super dealloc];
}

- (void)main
{
	[[connection connectionLock] lock];
	DataRow * row = row_new("tables");
	int rc = get_tables_list([connection thriftClient], row);
	[self setErrorCode:rc];
	if ( rc != T_OK ) {
		free(row);
		NSLog(@"Failed to get tables list with code %d, %s\n", rc,
			  [[ThriftConnection errorFromCode:rc] UTF8String]);
		return;
	}
	
	//success
	NSLog(@"Received %d tables\n", row->cellsCount);
	NSMutableArray * tables = [NSMutableArray arrayWithCapacity:row->cellsCount];
	DataCellIterator * ci = cell_iter_new(row);
	DataCell * cell = NULL;
	//filter out METADATA if specified
	id generalPrefs = [[NSApp delegate] getSettingsByName:@"GeneralPrefs"];
	if (!generalPrefs) {
		[[NSApp delegate] setMessage:@"There is no settings found!"];
		return;
	}
	int skipMetadata = [[generalPrefs valueForKey:@"skipMetadata"] intValue];
	[generalPrefs release];
	int index = 0;
	do {
		cell = cell_iter_next_cell(ci);
		if (cell) {
			if (skipMetadata && strcmp(cell->cellValue, "METADATA") == 0) {
				NSLog(@"Skipping METADATA table.\n");
				continue;
			}
			[tables insertObject:[NSString stringWithCString:cell->cellValue 
												 encoding:NSUTF8StringEncoding] 
					  atIndex:index];
			index++;
		}
	} while (cell);
	free(ci);
	row_clear(row);
	free(row);
	[[NSApp delegate] setMessage:[NSString stringWithFormat:@"%d tables found.", [tables count]]];
	[tables retain];
	[connection setTables:tables];
	[[connection connectionLock] unlock];
}

@end
