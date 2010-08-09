//
//  TablesBrowser.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NewTableController.h>
#import <InsertNewRowController.h>
#import <HyperTableOperationController.h>
#import <TablesBrowserPageSource.h>
#import <TablesBrowserToolbar.h>

@interface TablesBrowser : HyperTableOperationController {
	NewTableController * newTableController;
	InsertNewRowController * newRowController;
	TablesBrowserToolbarController * toolbarController;
	
	NSPanel * newTablePnl;
	NSPanel * insertNewRowPnl;
	
	TablesBrowserPageSource * pageSource;
}
@property (nonatomic, retain) IBOutlet TablesBrowserToolbarController * toolbarController;
@property (nonatomic, retain) IBOutlet TablesBrowserPageSource * pageSource;

@property (nonatomic, retain) IBOutlet NSPanel * newTablePnl;
@property (nonatomic, retain) IBOutlet NSPanel * insertNewRowPnl;

@property (nonatomic, retain) IBOutlet NewTableController * newTableController;
@property (nonatomic, retain) IBOutlet InsertNewRowController * newRowController;

@end
