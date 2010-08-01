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
	NSButton * copyRowKeyButton;
	NSTextField * selectedRowKey;
	NSString * selectedRowKeyValue;

}
@property (assign) int lastDisplayedPageNumber;
@property (nonatomic, retain) NSString * lastDisplayedTableName;
@property (nonatomic, retain) ThriftConnection * lastUsedConnection;
@property (nonatomic, retain) IBOutlet NSButton * refreshButton;
@property (nonatomic, retain) IBOutlet NSButton * nextPageButton;
@property (nonatomic, retain) IBOutlet NSButton * prevPageButton;
@property (nonatomic, retain) IBOutlet NSTextField * pageSizeTextField;

@property (nonatomic, retain) IBOutlet NSTableView * objectsPageView;
@property (nonatomic, retain) IBOutlet NSTextField * objectsPageField;
@property (nonatomic, retain) IBOutlet NSButton * copyRowKeyButton;
@property (nonatomic, retain) IBOutlet NSTextField * selectedRowKey;
@property (nonatomic, retain) NSString * selectedRowKeyValue;

- (void)showFirstPageFor:(NSString *)tableName
		  fromConnection:(ThriftConnection *)connection;
- (void)showPageFor:(NSString *)tableName 
		   fromConnection:(ThriftConnection *)connection
		   withPageNumber:(int)number
		andPageSize:(int)size;

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)copySelectedRowKey:(id)sender;
@end
