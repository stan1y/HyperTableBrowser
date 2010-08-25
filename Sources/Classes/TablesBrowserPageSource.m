//
//  TablesBrowserPageSource.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesBrowserPageSource.h"


@implementation TablesBrowserPageSource

@synthesize pageInfoField;
@synthesize pageTableView;
@synthesize	lastDisplayedTableName;
@synthesize lastUsedConnection;
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
	[lastUsedConnection release];
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

- (void)showFirstPageFor:(NSString *)tableName
		  fromConnection:(HyperTable *)connection
{
	[self showPageFor:tableName 
	   fromConnection:connection
	   withPageNumber:1 
		  andPageSize:[pageSizeTextField intValue]];
}

- (void)showPageFor:(NSString *)tableName 
	 fromConnection:(HyperTable *)connection
	 withPageNumber:(int)number andPageSize:(int)size
{
	NSLog(@"Tables Browser: Fetching page %d of %d rows from table %@.",
		  number, size, tableName);
	
	//save received values
	[pageSizeTextField setIntValue:size];
	[self setLastDisplayedPageNumber:number];
	[self setLastDisplayedTableName:tableName];
	[self setLastUsedConnection:connection];
	
	FetchPageOperation * fpageOp = [FetchPageOperation fetchPageFrom:connection
																	  withName:tableName
																	   atIndex:number
																	   andSize:size];
	[fpageOp setCompletionBlock: ^ {
		
		[indicator stopAnimation:self];
		if (fpageOp.errorCode == T_OK) {
			
			//unlock controls for page switching
			if (number > 1) {
				[prevPageButton setEnabled:YES];
			}
			else {
				[prevPageButton setEnabled:NO];
			}
			
			if (fpageOp.stopIndex == fpageOp.totalRows - 1) {
				[nextPageButton setEnabled:NO];
			}
			else {
				[nextPageButton setEnabled:YES];
			}
			
			//display received page
			DataPage * receivedPage = [fpageOp page];
			if (receivedPage) {
				NSLog(@"Tables Browser: Received page with %d rows.", receivedPage->rowsCount);
				
				//update page info
				int totalPages = [fpageOp totalRows] / size;
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
			
			[[NSApp delegate] showErrorDialog:-1 message:[HyperTable errorFromCode:[fpageOp errorCode]]];
		}
		
	} ];
	
	//start async operation
	[indicator startAnimation:self];
	[pageInfoField setStringValue:@"Fething data..."];
	[[[NSApp delegate] operations] addOperation: fpageOp];
	[fpageOp release];
}

- (IBAction)nextPage:(id)sender
{
	[self showPageFor:[self lastDisplayedTableName]
	   fromConnection:[self lastUsedConnection]
	   withPageNumber:[self lastDisplayedPageNumber] + 1
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)prevPage:(id)sender
{
	[self showPageFor:[self lastDisplayedTableName]
	   fromConnection:[self lastUsedConnection]
	   withPageNumber:[self lastDisplayedPageNumber] - 1
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)refresh:(id)sender
{
	[self showPageFor:[self lastDisplayedTableName]
	   fromConnection:[self lastUsedConnection]
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