//
//  ServersSource.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 1/13/10.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ServersSource.h"

@implementation ServersSource

- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index 
		   ofItem:(id)item
{
	if (item) {
		//table at index
		id tables = [[[[NSApp delegate] serversManager] getConnection:[item valueForKey:@"ipAddress"] ] tables];
		return [tables objectAtIndex:index];
	}
	else {
		//displaying servers
		id servers = [[[NSApp delegate] serversManager] getServers];
		id srv = [servers objectAtIndex:index];
		return srv;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	//server class is expandable
	if ([item class] == [NSManagedObject class]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
	if (item) {
		NSLog(@"UI asking for server tables count");
		id connection = [[[NSApp delegate] serversManager] getConnection:[item valueForKey:@"ipAddress"] ];
		if (!connection) {
			NSLog(@"Failed to get connection for %s", [[item valueForKey:@"ipAddress"] UTF8String]);
			[[[NSApp delegate] serversManager] reconnectServer:item];
			return 0;
		}
		int tablesCount = [[connection tables] count];
		NSLog(@"%d tables found on server %s", tablesCount, [[item valueForKey:@"ipAddress"] UTF8String]);
		return tablesCount;
	}
	else {
		NSLog(@"UI asking for servers count");
		int serversCount = [[[[NSApp delegate] serversManager] getServers] count];
		NSLog(@"%d servers are known", serversCount);
		return serversCount;
	}

}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item
{
	if ([item class] == [NSManagedObject class])
		return [item valueForKey:@"ipAddress"];
	else
		return item;
}

@end
