//
//  ClusterManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClusterManager.h"


@implementation ClusterManager
/*
+ (ClusterManager *) clusterManagerFromFile:(NSString *)filename
{
	NSLog(@"Clusters description file: %s", [filename UTF8String]);
	ClusterManager * cm = [[ClusterManager alloc] init];
	[cm setDataFileName:filename];
	return cm;
}*/

- (ClusterManager *) init
{
	NSLog(@"Initializing cluster manager.");
	hypertableCache = [[NSMutableDictionary alloc] init];
	hadoopCache = [[NSMutableDictionary alloc] init];
	[self setDataFileName:@"Clusters.xml"];
	return self;
}

- (NSArray *)clusters
{
	NSLog(@"Reading clusters...\n");
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[NSEntityDescription entityForName:@"Cluster" 
							 inManagedObjectContext:[self managedObjectContext]]];
	[r setIncludesPendingChanges:YES];
	NSError * err = nil;
	NSArray * clustersArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get clusters from data file.");
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	NSLog(@"There are %d clusters known.\n", [clustersArray count]);
	return [clustersArray retain];
}

- (id)serversInCluster:(NSManagedObject *)cluster
{
	NSLog(@"Reading members of %s...", [[cluster valueForKey:@"name"] UTF8String]);
	id members = [cluster valueForKey:@"members"];
	NSLog(@"There are %d members in %s", [members count], [[cluster valueForKey:@"name"] UTF8String]);
}

- (HyperTable *)hypertableOnServer:(NSManagedObject *)server
{
	NSString * ipAddress = [server valueForKey:@"ipAddress"];
	HyperTable * ht = [hypertableCache objectForKey:ipAddress];
	if (ht) {
		return ht;
	}
	else {
		id hypertableInfo = [server valueForKey:@"hypertable"];
		int port = [[hypertableInfo valueForKey:@"port"] intValue];
		ht = [HyperTable hypertableAt:ipAddress onPort:port];

		NSLog(@"Connecting to HyperTable Thrift broker at %s:%d...",
			  [ipAddress UTF8String], port);
		
		[ht reconnect];
		return ht;
		
	}	
}

- (void) dealloc
{
	[hypertableCache release];
	[hadoopCache release];
	[super dealloc];
}

- (NSArray *)allHypertableBrokers
{
	NSMutableArray * found = [[NSMutableArray alloc] init];
	for (id cluster in [self clusters]) {
		id server = [cluster valueForKey:@"hypertableThriftBroker"];
		HyperTable * hypertable = [self hypertableOnServer:server];
		[found addObject:hypertable];
	}
	return found;
}

@end
