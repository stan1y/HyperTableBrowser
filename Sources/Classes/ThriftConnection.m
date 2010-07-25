//
//  ThriftConnection.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/8/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ThriftConnection.h"


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

		case T_OK:
		default:
			return @"Executed successfuly.";
			break;
	}
}

- (BOOL)isConnected {
	return ( (thriftClient != nil) && (hqlClient != nil) );
}

- (NSString *)connectTo:(ThriftConnectionInfo *)info {
	NSLog(@"connectTo %s: port:%d\n", [[info address] UTF8String], [info port]);
	HTHRIFT th;
	int rc = create_thrift_client(&th, [[info address] UTF8String], [info port]);
	if (rc != T_OK) {
		NSLog(@"connectTo: error: create_thrift_client returned %d", rc);
	}
	else {
		HTHRIFT_HQL hql;
		rc = create_hql_client(&hql, [[info address] UTF8String], [info port]);
		if (rc != T_OK) {
			NSLog(@"connectTo: error: create_hql_client returned %d", rc);
		}
		else {
			[self setHqlClient:hql];
			[self setThriftClient:th];
			[self setConnInfo:info];
		}
	}

	return [ThriftConnection errorFromCode:rc];
}

- (void)refreshTables
{
	NSLog(@"Requesting tables");
	//read tables
	DataRow * row = row_new("tables");
	get_tables_list([self thriftClient], row);
	DataCellIterator * ci = cell_iter_new(row);
	if (self.tables) {
		[tables release];
	}
	NSMutableArray * tbl = [NSMutableArray arrayWithCapacity:row->cellsCount];
	DataCell * cell = NULL;
	int index = 0;
	do {
		cell = cell_iter_next_cell(ci);
		if (cell) {
			if (strcmp(cell->cellValue, "METADATA") == 0)
				continue;
			
			NSLog(@"Found table %s", cell->cellValue);
			[tbl insertObject:[NSString stringWithCString:cell->cellValue 
												 encoding:NSUTF8StringEncoding] 
					  atIndex:index];
			index++;
		}
	} while (cell);
	free(ci);
	
	[self setTables:tbl];
}

@end
