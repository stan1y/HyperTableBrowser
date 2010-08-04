//
//  ObjectsPageSource.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ObjectsPageSource.h"


@implementation ObjectsPageSource

@synthesize objectsPageField;
@synthesize objectsPageView;
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

- (void)dealloc
{
	[objectsPageField release];
	[objectsPageView release];
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

- (BOOL)tableView:(NSTableView *)aTableView 
  shouldSelectRow:(NSInteger)rowIndex {
	if (!page) {
		[selectedRowKey setTitleWithMnemonic:@"Nothing selected"];
		[selectedRowKeyValue release];
		[copyRowKeyButton setEnabled:NO];
		return NO;
	}
	[copyRowKeyButton setEnabled:YES];
	
	DataRow * row = page_row_at_index([self page], rowIndex);
	
	//show row key
	[self setSelectedRowKeyValue:[NSString stringWithUTF8String:row->rowKey]];
	[selectedRowKey setTitleWithMnemonic:[NSString stringWithFormat:@"Selected: %s",
												 row->rowKey]];
	
	//do selection
	return YES;
}

- (void)showFirstPageFor:(NSString *)tableName
		  fromConnection:(ThriftConnection *)connection
{
	[self showPageFor:tableName 
	   fromConnection:connection
	   withPageNumber:1 
		  andPageSize:[pageSizeTextField intValue]];
}

- (void)showPageFor:(NSString *)tableName 
		   fromConnection:(ThriftConnection *)connection
		   withPageNumber:(int)number andPageSize:(int)size
{
	NSLog(@"Preparing to fetch page\n");
	//save received values
	[pageSizeTextField setIntValue:size];
	[self setLastDisplayedPageNumber:number];
	[self setLastDisplayedTableName:tableName];
	[self setLastUsedConnection:connection];
	
	FetchPageOperation * fpageOp = [FetchPageOperation fetchPageFromConnection:connection
																withName:tableName
																 atIndex:number
																 andSize:size];
	[fpageOp setCompletionBlock: ^ {
		[[NSApp delegate] indicateDone];
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
				[[NSApp delegate]setMessage:[NSString stringWithFormat:@"Received %d rows.\n", receivedPage->rowsCount]];
				
				//update page info
				NSString * pageInfo = [NSString stringWithFormat:@"Page %d with %d (of %d requested) row(s) %s",
									   number,
									   receivedPage->rowsCount,
									   size,
									   [[self lastDisplayedTableName] UTF8String]];
				[objectsPageField setTitleWithMnemonic:pageInfo];
			}
			else {
				[[NSApp delegate]setMessage:[NSString stringWithFormat:
											 @"No rows were found in table \"%s\".\n",
											 [[fpageOp tableName] UTF8String] ]];
				receivedPage = page_new();
				DataRow * emptyRow = row_new("dummy");
				page_append(receivedPage, emptyRow);
			}
			
			//display received page with PageSource:setPage/reloadDataForView
			[self setPage:receivedPage withTitle:tableName];
			[self reloadDataForView:objectsPageView];
			
			//allow refresh
			[refreshButton setEnabled:YES];

		}
		else {
			[[NSApp delegate] setMessage:[ThriftConnection errorFromCode:fpageOp.errorCode]];
			//disabled controls
			[refreshButton setEnabled:NO];
			[nextPageButton setEnabled:NO];
			[prevPageButton setEnabled:NO];
		}
		
	} ];
	
	//start async operation
	[[NSApp delegate] indicateBusy];
	[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Fetching page from table \"%s\"\n", 
								  [tableName UTF8String] ]];

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
		[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Row key \"%s\" was copied to clipboard",
									  [[self selectedRowKeyValue] UTF8String]]];
	}
}

- (IBAction)insertNewRow:(id)sender
{
	id pnl = [[NSApp delegate] insertNewRowPnl];
	if ([pnl isVisible]) {
		[[[NSApp delegate] insertNewRowPnl] orderOut:sender];
	}
	else {
		id cntrl = [[NSApp delegate] newRowController];
		[cntrl updateConnections:self];
		[[[NSApp delegate] insertNewRowPnl] orderFront:sender];
		[cntrl release];
	}
	
	[pnl release];
}

- (IBAction)deleteSelectedRow:(id)sender
{
	if (![self selectedRowKeyValue] || [[self selectedRowKeyValue] length] <= 0 ) {
		NSLog(@"No row selected for delete");
		return;
	}
	
	NSString * selectedTable = [[[NSApp delegate] serversDelegate] selectedTable];
	if (!selectedTable) {
		NSLog(@"No table is selected to insert row");
		return;
	}
	
	NSString * selectedServerAddress = [[[NSApp delegate] serversDelegate] selectedServer];
	if (selectedServerAddress) {
		[selectedTable release];
		NSLog(@"No server is selected to delete row \"%s\"", [[self selectedRowKeyValue] UTF8String]);
		return;
	}
	
	NSLog([NSString stringWithFormat:@"Deleteing row with key \"%s\" from table \"%s\" on server \"%s\".", 
		   [[self selectedRowKeyValue] UTF8String],
		   [selectedTable UTF8String],
		   [selectedServerAddress UTF8String]]);
	
	id connection = [[[NSApp delegate] serversManager] getConnection:selectedServerAddress];
	[selectedServerAddress release];
	if (!connection) {
		[selectedTable release];
		[[NSApp delegate] setMessage:@"Cannot delete selected row. Server is NOT connected."];
		return;
	}
	
	[connection release];
}

@end
