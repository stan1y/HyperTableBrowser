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

- (DataPage *)page {
	return page;
}

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
	if (!page) {
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
			NSString * cellFamily = [NSString stringWithFormat:@"%s", cell->cellColumnFamily];
			NSString * cellColumn;
			if (cell->cellColumnQualifierSize > 0) {
				cellColumn = [cellFamily stringByAppendingFormat:@":%s", cell->cellColumnQualifier];
			}
			else {
				cellColumn = cellFamily;
			}

			NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:cellColumn];
			[column setMinWidth:100];
			[column setMaxWidth:300];
			[[column headerCell] setStringValue:cellColumn];
			[tableView addTableColumn:column];
		}
		
	} while (cell);
	free(i);
	
	//reload data
	[tableView reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView  {
	if (page) {
		return page->rowsCount;
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if (page == nil) {
		return nil;
	}
	
	if (page->rowsCount == 0) {
		return "Nil.";
	}
	DataCellIterator * cellIter = cell_iter_new(page_row_at_index(page, rowIndex));
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
				free(cellIter);
				return [NSString stringWithFormat:@"%s", cell->cellValue];
			}
		}
		
	} while (cell);
	free(cellIter);
	
	return nil;
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
