//
//  TablesBrowser.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesBrowser.h"
#import <DeleteRowOperation.h>
#import <HyperTable.h>

@implementation TablesBrowser

@synthesize pageSource;
@synthesize selectedTable;
@synthesize tablesList;

@synthesize newTablePnl;
@synthesize insertNewRowPnl;

@synthesize newTableController;
@synthesize newRowController;

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

- (void) dealloc
{
	[selectedTable release];
	[pageSource release];
	[newTablePnl release];
	[newTableController release];
	[insertNewRowPnl release];
	[newRowController release];
	
	[refreshBtn release];
	[newTableBtn release];
	[dropTableBtn release];
	[newRowBtn release];
	[dropRowBtn release];
	[toolBar release];
	
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"Tables Browser closed\n");
}

- (IBAction)newTable:(id)sender
{
	[NSApp beginSheet:[[[NSApp delegate] tablesBrowser] newTablePnl] 
	   modalForWindow:[[[NSApp delegate] tablesBrowser] window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)dropTable:(id)sender
{
	id connection = [self getSelectedConnection];
	if (!connection) {
		[self setMessage:@"Cannot drop table. Server is NOT connected."];
		return;
	}
	
	[self indicateBusy];
	int rc = drop_table([connection thriftClient], [selectedTable UTF8String]);
	
	if (rc != T_OK) {
		[self setMessage:[NSString stringWithFormat:@"Failed to drop table \"%s\". %s",
													  [selectedTable UTF8String],
													  [[HyperTable errorFromCode:rc] UTF8String]]];
		[self indicateDone];
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
			
			[self setMessage:msg];
			[self indicateDone];
		}];
		
		//start fetching tables
		[[[NSApp delegate] operations] addOperation: fetchTablesOp];
		[fetchTablesOp release];
	}
	
	[selectedTable release];
}

- (IBAction)refreshTables:(id)sender
{
	id hypertable = [self getSelectedConnection];
	if (!hypertable) {
		[self setMessage:@"No connection is available"];
		return;
	}
	[self setMessage:@"Reloading tables list items..."];
	[self indicateBusy];
	[hypertable refresh:^ {
		[self setMessage:@"Tables updated sucessfuly."];
		[tablesList loadColumnZero];
		[self indicateDone];
	}];
}

- (IBAction)insertNewRow:(id)sender
{
	id connection = [self getSelectedConnection];
	[[self newRowController] setConnection:connection];
	[NSApp beginSheet:[self insertNewRowPnl] modalForWindow:[self window]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
	[connection release];
}

- (IBAction)deleteSelectedRow:(id)sender
{
	NSString * selectedRowKeyValue = [[self pageSource] selectedRowKeyValue];
	if (!selectedRowKeyValue || [selectedRowKeyValue length] <= 0 ) {
		NSLog(@"No row selected for delete");
		return;
	}
	
	NSString * selectedTable = [[self tablesList] selectedTable];
	if (!selectedTable) {
		NSLog(@"No table is selected to insert row");
		return;
	}
	
	NSLog([NSString stringWithFormat:@"Deleteing row with key \"%s\" from table \"%s\".", 
		   [[self selectedRowKeyValue] UTF8String],
		   [selectedTable UTF8String]]);
	
	id connection = [self getSelectedConnection];
	if (!connection) {
		[self setMessage:@"Cannot delete selected row. Server is NOT connected."];
		return;
	}
	
	//drop row
	DataPage * currentPage = [[self pageSource] page];
	int selectedRowIndex = [[self pageSource] selectedRowIndex];
	DataRow * selectedRow = page_row_at_index(currentPage, selectedRowIndex);
	DeleteRowOperation * delOp = [DeleteRowOperation deleteRow:selectedRow
													   inTable:selectedTable
												withConnection:connection];
	
	[[[NSApp delegate] operations] addOperation:delOp];
	[selectedRowKeyValue release];
	[delOp release];
	[connection release];
}

- (BOOL)browser:(NSBrowser *)browser shouldEditItem:(id)item
{ 
	//edit not supported yet
	return NO; 
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(NSInteger)column
{
	return [[[self getSelectedConnection] tables] count] > 0;
}

//yes means non-expandable
- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item 
{
	if ([item class] == [HyperTable class]) {
		return NO;
	}
	return YES;
}

- (id)rootItemForBrowser:(NSBrowser *)browser
{
	return [self getSelectedConnection];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item
{
	if ([item class] == [HyperTable class])
		return [item ipAddress];
	else {
		return item;
	}

}
- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item
{
	if ([item class] == [HyperTable class])
	{
		id table = [[[self getSelectedConnection] tables] objectAtIndex:index];
		return table;
	}
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
	if ([item class] == [HyperTable class]) {
		return [[[self getSelectedConnection] tables] count];
	}
	return 0;
}


@end
