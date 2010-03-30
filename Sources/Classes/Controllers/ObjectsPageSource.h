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
	
	// table_name:DataRow with keys for rows
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
	
	//button to copy selected object key to paste
	NSButton * copyObjectKeyButton;
	NSTextField * selectedObjectKey;

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
@property (assign) IBOutlet NSButton * copyObjectKeyButton;
@property (assign) IBOutlet NSTextField * selectedObjectKey;

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
