//
//  ClusterManager.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClusterManager.h"


@implementation ClusterManager

- (ClusterManager *) init
{
	[super init];
	NSLog(@"Initializing cluster manager.");
	hypertableCache = [[NSMutableDictionary alloc] init];
	hadoopCache = [[NSMutableDictionary alloc] init];
	sshCache = [[NSMutableDictionary alloc] init];
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
	id members = [cluster mutableSetValueForKey:@"members"];
	NSLog(@"There are %d members in %s", [members count], [[cluster valueForKey:@"name"] UTF8String]);
}

- (HyperTable *)hypertableOnServer:(NSManagedObject *)server
{
	NSString * ipAddress = [server stringForKey:@"ipAddress"];
	HyperTable * ht = [hypertableCache objectForKey:ipAddress];
	if (ht) {
		return ht;
	}
	else {
		int thriftPort = [[server valueForKey:@"thriftPort"] intValue];
		ht = [HyperTable hypertableAt:ipAddress onPort:thriftPort];

		NSLog(@"Connecting to HyperTable Thrift broker at %s:%d...",
			  [ipAddress UTF8String], thriftPort);
		
		[ht reconnect];
		return ht;
		
	}	
}

- (SSHClient *)remoteShellOnServer:(NSManagedObject *)server
{
	NSString * ipAddress = [server stringForKey:@"ipAddress"];
	SSHClient * ssh = [sshCache	objectForKey:ipAddress];
	if (ssh) {
		return ssh;
	}
	else {
		int sshPort = [[server valueForKey:@"sshPort"] intValue];
		NSString * sshUserName = [server stringForKey:@"sshUserName"];
		NSString * sshPrivateKeyPath = [server stringForKey:@"sshPrivateKeyPath"];
		
		NSLog(@"Connecting to remote shell at %s:%d...",
			  [ipAddress UTF8String], sshPort);
		ssh = [SSHClient initClientTo:ipAddress onPort:sshPort asUser:sshUserName withKey:sshPrivateKeyPath];
		
		int rc = [ssh runCommand:@"lsb_release -a"];
		if (rc) {
			NSLog(@"Failed to open remote shell on server. Code %d", rc);
			NSLog(@"Error: %s", [[ssh error] UTF8String]);
			return nil;
		}
		NSLog(@"Connected to server:\n%s", [[ssh output] UTF8String]);
		return ssh;
	}
}

- (void) dealloc
{
	[hypertableCache release];
	[hadoopCache release];
	[sshCache release];
	[super dealloc];
}

- (NSArray *)allHypertableBrokers
{
	NSMutableArray * found = [[NSMutableArray alloc] init];
	for (id cluster in [self clusters]) {
		id server = [cluster stringForKey:@"hypertableThriftBroker"];
		HyperTable * hypertable = [self hypertableOnServer:server];
		[found addObject:hypertable];
	}
	return found;
}

@end
