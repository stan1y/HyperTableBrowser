//
//  TablesBrowserPageSource.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PageSource.h"

@interface TablesBrowserPageSource : PageSource {
	//view used to display source
	NSTableView * pageTableView;
	
	//last used args for showPageFor
	NSString * lastDisplayedTableName;
	NSManagedObject<CellStorage> * lastUsedStorage;
	int lastDisplayedPageNumber;
	
	//paging controls
	NSButton * nextPageButton;
	NSButton * prevPageButton;
	NSTextField * pageSizeTextField;
	NSButton * refreshButton;
	
	//label to display page info
	NSTextField * objectsPageField;
	
	//button to copy selected object key to paste
	NSButton * copyRowKeyButton;
	NSTextField * selectedRowKey;
	NSString * selectedRowKeyValue;
	int selectedRowIndex;
	
	//activity indicator
	NSProgressIndicator * indicator;
}
@property (assign) int lastDisplayedPageNumber;

@property (nonatomic, retain) NSString * lastDisplayedTableName;
@property (nonatomic, retain) NSManagedObject<CellStorage> * lastUsedStorage;

@property (nonatomic, retain) IBOutlet NSProgressIndicator * indicator;
@property (nonatomic, retain) IBOutlet NSButton * refreshButton;
@property (nonatomic, retain) IBOutlet NSButton * nextPageButton;
@property (nonatomic, retain) IBOutlet NSButton * prevPageButton;
@property (nonatomic, retain) IBOutlet NSTextField * pageSizeTextField;

@property (nonatomic, retain) IBOutlet NSTableView * pageTableView;
@property (nonatomic, retain) IBOutlet NSTextField * pageInfoField;
@property (nonatomic, retain) IBOutlet NSButton * copyRowKeyButton;
@property (nonatomic, retain) IBOutlet NSTextField * selectedRowKey;
@property (nonatomic, retain) NSString * selectedRowKeyValue;
@property (nonatomic) int selectedRowIndex;

- (void)showFirstPageFor:(NSString *)tableName
			  fromStorage:(NSManagedObject<CellStorage> *)storage;

- (void)showPageFor:(NSString *)tableName 
		 fromStorage:(NSManagedObject<CellStorage> *)storage
	 withPageNumber:(int)number
		andPageSize:(int)size;

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)copySelectedRowKey:(id)sender;
- (IBAction)deselectRow:(id)sender;
@end