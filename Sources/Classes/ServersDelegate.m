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

- (BOOL)outlineView:(NSOutlineView *)ov 
   shouldSelectItem:(id)item 
{
	if (item != nil) {
		if ([item entity] == [Server entityDescription]){
			//server node selected
			selectedServer = item;
			NSString * hostname = [item valueForKey:@"hostname"];
			[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"Objects Browser - %s", [hostname UTF8String]] ];
		}
		else {
			ThriftConnection * serverConnection = [[NSApp delegate] getConnectionForServer:[item server]];
			[objectsPageSource showFirstPageFor:[item valueForKey:@"name"] fromConnection:serverConnection];
		}

		//do selection
		return YES;
	}
	return NO;
}

@end
