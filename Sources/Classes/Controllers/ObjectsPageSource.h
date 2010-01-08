//
//  ObjectsPageSource.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/16/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PageSource.h>
#import <ThriftConnection.h>

@interface ObjectsPageSource : PageSource {
		
	//label to display selected object info
	NSTextField * selectedObjectRowKey;
	NSTextField * selectedObjectCellsCount;
	NSTextField * selectedObjectTotalCount;
	
	// table_name->DataRow with keys for rows
	NSMutableDictionary * keysDict;
	
	//view used to display source
	NSTableView * objectsPageView;
	
	//last used args for showPageFor
	NSString * lastDisplayedObjectType;
	ThriftConnection * lastUsedConnection;
	int lastDisplayedPageNumber;
	
	//paging controls
	NSButton * nextPageButton;
	NSButton * prevPageButton;
	NSTextField * pageSizeTextField;
	NSButton * refreshButton;
	
	//label to display page info
	NSTextField * objectsPageField;

}

@property (assign) NSString * lastDisplayedObjectType;
@property (assign) ThriftConnection * lastUsedConnection;
@property (readwrite) int lastDisplayedPageNumber;
@property (assign) IBOutlet NSButton * refreshButton;
@property (assign) IBOutlet NSButton * nextPageButton;
@property (assign) IBOutlet NSButton * prevPageButton;
@property (assign) IBOutlet NSTextField * pageSizeTextField;

@property (assign) IBOutlet NSTableView * objectsPageView;
@property (assign) IBOutlet NSTextField * objectsPageField;
@property (assign) IBOutlet NSTextField * selectedObjectRowKey;
@property (assign) IBOutlet NSTextField * selectedObjectCellsCount;
@property (assign) IBOutlet NSTextField * selectedObjectTotalCount;

- (void)showFirstPageFor:(NSString *)objectType
	 fromConnection:(ThriftConnection *)connection;

- (void)showPageFor:(NSString *)objectType 
		   fromConnection:(ThriftConnection *)connection
		   withPageNumber:(int)number andPageSize:(int)size;

- (void)refreshKeysFor:(NSString *)objectType
		fromConnection:(ThriftConnection *)conenction;

- (DataRow *)requestKeysFor:(NSString *)objectType
		 fromConnection:(ThriftConnection *)conenction;

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
- (IBAction)refresh:(id)sender;
@end
