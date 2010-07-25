//
//  ToolBarController.m
//
//  Created by Stanislav Yudin on 29/3/2010.
//  Copyright 2010 AwesomeStanlyLabs. All rights reserved.
//

#import "ToolBarController.h"

@implementation ToolBarController

@synthesize newTableBtn;
@synthesize dropTableBtn;

@synthesize toolBar;

@synthesize allowNewTable;
@synthesize allowDropTable;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([toolbarItem isEqual:newTableBtn]) {
		return allowNewTable;
    } else if ( [toolbarItem isEqual:dropTableBtn]) {
		return allowDropTable;
    }
	else {
		return YES;
	}
}

- (void)awakeFromNib
{
	//disallow buttons
	allowNewTable = NO;
	allowDropTable = NO;
	
	//prepare preferences window
	GeneralPreferencesController * general = [[GeneralPreferencesController alloc] initWithNibName:@"PreferencesGeneral" bundle:nil];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, nil]];
	[general release];
}

- (IBAction)newTable:(id)sender
{
}

- (IBAction)dropTable:(id)sender
{
}

- (IBAction)showPreferences:(id)sender
{	
	[[MBPreferencesController sharedController] showWindow:sender];
}

@end
