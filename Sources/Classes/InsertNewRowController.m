//
//  InsertNewRowController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "InsertNewRowController.h"
#import "SetRowOperation.h"
#import "ClustersBrowser.h"
#import "TablesBrowser.h"
#import "Activities.h"

@implementation InsertNewRowController

@synthesize tableSelector;
@synthesize rowKey;
@synthesize rowCellsTable;
@synthesize errorMessage;
@synthesize rowCells;

@synthesize errorCode;


- (void) awakeFromNib
{
	rowCells = [[NSMutableArray alloc] init];
}

- (void)dealloc
{
	[errorMessage release];
	[tableSelector release];
	[rowCellsTable release];
	[rowKey release];
	[rowCells release];
	
	[super dealloc];
}

- (IBAction)createNewRow:(id)sender
{
	if (!rowCells && ![rowCells count]) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Row cells are empty. Nothing to insert."];
	}
	
	NSString * tableName = [[tableSelector selectedItem] title];
	if ( ![tableName length]) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify row key to insert."];
	}
	/*
	[errorMessage setHidden:YES];
	
	DataPage * newRowPage = page_new();
	DataRow * newRow = row_new([[rowKey stringValue] UTF8String]);
	newRow->rowKey = [[rowKey stringValue] UTF8String];
	page_append(newRowPage, newRow);
	
	//populate row with cells
	for (NSDictionary * cellDict in rowCells) {
		DataCell * cell = cell_new(NULL, NULL);
		cell_set(cell, [[cellDict valueForKey:@"family"] UTF8String],
				 [[cellDict valueForKey:@"qualifier"] UTF8String],
				 [[cellDict valueForKey:@"value"] UTF8String], 0);
		row_append(newRow, cell);
	}
	
	Server * selectedServer = [[ClustersBrowser sharedInstance] selectedServer];
	
	SetRowOperation * setRowOp = [SetRowOperation setRow:newRow
												fromPage:newRowPage
												 inTable:tableName
												onServer:selectedServer];
	[setRowOp setCompletionBlock: ^{
		if ([setRowOp errorCode]) {
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			[dict setValue:@"Failed to create new row" forKey:NSLocalizedDescriptionKey];
			NSError * error = [NSError errorWithDomain:@"HyperTableBrowser" code:errorCode userInfo:dict];
			[[NSApplication sharedApplication] presentError:error];
		}
		else {
			//refresh page in tables browser
			[[TablesBrowser sharedInstance] tableSelectionChanged:sender];
		}
		
		//remove allocated data
		page_clear(newRowPage);
		free(newRowPage);

	}];
	
	//start async insert
	[[Activities sharedInstance] appendOperation:setRowOp withTitle:[NSString stringWithFormat:@"Creating new row with key %@ in table %@ on server %@", [rowKey stringValue], tableName, [selectedServer valueForKey:@"serverName"]] ];
	[setRowOp release];
	 */
	
	//close dialog
	[self hideModal];
}

- (void) cancel:(id)sender
{
	[self hideModal];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [rowCells count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex
{
	NSLog(@"Reading cell %@ at index %d", [[aTableColumn identifier] UTF8String], rowIndex);
	return [[rowCells objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	NSLog(@"Setting cell at index %d, %@ = %@", rowIndex, [[aTableColumn identifier] UTF8String], [anObject UTF8String]);
	[[rowCells objectAtIndex:rowIndex] setValue:anObject forKey:[aTableColumn identifier]];
}


@end
