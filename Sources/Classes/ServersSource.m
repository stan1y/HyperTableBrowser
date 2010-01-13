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
		//displaying tables
		NSSet * items = [item valueForKey:@"tables"];
		int i = 0;
		for (id obj in items) {
			if (i == index) return obj;
			i++;
		}
		return nil;
	}
	else {
		//displaying servers
		NSFetchRequest * r = [[NSFetchRequest alloc] init];
		[r setEntity:[Server entityDescription]];
		NSError * err = nil;
		NSArray * srvList = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
		[r release];
		if (err) {
			[[NSApp delegate] setMessage:@"Failed servers from objects context"];
			[err release];
			return nil;
		}
		return [srvList objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	//server class is expandable
	if ([item entity] == [Server entityDescription])
		return YES;
	
	return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
	if (item) {
		//return number of tables in server item
		return [[item valueForKey:@"tables"] count];
	}
	//return number of servers
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Server entityDescription]];
	NSError * err = nil;
	NSInteger itemsCount = [[[NSApp delegate] managedObjectContext] countForFetchRequest:r error:&err];
	[r release];
	if (err) {
		[[NSApp delegate] setMessage:@"Failed to get number of servers from objects context"];
		[err release];
		return 0;
	}
	NSLog(@"Known servers %d", itemsCount);
	return itemsCount;
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item
{
	if (item) {
		//return hostname of server or name of table
		if ([item entity] == [Server entityDescription])
			return [item valueForKey:@"hostname"];
		else if ([item entity] == [Table entityDescription])
			return [item valueForKey:@"name"];
		else
			return @"Unknown";
	}
	return nil;
}

@end
