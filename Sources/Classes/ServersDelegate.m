//
//  ServersDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import "ServersDelegate.h"


@implementation ServersDelegate

@synthesize knownServersController, objectsPageSource;

-(BOOL)outlineView:(NSOutlineView *)ov 
  isItemExpandable:(id)item 
{
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)ov 
   shouldSelectItem:(id)item 
{
	if (true) {
		[objectsPageSource showFirstPageFor:item fromConnection:nil];
	}
	else {
		//server node selected
		selectedServer = item;
		//change title
		[[[NSApp delegate] window] setTitle:[NSString stringWithFormat:@"Objects Browser - %s", [item UTF8String]] ];
	}
	//do selection
	return YES;
}

@end
