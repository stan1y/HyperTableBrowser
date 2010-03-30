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
}

@property (nonatomic, retain) IBOutlet NSToolbarItem * newTableBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem * dropTableBtn;

- (IBAction)newTable:(id)sender;
- (IBAction)dropTable:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
