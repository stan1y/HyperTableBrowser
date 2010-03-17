//
//  PageSource.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "PageSource.h"


@implementation PageSource

@synthesize pageTitle;

- (DataPage *)page { return page; }

- (void)setPage:(DataPage *)newPage {
	if (page) {
		//remove current page
		page_clear(page);
		free(page);
	}
	page = newPage;
}

- (void)setPage:(DataPage*)newPage 
	  withTitle:(NSString*)title
{
	[self setPage:newPage];
	[self setPageTitle:title];
}

- (void)reloadDataForView:(NSTableView *)tableView {
	NSLog(@"PageSource: reloading data for view");
	
	if (!page) {
		NSLog(@"PageSource: no page set for reload");
		return;
	}
	//remove columns from table view
	int count = [[tableView tableColumns] count];
	for (int i=0; i<count; i++) {
		[tableView removeTableColumn:[[tableView tableColumns] objectAtIndex:0]];
	}
	
	//add new columns
	DataCellIterator * i = cell_iter_new(page->rowsHead);
	DataCell * cell;
	do {
		cell = cell_iter_next_cell(i);
		if (cell) {
			NSString * cellFamily;
			if (cell->cellColumnFamilySize > 0 ) {
				cellFamily = [NSString stringWithFormat:@"%s", cell->cellColumnFamily];
			} else {
				cellFamily = @"";
			}

			NSString * cellColumn;
			if (cell->cellColumnQualifierSize > 0) {
				cellColumn = [cellFamily stringByAppendingFormat:@":%s", cell->cellColumnQualifier];
			}
			else {
				cellColumn = cellFamily;
			}
			NSLog(@"Reloading data for %s:%s", [cellFamily UTF8String], [cellColumn UTF8String]);
			
			NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:cellColumn];
			[column setMinWidth:100];
			[column setMaxWidth:300];
			[[column headerCell] setStringValue:cellColumn];
			[tableView addTableColumn:column];
		}
		
	} while (cell);
	free(i);
	NSLog(@"PageSource: reloading table view");
	//reload data
	[tableView reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView  {
	if (page) {
		NSLog(@"%d rows in table", page->rowsCount);
		return page->rowsCount;
	}
	NSLog(@"No rows in null page");
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	@try {
		if (!page) {
			return nil;
		}
		
		if (page->rowsCount == 0) {
			return nil;
		}
		NSString * columnId = [aTableColumn identifier];
		NSLog(@"Looking for cell with label \"%s\"", [columnId UTF8String]);
		DataCellIterator * cellIter = cell_iter_new(page_row_at_index(page, rowIndex));
		DataCell * cell = NULL;
		do {
			NSLog(@"Iterating over %d cells", page_row_at_index(page, rowIndex)->cellsCount);
			
			cell = cell_iter_next_cell(cellIter);
			if (cell) {
				//get cell family
				NSString * cellFamily;
				if (cell->cellColumnFamilySize > 0 ) {
					cellFamily = [NSString stringWithFormat:@"%s", cell->cellColumnFamily];
				} else {
					NSLog(@"(iter) -> Warnning! Cell column family size is zero, value is \"%s\"", [cell->cellColumnFamily UTF8String]);
					NSLog(@"(iter) -> Defaulting to empty");
					cellFamily = @"";
				}
				//get cell column
				NSString * cellColumn;
				if (cell->cellColumnQualifierSize > 0) {
					cellColumn = [cellFamily stringByAppendingFormat:@":%s", cell->cellColumnQualifier];
				}
				else {
					NSLog(@"Warnning! Cell column value size is zero, value is \"%s\"", [cell->cellColumnFamily UTF8String]);
					NSLog(@"Defaulting to \"%s\"", [cellFamily UTF8String]);
					cellColumn = cellFamily;
				}

				if (strcmp([cellColumn UTF8String], [columnId UTF8String]) == 0) {
					free(cellIter);
					if (cell->cellValueSize > 0) {
						return [NSString stringWithFormat:@"%s", cell->cellValue];
					} else {
						NSLog(@"Warnning! Cell value size is zero");
						return @"";
					}
					 
				}
			}
			
		} while (cell);
		free(cellIter);
		NSLog(@"No value found for \"%s\"", [columnId UTF8String]);
		return @"<#Error#>";
	}
	@catch(NSException * ex) {
		NSLog(@"Failed to get data for cell at row %d, column %s", rowIndex, 
			  [[aTableColumn identifier] UTF8String]);
		return 0;
	}
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)newValue 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex 
{
	//modify cell
	if (page == nil) {
		return;
	}
	
	DataRow * row = page_row_at_index(page, rowIndex);
	DataCellIterator * cellIter = cell_iter_new(row);
	DataCell * cell = NULL;
	do {
		cell = cell_iter_next_cell(cellIter);
		if (cell) {
			NSString * cellFamily = [NSString stringWithFormat:@"%s", cell->cellColumnFamily];
			NSString * cellColumn;
			if (cell->cellColumnQualifierSize > 0) {
				cellColumn = [cellFamily stringByAppendingFormat:@":%s", cell->cellColumnQualifier];
			}
			else {
				cellColumn = cellFamily;
			}
			
			NSString * columnId = [aTableColumn identifier];
			if (strcmp([cellColumn UTF8String], [columnId UTF8String]) == 0) {
				break;
			}
		}
		
	} while (cell);
	free(cellIter);
	
	if (cell) {
		//set value
		if ([newValue length] > cell->cellValueSize) {
			realloc(cell->cellValue, sizeof(char) * ([newValue length] + 1));
			cell->cellValueSize = [newValue length];
		}
		strncpy(cell->cellValue, [newValue UTF8String], ([newValue length] + 1));
		
		id srv = [[NSApp delegate] getCurrentServer];
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			int rc = set_row([[srv objectForKey:@"connection"] thriftClient], row, [pageTitle UTF8String]);
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSApp delegate] indicateDone];
				if (rc != T_OK) {
					[[NSApp delegate] setMessage:[@"Failed to write cells:" stringByAppendingString:
															[ThriftConnection errorFromCode:rc]] ];
					[self setPage:nil];
				}
				else {
					[[NSApp delegate] setMessage:@"Row updated"];
				}
			});
		});
	}
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
}


@end
