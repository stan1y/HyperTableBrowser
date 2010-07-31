//
//  SetRowOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "SetRowOperation.h"


@implementation SetRowOperation

@synthesize connection;
@synthesize row;
@synthesize cellValue;
@synthesize rowIndex;
@synthesize columnName;
@synthesize errorCode;
@synthesize tableName;
@synthesize page;

+ setRow:(DataRow *)row inTable:(NSString*)tableName withConnection:(ThriftConnection *)con
{
	SetRowOperation * op = [[SetRowOperation alloc] init];
	[op setConnection:con];
	[op setTableName:tableName];
	[op setRow:row];
	return op;
}

+ setCellValue:(NSString *)newValue
	  fromPage:(DataPage *)page
	   inTable:(NSString *)tableName 
		 atRow:(NSInteger)rowIndex
	 andColumn:(NSString *)columnName
withConnection:(ThriftConnection *)con;
{
	SetRowOperation * op = [[SetRowOperation alloc] init];
	[op setConnection:con];
	[op setTableName:tableName];
	[op setRowIndex:rowIndex];
	[op setColumnName:columnName];
	[op setCellValue:newValue];
	[op setPage:page];
	return op;
}

- (void) dealloc
{
	[connection release];
	[tableName release];
	[cellValue release];
	[columnName release];
	
	if (page) {
		page_clear(page);
		free(page);
		page = nil;
	}
	 
	 if (row) {
		 row_clear(row);
		 free(row);
		 row = nil;
	 }
	
	[super dealloc];
}

- (void)main
{
	[self setErrorCode:0];
	//construct row with one cell from
	//data we have or just set specified row
	if ( ![self row]) {
		row = page_row_at_index(page, rowIndex);
		DataCellIterator * cellIter = cell_iter_new(row);
		DataCell * cell = NULL;
		do {
			cell = cell_iter_next_cell(cellIter);
			if (cell) {
				NSString * cellFamily = [NSString stringWithUTF8String:cell->cellColumnFamily];
				NSString * cellColumn;
				if (cell->cellColumnQualifierSize > 0) {
					cellColumn = [cellFamily stringByAppendingFormat:@":%s", cell->cellColumnQualifier];
				}
				else {
					cellColumn = cellFamily;
				}
				
				if (strcmp([cellColumn UTF8String], [columnName UTF8String]) == 0) {
					break;
				}
			}
			
		} while (cell);
		free(cellIter);
		
		if (cell) {
			//modify value
			realloc(cell->cellValue, sizeof(char) * [cellValue length] + 1);
			memset(cell->cellValue, 0, sizeof(char) * [cellValue length] + 1);
			cell->cellValueSize = [cellValue length];
			strncpy(cell->cellValue, [cellValue UTF8String], [cellValue length]);
			
			NSLog(@"Set cell (\"%s\", \"%s\", \"%s\") = \"%s\"", row->rowKey,
				  cell->cellColumnFamily,
				  cell->cellColumnQualifier,
				  cell->cellValue);
		}
		else {
			[self setErrorCode:T_ERR_APPLICATION];
			NSLog(@"Failed to find cell with requested metadata.\n");
		}
	}
	
	//set row
	int rc = set_row([connection thriftClient], row, [tableName UTF8String]);
	[self setErrorCode:rc];
}

@end
