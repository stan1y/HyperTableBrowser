//
//  ToolBarController.h
//
//  Created by Stanislav Yudin on 29/3/2010.
//  Copyright 2010 AwesomeStanlyLabs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"
#import "GeneralPreferencesController.h"

@interface ToolBarController : NSObject {
	NSToolbarItem * newTableBtn;
	NSToolbarItem * dropTableBtn;
	
	NSToolbar * toolBar;
	
	BOOL allowNewTable;
	BOOL allowDropTable;
}

@property (nonatomic, retain) IBOutlet NSToolbarItem * newTableBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * dropTableBtn;

@property (nonatomic, retain) IBOutlet NSToolbar * toolBar;

@property (assign) BOOL allowNewTable;
@property (assign) BOOL allowDropTable;

- (IBAction)newTable:(id)sender;
- (IBAction)dropTable:(id)sender;

- (IBAction)showPreferences:(id)sender;
- (IBAction)showHideHQL:(id)sender;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem;
@end
