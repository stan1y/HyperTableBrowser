//
//  TablesBrowser.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NewTableController.h"
#import "InsertNewRowController.h"
#import "TablesBrowserPageSource.h"
#import "Utility.h"

@interface TablesBrowser : HyperTableBrokersCntrl {
	
	//panel controls
	NewTableController * newTableController;
	InsertNewRowController * newRowController;
	
	NSPanel * newTablePnl;
	NSPanel * insertNewRowPnl;
	NSBrowser * tablesList;
	
	TablesBrowserPageSource * pageSource;
	
	NSButton * newTableBtn;
	NSButton * dropTableBtn;
	//toolbar controls
	NSToolbarItem * refreshBtn;
	NSToolbarItem * newRowBtn;
	NSToolbarItem * dropRowBtn;
	NSToolbar * toolBar;
	
	int allowNewTable;
	int allowDropTable;
	int allowRefresh;
	int allowInsertRow;
	int allowDeleteRow;
}

//toolbar properties 
@property (nonatomic, retain) IBOutlet NSBrowser * tablesList;
@property (nonatomic, retain) IBOutlet NSToolbarItem * refreshBtn;
@property (nonatomic, retain) IBOutlet NSButton * newTableBtn;
@property (nonatomic, retain) IBOutlet NSButton * dropTableBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * newRowBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * dropRowBtn;

@property (nonatomic, retain) IBOutlet NSToolbar * toolBar;

@property (assign) int allowRefresh;
@property (assign) int allowNewTable;
@property (assign) int allowDropTable;
@property (assign) int allowInsertRow;
@property (assign) int allowDeleteRow;

//panel properties
@property (nonatomic, retain) IBOutlet TablesBrowserPageSource * pageSource;

@property (nonatomic, retain) IBOutlet NSPanel * newTablePnl;
@property (nonatomic, retain) IBOutlet NSPanel * insertNewRowPnl;

@property (nonatomic, retain) IBOutlet NewTableController * newTableController;
@property (nonatomic, retain) IBOutlet InsertNewRowController * newRowController;

//tables list opertions
- (IBAction)newTable:(id)sender;
- (IBAction)dropTable:(id)sender;

//toolbar operations
- (IBAction)refreshTables:(id)sender;
- (IBAction)insertNewRow:(id)sender;
- (IBAction)deleteSelectedRow:(id)sender;

//tool bar validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem;

//tablesList delegate's protocol
- (BOOL)browser:(NSBrowser *)browser shouldEditItem:(id)item;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(NSInteger)column;
- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item; //yes means non-expandable

- (id)rootItemForBrowser:(NSBrowser *)browser;
- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item;
- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item;
- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item;

//called by browser's selector
- (IBAction)tableSelectionChanged:(id)sender;

@end
