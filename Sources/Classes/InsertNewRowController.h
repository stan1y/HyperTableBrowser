//
//  InsertNewRowController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModalDialog.h"

@interface InsertNewRowController : ModalDialog {
	NSTextField * errorMessage;
	
	NSTextField * rowKey;
	NSTableView * rowCellsTable;
	NSPopUpButton * tableSelector;
	
	// Internal array of dictionaries.
	// Each dict is expected to have values for 
	// "family" and "qualifier" keys. Later "value"
	// will be setup
	NSMutableArray * rowCells;
	int errorCode;
}

@property (assign) int errorCode;
@property (nonatomic, retain) IBOutlet NSPopUpButton * tableSelector;
@property (nonatomic, retain) IBOutlet NSTextField * rowKey;
@property (nonatomic, retain) IBOutlet NSTableView * rowCellsTable;
@property (nonatomic, retain) IBOutlet NSTextField * errorMessage;

//get & set known cells
@property (nonatomic, retain) NSMutableArray * rowCells;

- (IBAction)createNewRow:(id)sender;
- (IBAction) cancel:(id)sender;
@end
