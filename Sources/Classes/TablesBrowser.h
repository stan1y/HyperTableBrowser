//
//  TablesBrowser.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TablesBrowserPageSource.h"
#import "ModalDialog.h"
#import "Utility.h"

@interface TablesBrowser : HyperTableBrokersCntrl {
	ModalDialog * createNewTableDialog;
	ModalDialog * insertNewRowDialog;

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

@property (nonatomic, retain) IBOutlet ModalDialog * insertNewRowDialog;
@property (nonatomic, retain) IBOutlet ModalDialog * createNewTableDialog;

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

//singleton
+ (TablesBrowser *) sharedInstance;

//dialog operations
- (IBAction)createNewTable:(id)sender;
- (IBAction)insertNewRow:(id)sender;

//toolbar operations
- (IBAction)deleteSelectedRow:(id)sender;
- (IBAction)refreshTables:(id)sender;
- (IBAction)dropSelectedTable:(id)sender;

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
