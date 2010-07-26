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
@synthesize	copyObjectKeyButton;
@synthesize selectedRowKey;
@synthesize refreshButton;
@synthesize	nextPageButton;
@synthesize prevPageButton;

- (BOOL)tableView:(NSTableView *)aTableView 
  shouldSelectRow:(NSInteger)rowIndex {
	if (!page) {
		[selectedRowKey setTitleWithMnemonic:@"Nothing selected"];
		[copyObjectKeyButton setEnabled:NO];
		return NO;
	}
	[copyObjectKeyButton setEnabled:YES];
	
	DataRow * row = page_row_at_index(self.page, rowIndex);
	
	//show row key
	[selectedRowKey setTitleWithMnemonic:[NSString stringWithFormat:@"Selected table key: %s",
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
			
			//display message
			DataPage * receivedPage = [fpageOp page];
			[[NSApp delegate]setMessage:[NSString stringWithFormat:@"Received %d rows.\n", receivedPage->rowsCount]];
			
			//update page info
			NSString * pageInfo = [NSString stringWithFormat:@"Page %d with %d (of %d requested) row(s) %s",
								   number,
								   receivedPage->rowsCount,
								   size,
								   [[self lastDisplayedTableName] UTF8String]];
			[objectsPageField setTitleWithMnemonic:pageInfo];
			
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


@end
