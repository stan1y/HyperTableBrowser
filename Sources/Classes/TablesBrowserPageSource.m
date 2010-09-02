//
//  TablesBrowserPageSource.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "TablesBrowserPageSource.h"
#import "FetchPageOperation.h"
#import "TablesBrowser.h"

@implementation TablesBrowserPageSource

@synthesize pageInfoField;
@synthesize pageTableView;
@synthesize	lastDisplayedTableName;
@synthesize lastUsedStorage;
@synthesize lastDisplayedPageNumber;
@synthesize pageSizeTextField;
@synthesize	copyRowKeyButton;
@synthesize selectedRowKey;
@synthesize selectedRowKeyValue;
@synthesize refreshButton;
@synthesize	nextPageButton;
@synthesize prevPageButton;
@synthesize selectedRowIndex;
@synthesize indicator;

- (void)dealloc
{
	[indicator release];
	[pageInfoField release];
	[pageTableView release];
	[lastDisplayedTableName release];
	[lastUsedStorage release];
	[pageSizeTextField release];
	[copyRowKeyButton release];
	[selectedRowKey release];
	[selectedRowKeyValue release];
	[refreshButton release];
	[nextPageButton release];
	[prevPageButton release];
	
	[super dealloc];
}

- (IBAction) deselectRow:(id)sender
{
	[selectedRowKey setStringValue:@"Nothing selected"];
	[selectedRowKey setEnabled:NO];
	[copyRowKeyButton setEnabled:NO];	
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)newValue 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex 
{
	DataRow * row = page_row_at_index([self page], rowIndex);
	Server<CellStorage> * broker = [[TablesBrowser sharedInstance] selectedBroker];
	if ( broker && row) {
		NSString * rowKey = [NSString stringWithUTF8String:row->rowKey];
		NSString * tableName = [[[[TablesBrowser sharedInstance] tablesList] selectedCellInColumn:0] stringValue];
		[broker setCell:newValue forRow:rowKey andColumn:[aTableColumn identifier] inTable:tableName withCompletionBlock:^(BOOL success) {
			[self refresh:nil];
			if (!success) {
				NSRunAlertPanel(@"Operation failed", [NSString stringWithFormat:@"Failed to modify cell in row %@ in table %@ on server %@", rowKey, tableName, [broker valueForKey:@"serverName"]], @"Continue", nil, nil);
			}
		}];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView 
  shouldSelectRow:(NSInteger)rowIndex {
	if (![self page]) {
		[self deselectRow:nil];
		return NO;
	}
	//enable controls
	[selectedRowKey setEnabled:YES];
	[copyRowKeyButton setEnabled:YES];
	
	DataRow * row = page_row_at_index([self page], rowIndex);
	
	//show row key
	[self setSelectedRowKeyValue:[NSString stringWithUTF8String:row->rowKey]];
	[self setSelectedRowIndex:rowIndex];
	[selectedRowKey setStringValue:[NSString stringWithFormat:@"%s",
										  row->rowKey]];
	
	//do selection
	return YES;
}

- (void)showFirstPageFor:(NSString *)tableName fromStorage:(Server<CellStorage> *)storage
{
	[self showPageFor:tableName 
	   fromStorage:storage
	   withPageNumber:1 
		  andPageSize:[pageSizeTextField intValue]];
}

- (void)showPageFor:(NSString *)tableName fromStorage:(Server<CellStorage> *)storage 
	 withPageNumber:(int)number andPageSize:(int)size
{
	if (!tableName) {
		return;
	}
	
	NSLog(@"Tables Browser: Fetching page %d of %d rows from table %@.",
		  number, size, tableName);
	
	//save received values
	[pageSizeTextField setIntValue:size];
	[self setLastDisplayedPageNumber:number];
	[self setLastDisplayedTableName:tableName];
	[self setLastUsedStorage:storage];
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	
	[storage fetchPageFrom:tableName number:number ofSize:size withCompletionBlock: ^(DATA_PAGE data) {
		[indicator stopAnimation:self];
		[indicator setHidden:YES];
		//display received page
		DataPage * receivedPage = (DataPage *)data;
		if (receivedPage) {
			//unlock controls for page switching
			if (number > 1) {
				[prevPageButton setEnabled:YES];
			}
			else {
				[prevPageButton setEnabled:NO];
			}
			
			if ([storage lastFetchedIndex] == [storage lastFetchedTotalIndexes] - 1) {
				[nextPageButton setEnabled:NO];
			}
			else {
				[nextPageButton setEnabled:YES];
			}
			
			if (receivedPage->rowsCount > 0) {
				NSLog(@"Tables Browser: Received page with %d rows.", receivedPage->rowsCount);
				
				//update page info
				int totalPages = [storage lastFetchedTotalIndexes] / size;
				if (totalPages == 0) {
					totalPages = 1;
				}
				NSString * pageInfo = [NSString stringWithFormat:@"Page %d of %d with %d row(s).",
									   number,
									   totalPages,
									   receivedPage->rowsCount];
				[pageInfoField setStringValue:pageInfo];
			}
			else {
				NSLog(@"Tables Browser: Table %@ is empty.", tableName);
				[pageInfoField setStringValue:[NSString stringWithFormat:@"Table %@ is empty.", tableName]];
				receivedPage = page_new();
				DataRow * emptyRow = row_new("dummy");
				page_append(receivedPage, emptyRow);
			}
		
			//display received page with PageSource:setPage/reloadDataForView
			[self setPage:receivedPage withTitle:tableName];
			[self reloadDataForView:pageTableView];
			
			//allow refresh control
			[refreshButton setEnabled:YES];
		}
		else {
			NSLog(@"Tables Browser: Failed to fetch page.");
			
			//disabled controls
			[refreshButton setEnabled:NO];
			[nextPageButton setEnabled:NO];
			[prevPageButton setEnabled:NO];
			NSRunAlertPanel(@"Operation failed", [NSString stringWithFormat:@"Failed to fetch cells page from storage %@.", [storage valueForKey:@"serverName"]], @"Continue", nil, nil);
		}
		
	} ];
}

- (IBAction)nextPage:(id)sender
{
	[self showPageFor:[self lastDisplayedTableName]
	   fromStorage:[self lastUsedStorage]
	   withPageNumber:[self lastDisplayedPageNumber] + 1
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)prevPage:(id)sender
{
	[self showPageFor:[self lastDisplayedTableName]
	   fromStorage:[self lastUsedStorage]
	   withPageNumber:[self lastDisplayedPageNumber] - 1
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)refresh:(id)sender
{
	[self showPageFor:[self lastDisplayedTableName]
	   fromStorage:[self lastUsedStorage]
	   withPageNumber:[self lastDisplayedPageNumber]
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)copySelectedRowKey:(id)sender
{
	if ( [self selectedRowKeyValue] && [[self selectedRowKeyValue] length] > 0) {
		NSPasteboard *pb = [NSPasteboard generalPasteboard];
		NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
		[pb declareTypes:types owner:self];
		[pb setString:[self selectedRowKeyValue] forType:NSStringPboardType];
		NSLog(@"Row key \"%@\" was copied to clipboard", [self selectedRowKeyValue]);
	}
}

@end