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
#import <FetchPageOperation.h>

@interface ObjectsPageSource : PageSource {
	//view used to display source
	NSTableView * objectsPageView;
	
	//last used args for showPageFor
	NSString * lastDisplayedTableName;
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
	NSTextField * selectedRowKey;

}

@property (assign) NSString * lastDisplayedTableName;
@property (assign) ThriftConnection * lastUsedConnection;
@property (readwrite) int lastDisplayedPageNumber;
@property (assign) IBOutlet NSButton * refreshButton;
@property (assign) IBOutlet NSButton * nextPageButton;
@property (assign) IBOutlet NSButton * prevPageButton;
@property (assign) IBOutlet NSTextField * pageSizeTextField;

@property (assign) IBOutlet NSTableView * objectsPageView;
@property (assign) IBOutlet NSTextField * objectsPageField;
@property (assign) IBOutlet NSButton * copyObjectKeyButton;
@property (assign) IBOutlet NSTextField * selectedRowKey;

- (void)showFirstPageFor:(NSString *)tableName
		  fromConnection:(ThriftConnection *)connection;
- (void)showPageFor:(NSString *)tableName 
		   fromConnection:(ThriftConnection *)connection
		   withPageNumber:(int)number
		andPageSize:(int)size;

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
- (IBAction)refresh:(id)sender;
@end
