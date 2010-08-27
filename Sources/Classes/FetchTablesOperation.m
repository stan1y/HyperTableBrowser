//
//  FetchTablesOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 26/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "FetchTablesOperation.h"


@implementation FetchTablesOperation

@synthesize hypertable;
@synthesize errorCode;

+ fetchTablesFrom:(HyperTable *)hypertable
{
	FetchTablesOperation * ftOp = [[FetchTablesOperation alloc] init];
	[ftOp setHypertable:hypertable];
	return ftOp;
}

- (void) dealloc
{
	[hypertable release];
	[super dealloc];
}

- (void)main
{
	[[hypertable connectionLock] lock];
	DataRow * row = row_new("tables");
	int rc = get_tables_list([hypertable thriftClient], row);
	[self setErrorCode:rc];
	if ( rc != T_OK ) {
		free(row);
		NSLog(@"Failed to get tables list with code %d, %s\n", rc,
			  [[HyperTable errorFromCode:rc] UTF8String]);
		return;
	}
	
	//success
	NSMutableArray * tables = [NSMutableArray arrayWithCapacity:row->cellsCount];
	DataCellIterator * ci = cell_iter_new(row);
	DataCell * cell = NULL;
	
	//FIXME : Settings
	int skipMetadata = 0;
	
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
	NSLog(@"%d tables found.", [tables count]);
	[hypertable setTables:tables];
	[[hypertable connectionLock] unlock];
}

@end
