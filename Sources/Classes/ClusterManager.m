//
//  ClusterManager.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClusterManager.h"


@implementation ClusterManager

- (ClusterManager *) init
{
	if (self = [super init]){
		NSLog(@"Initializing cluster manager.");
		hypertableCache = [[NSMutableDictionary alloc] init];
		hadoopCache = [[NSMutableDictionary alloc] init];
		sshCache = [[NSMutableDictionary alloc] init];
		dataFileName =  @"Clusters.xml";
	}
	return self;
}



- (NSSet *)serversInCluster:(NSManagedObject *)cluster
{
	
}

/*
- (HyperTable *)hypertableOnServer:(NSManagedObject *)server
{
	NSString * ipAddress = [server valueForKey:@"ipAddress"];
	HyperTable * ht = [hypertableCache objectForKey:ipAddress];
	if (ht) {
		return ht;
	}
	else {
		int thriftPort = [[server valueForKey:@"thriftPort"] intValue];
		ht = [HyperTable hypertableAt:ipAddress onPort:thriftPort];
		NSLog(@"Connecting to HyperTable Thrift broker at %s:%d...",
			  [ipAddress UTF8String], thriftPort);
		[hypertableCache setObject:ht forKey:ipAddress];
		return ht;
		
	}	
}
*/

- (SSHClient *)remoteShellOnServer:(NSManagedObject *)server
{
	NSString * ipAddress = [server valueForKey:@"ipAddress"];
	SSHClient * ssh = [sshCache	objectForKey:ipAddress];
	if (ssh) {
		return ssh;
	}
	else {
		int sshPort = [[server valueForKey:@"sshPort"] intValue];
		NSString * sshUserName = [server valueForKey:@"sshUserName"];
		NSString * sshPrivateKeyPath = [server valueForKey:@"sshPrivateKeyPath"];
		
		NSLog(@"Connecting to remote shell at %s:%d...",
			  [ipAddress UTF8String], sshPort);
		ssh = [[SSHClient alloc] initClientTo:ipAddress 
									   onPort:sshPort 
									   asUser:sshUserName 
									  withKey:sshPrivateKeyPath];
		
		int rc = [ssh runCommand:@"lsb_release -a"];
		if (rc) {
			NSLog(@"Failed to open remote shell on server. Code %d", rc);
			NSLog(@"Error: %s", [[ssh error] UTF8String]);
			[ssh release];
			return nil;
		}
		NSLog(@"Connected to server:\n%s", [[ssh output] UTF8String]);
		[sshCache setObject:ssh forKey:ipAddress];
		return ssh;
	}
}



- (void) dealloc
{
	[sshCache release];
	[hypertableCache release];
	[hadoopCache release];
	
	[super dealloc];
}



@end
