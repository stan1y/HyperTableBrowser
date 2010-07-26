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

@interface NewTableController : NSWindowController {

	NSTextField * tableNameField;
	NSTextField * schemaContents;
	NSButton * createButton;
	NSPopUpButton * serverSelector;
	NSTableView * schemasView;
	NSProgressIndicator * indicator;
	NSTextField * statusField;
}

@property (assign) IBOutlet NSTextField * schemaContents;
@property (assign) IBOutlet NSButton * createButton;
@property (assign) IBOutlet NSPopUpButton * serverSelector;
@property (assign) IBOutlet NSTableView * schemasView;
@property (assign) IBOutlet NSProgressIndicator * indicator;
@property (assign) IBOutlet NSTextField * statusField;
@property (assign) IBOutlet NSTextField * tableNameField;

- (IBAction)createTable:(id)sender;

- (void) createTableWithName:(NSString *)tableName
				   andSchema:(NSString *)schemaContent
					onServer:(ThriftConnection *)connection;

//show message on window's status bar
- (void)setMessage:(NSString*)message;
//start operation indicator
- (void)indicateBusy;
//stop operation indicator
- (void)indicateDone;
//set available connections
- (IBAction)updateConnections:(id)sender;
//get connection selected by user in drop down 
- (id)getSelectedConnection;
//called when hql windows is about to close
- (void)windowWillClose:(NSNotification *)notification;
@end
