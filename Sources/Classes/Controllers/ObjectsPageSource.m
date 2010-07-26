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
@synthesize	lastDisplayedObjectType;
@synthesize lastUsedConnection;
@synthesize lastDisplayedPageNumber;
@synthesize pageSizeTextField;
@synthesize	copyObjectKeyButton;
@synthesize selectedObjectKey;
@synthesize refreshButton;
@synthesize	nextPageButton;
@synthesize prevPageButton;

- (BOOL)tableView:(NSTableView *)aTableView 
  shouldSelectRow:(NSInteger)rowIndex {
	if (!page) {
		[selectedObjectKey setTitleWithMnemonic:@"Nothing selected"];
		[copyObjectKeyButton setEnabled:NO];
		return NO;
	}
	[copyObjectKeyButton setEnabled:YES];
	
	DataRow * row = page_row_at_index(self.page, rowIndex);
	
	//show row key
	[selectedObjectKey setTitleWithMnemonic:[NSString stringWithFormat:@"Selected object key: %s",
												 row->rowKey]];
	
	//do selection
	return YES;
}

- (void)showFirstPageFor:(NSString *)objectType
		  fromConnection:(ThriftConnection *)connection
{
	[self showPageFor:objectType 
	   fromConnection:connection
	   withPageNumber:1 
		  andPageSize:[pageSizeTextField intValue]];
}

- (void)showPageFor:(NSString *)tableName 
		   fromConnection:(ThriftConnection *)connection
		   withPageNumber:(int)number andPageSize:(int)size
{
	[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Reading objects from %s.", [tableName UTF8String]]];
	[[NSApp delegate] indicateBusy];
	
	//save received values
	[pageSizeTextField setIntValue:size];
	[self setLastDisplayedPageNumber:number];
	[self setLastDisplayedObjectType:tableName];
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
								   [[self lastDisplayedObjectType] UTF8String]];
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
	
	NSLog(@"Starting page fetching operation...\n");
	[fpageOp start];
}

- (IBAction)nextPage:(id)sender
{
	[self showPageFor:[self lastDisplayedObjectType]
	   fromConnection:[self lastUsedConnection]
	   withPageNumber:[self lastDisplayedPageNumber] + 1
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)prevPage:(id)sender
{
	[self showPageFor:[self lastDisplayedObjectType]
	   fromConnection:[self lastUsedConnection]
	   withPageNumber:[self lastDisplayedPageNumber] - 1
		  andPageSize:[pageSizeTextField intValue]];
}

- (IBAction)refresh:(id)sender
{
	[self showPageFor:[self lastDisplayedObjectType]
	   fromConnection:[self lastUsedConnection]
	   withPageNumber:[self lastDisplayedPageNumber]
		  andPageSize:[pageSizeTextField intValue]];
}


@end
