//
//  TablesBrowserPageSource.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesBrowserPageSource.h"


@implementation TablesBrowserPageSource

@synthesize pageInfoField;
@synthesize rowsPageView;
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

- (void)dealloc
{
	[pageInfoField release];
	[rowsPageView release];
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
	if (![self page]) {
		[selectedRowKey setTitleWithMnemonic:@"Nothing selected"];
		[selectedRowKeyValue release];
		[copyRowKeyButton setEnabled:NO];
		return NO;
	}
	[copyRowKeyButton setEnabled:YES];
	
	DataRow * row = page_row_at_index([self page], rowIndex);
	
	//show row key
	[self setSelectedRowKeyValue:[NSString stringWithUTF8String:row->rowKey]];
	[self setSelectedRowIndex:rowIndex];
	[selectedRowKey setTitleWithMnemonic:[NSString stringWithFormat:@"Selected: %s",
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
		[[[NSApp delegate] tablesBrowser] indicateDone];
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
				[[[NSApp delegate] tablesBrowser] setMessage:[NSString stringWithFormat:@"Received %d rows.\n", receivedPage->rowsCount]];
				
				//update page info
				NSString * pageInfo = [NSString stringWithFormat:@"Page %d with %d (of %d requested) row(s) %s",
									   number,
									   receivedPage->rowsCount,
									   size,
									   [[self lastDisplayedTableName] UTF8String]];
				[pageInfoField setTitleWithMnemonic:pageInfo];
			}
			else {
				[[[NSApp delegate] tablesBrowser] setMessage:[NSString stringWithFormat:
											 @"No rows were found in table \"%s\".\n",
											 [[fpageOp tableName] UTF8String] ]];
				receivedPage = page_new();
				DataRow * emptyRow = row_new("dummy");
				page_append(receivedPage, emptyRow);
			}
			
			//display received page with PageSource:setPage/reloadDataForView
			[self setPage:receivedPage withTitle:tableName];
			[self reloadDataForView:rowsPageView];
			
			//allow refresh control
			[refreshButton setEnabled:YES];
		}
		else {
			[[[NSApp delegate] tablesBrowser] setMessage:[HyperTable errorFromCode:fpageOp.errorCode]];
			//disabled controls
			[refreshButton setEnabled:NO];
			[nextPageButton setEnabled:NO];
			[prevPageButton setEnabled:NO];
		}
		
	} ];
	
	//start async operation
	[[[NSApp delegate] tablesBrowser] indicateBusy];
	[[[NSApp delegate] tablesBrowser] setMessage:[NSString stringWithFormat:@"Fetching page from table \"%s\"\n", 
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
		[[[NSApp delegate] tablesBrowser] setMessage:[NSString stringWithFormat:@"Row key \"%s\" was copied to clipboard",
									  [[self selectedRowKeyValue] UTF8String]]];
	}
}

@end