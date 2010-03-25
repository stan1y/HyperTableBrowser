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
		if ([item class] == [NSManagedObject class]){
			NSLog(@"Server %s selected ", [[item valueForKey:@"hostname"] UTF8String]);
			//server node selected
			selectedServer = item;
			NSString * hostname = [item valueForKey:@"hostname"];
			[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"Objects Browser - %s", [hostname UTF8String]] ];
		}
		else {
			id serverItem = [ov parentForItem:item];
			selectedServer = serverItem;
			ThriftConnection * connection = [[[NSApp delegate] serversManager] getConnection:[serverItem valueForKey:@"hostname"]];
			if (connection) {
				NSLog(@"Displaying first page of table %s", [item UTF8String]);
				[objectsPageSource showFirstPageFor:item fromConnection:connection];
			} else {
				NSLog(@"No connection to display data for table %s", [item UTF8String]);
				return NO;
			}
		}
		//do selection
		return YES;
	}
	return NO;
}

@end
