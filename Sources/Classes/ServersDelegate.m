//
//  ServersDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ServersDelegate.h"

@implementation ServersDelegate

@synthesize objectsPageSource, selectedServer, connectionController;

- (BOOL)outlineView:(NSOutlineView *)ov 
   shouldSelectItem:(id)item 
{
	if (item != nil) {
		if ([item entity] == [HyperTableServer entityDescription]){
			//server node selected
			selectedServer = item;
			NSString * hostname = [item valueForKey:@"hostname"];
			[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"Objects Browser - %s", [hostname UTF8String]] ];
		}
		else {
			ThriftConnection * connection = [[[NSApp delegate] serversManager] getConnectionForServer:[item server]];
			if (connection) {
				NSLog(@"Displaying first page");
				[objectsPageSource showFirstPageFor:[item valueForKey:@"name"] fromConnection:connection];
			} else {
				[[[NSApp delegate] serversManager] reconnectServer:[item server]];
				return NO;
			}
		}
		//do selection
		return YES;
	}
	return NO;
}

@end
