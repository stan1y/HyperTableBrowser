//
//  NewTableController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 25/7/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Utility.h"
#import "ModalDialog.h"

@interface NewTableController : ModalDialog {

	NSTextField * tableNameField;
	NSTextField * schemaContents;
	NSButton * createButton;
	NSTableView * schemasView;
	
	HyperTable * connection;
}

@property (nonatomic, retain) HyperTable * connection;
@property (nonatomic, retain) IBOutlet NSTextField * schemaContents;
@property (nonatomic, retain) IBOutlet NSButton * createButton;
@property (nonatomic, retain) IBOutlet NSTableView * schemasView;
@property (nonatomic, retain) IBOutlet NSTextField * tableNameField;

- (IBAction)createTable:(id)sender;

- (void) createTableWithName:(NSString *)tableName
				   andSchema:(NSString *)schemaContent
					onServer:(HyperTable *)connection;

@end
