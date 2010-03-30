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

- (void)awakeFromNib {
	//init pages container
    keysDict = [[NSMutableDictionary dictionary] retain];
}

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
	[self showPageFor:objectType fromConnection:connection withPageNumber:1 andPageSize:[pageSizeTextField intValue]];
}

- (void)showPageFor:(NSString *)objectType 
		   fromConnection:(ThriftConnection *)connection
		   withPageNumber:(int)number andPageSize:(int)size
{
	[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Reading objects from %s.", [objectType UTF8String]]];
	[[NSApp delegate] indicateBusy];
	
	//save received values
	[pageSizeTextField setIntValue:size];
	[self setLastDisplayedPageNumber:number];
	[self setLastDisplayedObjectType:objectType];
	[self setLastUsedConnection:connection];

	//get keys
	DataRow * keys = (DataRow *)[keysDict objectForKey:objectType];
	if (!keys) {
		//refresh keys if none
		[self refreshKeysFor:objectType fromConnection:connection];
		keys = (DataRow *)[keysDict objectForKey:objectType];
		if (!keys) {
			//ok, we've tried and failed
			[[NSApp delegate] setMessage:@"Failed to get keys"];
			[[NSApp delegate] indicateDone];
			return;
		}
		if (keys->cellsCount <= 0 ) {
			//no data in table
			[[NSApp delegate] setMessage:@"Table is empty"];
			[[NSApp delegate] indicateDone];
			return;
		}
	}
	
	//calculate start key index.
	int startIndex = 0;
	if (number > 1) {
		startIndex = (number - 1) * size;
	}
	
	//calculate stop key index
	int stopIndex = startIndex + size - 1;
	if (stopIndex > keys->cellsCount-1) {
		stopIndex = keys->cellsCount-1;
	}
	
	//set start key
	DataCell * startCell = row_cell_at_index(keys, startIndex);
	char * startRow = (char*)malloc(sizeof(char) * startCell->cellValueSize + 1);
	strncpy(startRow, startCell->cellValue, startCell->cellValueSize + 1);
	
	
	//set stop key
	DataCell * stopCell = row_cell_at_index(keys, stopIndex);
	char * stopRow = (char*)malloc(sizeof(char) * stopCell->cellValueSize + 1);
	strncpy(stopRow, stopCell->cellValue, stopCell->cellValueSize + 1);
	
	//unlock controls for page switching
	if (number > 1) {
		[prevPageButton setEnabled:YES];
	}
	else {
		[prevPageButton setEnabled:NO];
	}
	
	if (stopIndex == keys->cellsCount-1) {
		[nextPageButton setEnabled:NO];
	}
	else {
		[nextPageButton setEnabled:YES];
	}
	
	[[NSApp delegate]setMessage:[NSString stringWithFormat:@"Requesting page %d-%d from %s to %s.\n", 
								 startIndex,
								 stopIndex,
								 startRow,
								 stopRow]];
	
	DataPage * receivedPage = page_new();
	int rc = get_page([connection thriftClient], receivedPage, [objectType UTF8String], startRow, stopRow);
	[[NSApp delegate] indicateDone];
	
	NSLog(@"Page code is %d", rc);
	if (rc == T_OK) {
		//display message
		[[NSApp delegate]setMessage:[NSString stringWithFormat:@"Received %d objects.\n", receivedPage->rowsCount]];
		
		//update page info
		NSString * pageInfo = [NSString stringWithFormat:@"Page %d with %d (of %d requested) object(s) %s",
							   number,
							   receivedPage->rowsCount,
							   size,
							   [[self lastDisplayedObjectType] UTF8String]];
		[objectsPageField setTitleWithMnemonic:pageInfo];
		
		//display received page with PageSource:setPage/reloadDataForView
		[self setPage:receivedPage withTitle:objectType];
		[self reloadDataForView:objectsPageView];
		//allow refresh
		[refreshButton setEnabled:YES];
	}
	else {
		[[NSApp delegate] setMessage:[ThriftConnection errorFromCode:rc]];
		//disabled controls
		[refreshButton setEnabled:NO];
		[nextPageButton setEnabled:NO];
		[prevPageButton setEnabled:NO];
	}
	free(stopRow);
	free(startRow);
}

- (void)refreshKeysFor:(NSString *)objectType
		fromConnection:(ThriftConnection *)conenction;
{
	//remove old keys of present
	DataRow * oldKeys = (DataRow *)[keysDict objectForKey:objectType];
	if (oldKeys) {
		row_clear(oldKeys);
		free(oldKeys);
	}
	
	DataRow * newKeysRow = [self requestKeysFor:objectType fromConnection:conenction];
	
	if (newKeysRow && newKeysRow->cellsCount > 0) {
		[keysDict setObject:newKeysRow forKey:objectType];
		[[NSApp delegate] setMessage:[NSString stringWithFormat:@"Received %d keys.\n", newKeysRow->cellsCount]];
	}
	else {
		//make sure that keys are empty for failed refresh
		[keysDict removeObjectForKey:objectType];
	}
}

- (DataRow *)requestKeysFor:(NSString *)objectType
		 fromConnection:(ThriftConnection *)conenction
{
	DataRow * keysRow = row_new([objectType UTF8String]);
	
	[[NSApp delegate]setMessage:[NSString stringWithFormat:@"Requesting keys for %s\n", [objectType UTF8String]]];
	//read keys from hypertable
	int rc = get_keys([conenction thriftClient], keysRow, [objectType UTF8String]);
	if ( rc != T_OK) {
		id msg = [NSString stringWithFormat:@"Failed to read keys for %s: %s.",
				  [objectType UTF8String],
				  [[ThriftConnection errorFromCode:rc] UTF8String]];	
		[[NSApp delegate] setMessage:msg];
		
		return NULL;
	}
	
	return keysRow;
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
