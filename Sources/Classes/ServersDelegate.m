//
//  ServersDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ServersDelegate.h"

@implementation ServersDelegate

@synthesize objectsPageSource;
@synthesize selectedServer;
@synthesize connectionController;

- (BOOL)outlineView:(NSOutlineView *)ov 
   shouldSelectItem:(id)item 
{	
	ToolBarController * toolbar = [[NSApp delegate] toolBarController];
	if (item != nil) {
		if ([item class] == [NSManagedObject class]){
			//server node selected
			selectedServer = item;
			ThriftConnection * connection = [[[NSApp delegate] serversManager] getConnection:[selectedServer valueForKey:@"ipAddress"]];
			//allow new table
			if (connection) {
				NSLog(@"Server \"%s\" is ready\n", [[item valueForKey:@"ipAddress"] UTF8String]);
				
				toolbar.allowNewTable = 1;
				toolbar.allowDropTable = 0;
				[[toolbar toolBar] validateVisibleItems];
				
				NSString * ipAddress = [item valueForKey:@"ipAddress"];
				[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"HyperTable Browser @ %s", [ipAddress UTF8String]] ];
			}
			else {
				NSLog(@"Server \"%s\" is NOT connected!\n", [[item valueForKey:@"ipAddress"] UTF8String]);
				
				toolbar.allowNewTable = 0;
				toolbar.allowDropTable = 0;
				[[toolbar toolBar] validateVisibleItems];
			}

			
		}
		else {
			id serverItem = [ov parentForItem:item];
			selectedServer = serverItem;
			ThriftConnection * connection = [[[NSApp delegate] serversManager] getConnection:[selectedServer valueForKey:@"ipAddress"]];
			if (connection) {
				//table selected, so allow buttons in toolbar
				toolbar.allowNewTable = 1;
				toolbar.allowDropTable = 1;
				[[toolbar toolBar] validateVisibleItems];
				
				NSLog(@"Displaying first page of table %s\n", [item UTF8String]);
				[objectsPageSource showFirstPageFor:item fromConnection:connection];
			} else {
				NSLog(@"No connection to display data for table %s\n", [item UTF8String]);
				return NO;
			}
		}
		//do selection
		return YES;
	}
	else {
		NSLog(@"Disabling toolbar buttons\n");
		//diable toolbar
		toolbar.allowNewTable = NO;
		toolbar.allowDropTable = NO;
		return NO;
	}
}

@end
