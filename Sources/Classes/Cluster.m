//
//  Cluster.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Cluster.h"


@implementation Cluster

+ (NSEntityDescription *) clusterDescription
{
	return [NSEntityDescription entityForName:@"Cluster" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
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
		NSLog(@"Error: Failed to fetch defined clusters.");
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	return clustersArray;
}

- (NSSet *) servers
{
	return [self mutableSetValueForKey:@"members"];
}

@end
