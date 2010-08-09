//
//  NewTableController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 25/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <TableSchema.h>
#import <FetchTablesOperation.h>

@interface NewTableController : NSViewController {

	NSTextField * tableNameField;
	NSTextField * schemaContents;
	NSButton * createButton;
	NSTableView * schemasView;
	
	ThriftConnection * connection;
}

@property (nonatomic, retain) ThriftConnection * connection;
@property (nonatomic, retain) IBOutlet NSTextField * schemaContents;
@property (nonatomic, retain) IBOutlet NSButton * createButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton * serverSelector;
@property (nonatomic, retain) IBOutlet NSTableView * schemasView;
@property (nonatomic, retain) IBOutlet NSTextField * tableNameField;

- (IBAction)createTable:(id)sender;

- (void) createTableWithName:(NSString *)tableName
				   andSchema:(NSString *)schemaContent
					onServer:(ThriftConnection *)connection;

@end
