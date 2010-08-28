//
//  Cluster.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Cluster.h"
#import "ClustersBrowser.h"

@implementation Cluster

+ (NSEntityDescription *) clusterDescription
{
	return [NSEntityDescription entityForName:@"Cluster" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

+ (Cluster *) clusterWithName:(NSString *)name
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Cluster clusterDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]];
	
	NSError * err = nil;
	NSArray * clustersArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to find cluster with name %@", name);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	
	if (![clustersArray count]) {
		NSLog(@"Cluster with name %@ not found", name);
		return nil;
	}
	
	return [clustersArray objectAtIndex:0];
}

+ (NSArray *) clusters
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Cluster clusterDescription]];
	[r setIncludesPendingChanges:YES];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * clustersArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to fetch clusters list.");
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	return clustersArray;
}

- (NSArray *) members
{
	//return [[self mutableSetValueForKey:@"members"] allObjects];
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Server serverDescription]];
	[r setIncludesPendingChanges:YES];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[r setPredicate:[NSPredicate predicateWithFormat:@"belongsTo = %@", self]];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * membersArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to fetch cluster %@ members.", [self valueForKey:@"name"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	return membersArray;
}

- (void) updateWithCompletionBlock:(void (^)(void)) codeBlock
{
	for (Server * member in [self members]) {
		[member updateWithCompletionBlock:^{
			//update table after status change
			[[[ClustersBrowser sharedInstance] membersTable] reloadData];
		}];
	}
}

- (void) disconnect {}
- (void) reconnectWithCompletionBlock:(void (^)(void)) codeBlock {}
- (BOOL) isConnected { return YES; }

@end
