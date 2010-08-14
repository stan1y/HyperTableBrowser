//
//  TablesBrowserToolbar.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesBrowserToolbar.h"

@implementation TablesBrowserToolbarController

@synthesize newTableBtn;
@synthesize dropTableBtn;
@synthesize refreshBtn;
@synthesize newRowBtn;
@synthesize dropRowBtn;

@synthesize toolBar;

@synthesize allowNewTable;
@synthesize allowDropTable;
@synthesize allowRefresh;
@synthesize allowInsertRow;
@synthesize allowDeleteRow;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([toolbarItem isEqual:newTableBtn]) {
		return allowNewTable;
    } else if ( [toolbarItem isEqual:dropTableBtn]) {
		return allowDropTable;
    } else if ( [toolbarItem isEqual:refreshBtn]) {
		return allowRefresh;
	} else if ( [toolbarItem isEqual:newRowBtn]) {
		return allowInsertRow;
	} else if ( [toolbarItem isEqual:dropRowBtn]) {
		return allowDeleteRow;
	}
	
	return YES;
}

- (void)dealloc
{
	[refreshBtn release];
	[newTableBtn release];
	[dropTableBtn release];
	[newRowBtn release];
	[dropRowBtn release];
	[toolBar release];
	[super dealloc];
}

- (IBAction)newTable:(id)sender
{
	[NSApp beginSheet:[[[NSApp delegate] tablesBrowser] newTablePnl] 
	   modalForWindow:[[[NSApp delegate] tablesBrowser] window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)dropTable:(id)sender
{
	id connection = [[[NSApp delegate] tablesBrowser] getSelectedConnection];
	if (!connection) {
		[[[NSApp delegate] tablesBrowser] setMessage:@"Cannot drop table. Server is NOT connected."];
		return;
	}
	
	[[[NSApp delegate] tablesBrowser] indicateBusy];
	NSString * selectedTable = [[[NSApp delegate] serversDelegate] selectedTable];
	int rc = drop_table([connection thriftClient], [selectedTable UTF8String]);
	
	if (rc != T_OK) {
		[[[NSApp delegate] tablesBrowser] setMessage:[NSString stringWithFormat:@"Failed to drop table \"%s\". %s",
									  [selectedTable UTF8String],
									  [[HyperTable errorFromCode:rc] UTF8String]]];
		[[[NSApp delegate] tablesBrowser] indicateDone];
	}
	else {
		NSString * msg = [NSString stringWithFormat:@"Table \"%s\" was dropped.",
						  [selectedTable UTF8String]];
		
		//refresh tables on connection
		FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:connection];
		[fetchTablesOp setCompletionBlock: ^ {
			NSLog(@"Refreshing tables on \"%s\"\n", [[[connection connInfo] address] UTF8String] );
			
			//FIXME: servers view
			//[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
			//[[[NSApp delegate] serversView] deselectAll:self];
			
			[[[NSApp delegate] tablesBrowser] setMessage:msg];
			[[[NSApp delegate] tablesBrowser] indicateDone];
		}];
		
		//start fetching tables
		[[[NSApp delegate] operations] addOperation: fetchTablesOp];
		[fetchTablesOp release];
	}
	
	[selectedTable release];
}

- (IBAction)refreshTables:(id)sender
{
	
	id connection = [[[NSApp delegate] tablesBrowser] getSelectedConnection];
	if (!connection) {
		[[[NSApp delegate] tablesBrowser] setMessage:@"No connection is available"];
		return;
	}
	
	[[[NSApp delegate] tablesBrowser] indicateBusy];
	
	//refresh tables on connection
	FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFromConnection:connection];
	[fetchTablesOp setCompletionBlock: ^ {
		NSLog(@"Refreshing tables on \"%s\"\n", [[[connection connInfo] address] UTF8String] );
		
		//FIXME: servers view
		//[[[NSApp delegate] serversView] reloadItem:nil reloadChildren:YES];
		[[[NSApp delegate] tablesBrowser] indicateDone];
	}];
	
	//start fetching tables
	[[[NSApp delegate] operations] addOperation: fetchTablesOp];
	[fetchTablesOp release];
}

- (IBAction)insertNewRow:(id)sender
{
	id connection = [[[NSApp delegate] tablesBrowser] getSelectedConnection];
	[[[[NSApp delegate] tablesBrowser] newRowController] setConnection:connection];
	[NSApp beginSheet:[[[NSApp delegate] tablesBrowser] insertNewRowPnl] modalForWindow:[[[NSApp delegate] tablesBrowser] window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
	[connection release];
}

- (IBAction)deleteSelectedRow:(id)sender
{
	NSString * selectedRowKeyValue = [[[[NSApp delegate] tablesBrowser] pageSource] selectedRowKeyValue];
	if (!selectedRowKeyValue || [selectedRowKeyValue length] <= 0 ) {
		NSLog(@"No row selected for delete");
		return;
	}
	
	NSString * selectedTable = [[[[NSApp delegate] tablesBrowser] tablesList] selectedTable];
	if (!selectedTable) {
		NSLog(@"No table is selected to insert row");
		return;
	}
	
	NSLog([NSString stringWithFormat:@"Deleteing row with key \"%s\" from table \"%s\".", 
		   [[self selectedRowKeyValue] UTF8String],
		   [selectedTable UTF8String]]);
	
	id connection = [[[NSApp delegate] tablesBrowser] getSelectedConnection];
	if (!connection) {
		[selectedTable release];
		[[[NSApp delegate] tablesBrowser] setMessage:@"Cannot delete selected row. Server is NOT connected."];
		return;
	}
	
	//drop row
	DataPage * currentPage = [[[[NSApp delegate] tablesBrowser] pageSource] page];
	int selectedRowIndex = [[[[NSApp delegate] tablesBrowser] pageSource] selectedRowIndex];
	DataRow * selectedRow = page_row_at_index(currentPage, selectedRowIndex);
	DeleteRowOperation * delOp = [DeleteRowOperation deleteRow:selectedRow
													   inTable:selectedTable
												withConnection:connection];
	
	[[[NSApp delegate] operations] addOperation:delOp];
	[selectedRowKeyValue release];
	[selectedTable release];
	[delOp release];
	[connection release];
}

@end
