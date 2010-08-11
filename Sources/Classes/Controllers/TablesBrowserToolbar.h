//
//  TablesBrowserToolbar.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FetchTablesOperation.h>
#import <DeleteRowOperation.h>

@interface TablesBrowserToolbarController : NSObject {
	NSToolbarItem * newTableBtn;
	NSToolbarItem * dropTableBtn;
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

@property (nonatomic, retain) IBOutlet NSToolbarItem * refreshBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * newTableBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * dropTableBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * newRowBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * dropRowBtn;

@property (nonatomic, retain) IBOutlet NSToolbar * toolBar;

@property (assign) int allowRefresh;
@property (assign) int allowNewTable;
@property (assign) int allowDropTable;
@property (assign) int allowInsertRow;
@property (assign) int allowDeleteRow;

- (IBAction)newTable:(id)sender;
- (IBAction)dropTable:(id)sender;
- (IBAction)refreshTables:(id)sender;

- (IBAction)insertNewRow:(id)sender;
- (IBAction)deleteSelectedRow:(id)sender;


@end
