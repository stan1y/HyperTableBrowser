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
	return [ftOp autorelease];
}

- (void)main
{
	NSLog(@"Requesting tables");
	
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
	int index = 0;
	do {
		cell = cell_iter_next_cell(ci);
		if (cell) {
			
			if (strcmp(cell->cellValue, "METADATA") == 0)
				continue;
			
			[tables insertObject:[NSString stringWithCString:cell->cellValue 
												 encoding:NSUTF8StringEncoding] 
					  atIndex:index];
			index++;
		}
	} while (cell);
	free(ci);
	free(row);
	[connection setTables:tables];
	[tables release];
}

@end
