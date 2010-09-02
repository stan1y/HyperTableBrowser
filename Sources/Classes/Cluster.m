//
//  Cluster.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
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
	[r setPredicate:[NSPredicate predicateWithFormat:@"clusterName = %@", name]];
	
	NSError * err = nil;
	NSArray * clustersArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to find cluster %@", name);
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
	//NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	//[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
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

- (Server<ClusterMember> *)memberWithID:(id)memberID
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Server serverDescription]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@", memberID]];
	NSError * err = nil;
	NSArray * membersArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to fetch cluster with ID '%@'.", memberID);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	
	if ([membersArray count] == 1) {
		return [membersArray objectAtIndex:0];
	}
	else {
		int rc = NSRunAlertPanel(@"Serious Internal Error", [NSString stringWithFormat:@"Failed to find member with id '%@'", memberID] , @"Exit", @"Continue", nil);
		if (rc == 1) {
			[NSApp terminate:nil];
		}
		return nil;
	}
}

- (NSArray *) members
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Server serverDescription]];
	//NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	[r setPredicate:[NSPredicate predicateWithFormat:@"belongsTo = %@", self]];
	//[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * membersArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to fetch %@ members.", [self valueForKey:@"clusterName"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	return membersArray;
}

@end
