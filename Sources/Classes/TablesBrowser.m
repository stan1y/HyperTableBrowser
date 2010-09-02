//
//  TablesBrowser.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "TablesBrowser.h"
#import "DeleteRowOperation.h"
#import "HyperTable.h"
#import "Activities.h"
#import "Protocols.h"
#import "Table.h"

@implementation TablesBrowser

@synthesize pageSource;
@synthesize tablesList;

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

@synthesize createNewTableDialog;
@synthesize insertNewRowDialog;

//	Singleton
static TablesBrowser * sharedBrowser = nil;
+ (TablesBrowser *) sharedInstance {
    return sharedBrowser;
}

- (id) _initWithWindow:(id)window
{
	if (!(self = [super initWithWindow:window]))
		return nil;
	
	NSLog(@"Initializing Tables Browser [%@]", window);	
	allowNewTable = 0;
	allowDropTable = 0;
	allowRefresh = 0;
	allowInsertRow = 0;
	allowDeleteRow = 0;
	
	return self;
}

- (id) initWithWindow:(id)window
{	
	if(sharedBrowser == nil) {
        sharedBrowser = [[TablesBrowser alloc] _initWithWindow:window];
    }
	return [TablesBrowser sharedInstance];
}

- (void) dealloc
{
	[pageSource release];
	[refreshBtn release];
	[newTableBtn release];
	[dropTableBtn release];
	[newRowBtn release];
	[dropRowBtn release];
	[toolBar release];
	
	[createNewTableDialog release];
	[insertNewRowDialog release];
	
	[super dealloc];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([toolbarItem isEqual:newTableBtn]) {
		return [[self selectedBroker] isConnected];
    } else if ( [toolbarItem isEqual:dropTableBtn]) {
		return [tablesList selectedRowInColumn:0] >= 0;
    } else if ( [toolbarItem isEqual:refreshBtn]) {
		return [[self selectedBroker] isConnected];
	} else if ( [toolbarItem isEqual:newRowBtn]) {
		return [tablesList selectedRowInColumn:0] >= 0;
	} else if ( [toolbarItem isEqual:dropRowBtn]) {
		return ([pageSource selectedRowKeyValue] != nil) && ([[pageSource selectedRowKeyValue] length] > 0);
	}
	
	return YES;
}

- (IBAction) showWindow:(id)sender
{
	[super showWindow:sender];
	[self updateBrokersWithCompletionBlock:^(BOOL success) {
		[self refreshTables:sender];
	}];
	
}

- (IBAction)refreshTables:(id)sender
{
	[tablesList loadColumnZero];
}

- (IBAction)deleteSelectedRow:(id)sender
{
	if ([[self pageSource] selectedRowIndex] >= 0) {
		NSLog(@"Deleteing row with key '%@' from table '%@'.", [[self pageSource] selectedRowKeyValue], [[tablesList selectedCellInColumn:0] stringValue]);
		
		id broker = [self selectedBroker];
		if (!broker) {
			return;
		}
		
		//drop row
		DataPage * currentPage = [[self pageSource] page];
		DataRow * selectedRow = page_row_at_index(currentPage, [[self pageSource] selectedRowIndex]);
		DeleteRowOperation * delOp = [DeleteRowOperation deleteRow:selectedRow
														   inTable:[[tablesList selectedCellInColumn:0] stringValue]
														  onServer:broker];
		
		[delOp setCompletionBlock: ^{
			if ([delOp errorCode]) {
				NSRunAlertPanel(@"Operation failed", [HyperTable errorFromCode:[delOp errorCode]], @"Continue", nil, nil);
			}
		}];
		
		//start async delete
		[[Activities sharedInstance] appendOperation:delOp withTitle:[NSString stringWithFormat:@"Deleting row with key %@ from table %@ on server %@", [[self pageSource] selectedRowKeyValue], [[tablesList selectedCellInColumn:0] stringValue], [broker valueForKey:@"name"]]];
		[delOp release];
	}
	else {
		NSLog(@"No row selected to delete");
	}
}

- (IBAction) createNewTable:(id)sender
{
	[createNewTableDialog showModalForWindow:[self window]];
}

- (IBAction) insertNewRow:(id)sender
{
	[insertNewRowDialog showModalForWindow:[self window]];
}

- (IBAction)dropSelectedTable:(id)sender
{
	// FIXME: Not implemented 
}


- (BOOL)browser:(NSBrowser *)browser shouldEditItem:(id)item
{ 
	// FIXME: Not implemented 
	return NO; 
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(NSInteger)column
{
	return [[[self selectedBroker] tablesArray] count] > 0;
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item 
{
	return YES; //yes means non-expandable
}

- (id)rootItemForBrowser:(NSBrowser *)browser
{
	return [self selectedBroker];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item
{
	if ([item class] == [Table class])
		return [item valueForKey:@"tableID"];
	else {
		return item;
	}

}
- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item
{
	if ([item conformsToProtocol:@protocol(CellStorage)]) {
		return [[[self selectedBroker] tablesArray] objectAtIndex:index];
	}
	return nil;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
	if ([item conformsToProtocol:@protocol(CellStorage)]) {
		return [[item tablesArray] count];
	}
	return 0;
}


- (IBAction)tableSelectionChanged:(id)sender
{
	[[[self pageSource] pageTableView] deselectAll:sender];
	[[self pageSource] deselectRow:sender];
	
	[pageSource showFirstPageFor:[[tablesList selectedCellInColumn:0] stringValue]
				  fromStorage:[self selectedBroker]];
}

@end
