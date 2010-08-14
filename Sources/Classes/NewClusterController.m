//
//  NewClusterController.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "NewClusterController.h"

@implementation NewClusterController

@synthesize clusterName;
@synthesize masterAddress;
@synthesize sshPort;
@synthesize userName;
@synthesize password;
@synthesize hadoopBroker;
@synthesize hypertableBroker;

- (void) dealloc
{
	[clusterName release];
	[masterAddress release];
	[sshPort release];
	[userName release];
	[password release];
	[hadoopBroker release];
	[hypertableBroker release];
}

- (IBAction) cancel:(id)sender
{
	//close dialog
	[[[self view] window] orderOut:sender];
	
	//quit app if no clusters
	if ( ![[[[NSApp delegate] clusterManager] clusters] count] ) {
		NSLog(@"Quiting application, new cluster dialog was canceled with no defined clusters");
		[NSApp terminate:nil];
	}
}

- (IBAction) saveCluster:(id)sender
{
	if ( ![[clusterName stringValue] length] ) {
		NSLog(@"Empty cluster name!");
		return;
	}
	if ( ![[masterAddress stringValue] length] ) {
		NSLog(@"Empty master address!");
		return;
	}
	if ( ![[userName stringValue] length] ) {
		NSLog(@"Empty user name!");
		return;
	}
	if ( ![[password stringValue] length] ) {
		NSLog(@"Empty password!");
		return;
	}
	
	//ssh port number?
	NSNumber * portNum;
	if ([[sshPort stringValue] length]) {
		portNum = [NSNumber numberWithInt:[sshPort intValue]];
	}
	else {
		portNum = [NSNumber numberWithInt:22];
	}

	
	NSLog(@"Saving new cluster");
	NSManagedObjectContext * context = [[[NSApp delegate] clusterManager] managedObjectContext];
	
	//new cluster entry
	NSManagedObject * cluster = [NSEntityDescription insertNewObjectForEntityForName:@"Cluster" 
															  inManagedObjectContext:context ];
	[cluster setValue:[clusterName stringValue] forKey:@"name"];
	
	
	//new master for cluster
	NSManagedObject * master = [NSEntityDescription insertNewObjectForEntityForName:@"HyperTable" 
															 inManagedObjectContext:context ];
	NSMutableSet * members = [cluster mutableSetValueForKey:@"members"];
	
	//name
	[master setValue:@"Master" forKey:@"name"];
	[master setValue:@"Master" forKey:@"role"];
	[master setValue:@"" forKey:@"comment"];
	//status
	[master setValue:@"Pending..." forKey:@"status"];
	[master setValue:[NSNumber numberWithInt:0] forKey:@"statusInt"];		
	[master setValue:[NSNumber numberWithInt:0] forKey:@"health"];
	//network
	[master setValue:[masterAddress stringValue] forKey:@"ipAddress"];
	[master setValue:portNum forKey:@"sshPort"];
	//add to cluster
	[master setValue:cluster forKey:@"belongsTo"];
	[members addObject:master];
	[cluster setValue:master forKey:@"master"];
	
	//hadoop settings
	if ([[hadoopBroker stringValue] length] > 0) {
		//define new server as hadoop broker
		NSManagedObject * hadoop = [NSEntityDescription insertNewObjectForEntityForName:@"Hadoop" 
																 inManagedObjectContext:context ];
		//name
		[hadoop setValue:@"HDFS Broker" forKey:@"name"];
		[hadoop setValue:@"HDFS Broker" forKey:@"role"];
		[hadoop setValue:@"" forKey:@"comment"];
		//status
		[hadoop setValue:@"Pending..." forKey:@"status"];
		[hadoop setValue:[NSNumber numberWithInt:0] forKey:@"statusInt"];		
		[hadoop setValue:[NSNumber numberWithInt:0] forKey:@"health"];
		//network
		[hadoop setValue:[hadoopBroker stringValue] forKey:@"ipAddress"];
		[hadoop setValue:portNum forKey:@"sshPort"];
		//add to cluster
		[hadoop setValue:cluster forKey:@"belongsTo"];
		[members addObject:hadoop];
		[cluster setValue:hadoop forKey:@"hadoopThriftBroker"];
	}
	else {
		//set master as hadoop broker
		[cluster setValue:master forKey:@"hadoopThriftBroker"];
	}

	//hypertable settings
	if ([[hypertableBroker stringValue] length] > 0) {
		//define new server as hypertable broker
		NSManagedObject * hypertable = [NSEntityDescription insertNewObjectForEntityForName:@"HyperTable" 
																 inManagedObjectContext:context ];
		
		
		//name
		[hypertable setValue:@"Hypertable Broker" forKey:@"name"];
		[hypertable setValue:@"Hypertable" forKey:@"role"];
		[hypertable setValue:@"" forKey:@"comment"];
		//status
		[hypertable setValue:@"Pending..." forKey:@"status"];
		[hypertable setValue:[NSNumber numberWithInt:0] forKey:@"statusInt"];		
		[hypertable setValue:[NSNumber numberWithInt:0] forKey:@"health"];
		//network
		[hypertable setValue:[hypertableBroker stringValue] forKey:@"ipAddress"];
		[hypertable setValue:portNum forKey:@"sshPort"];
		//add to cluster
		[hypertable setValue:cluster forKey:@"belongsTo"];
		[members addObject:hypertable];
		[cluster setValue:hypertable forKey:@"hypertableThriftBroker"];
	}
	else {
		//set master as hypertable broker
		[cluster setValue:master forKey:@"hypertableThriftBroker"];
	}
	
	//username & password
	[cluster setValue:[userName stringValue] forKey:@"userName"];
	[cluster setValue:[password stringValue] forKey:@"password"];
	
	//commit
	NSError * error = nil;
	if (![context commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	[context release];
	NSLog(@"Cluster with master %s was saved.", [[masterAddress stringValue] UTF8String]);
	
	//close dialog
	[[[self view] window] orderOut:sender];
}

@end
