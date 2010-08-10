//
//  NewClusterController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "NewClusterController.h"

@implementation NewClusterController

@synthesize clusterName;
@synthesize masterAddress;
@synthesize userName;
@synthesize password;
@synthesize hadoopBroker;
@synthesize hypertableBroker;

- (void) dealloc
{
	[clusterName release];
	[masterAddress release];
	[userName release];
	[password release];
	[hadoopBroker release];
	[hypertableBroker release];
}

- (IBAction) saveCluster:(id)sender
{
	//new master for cluster
	NSManagedObject * master = [NSEntityDescription insertNewObjectForEntityForName:@"Server" 
															  inManagedObjectContext:[[[NSApp delegate] clusterManager] managedObjectContext] ];
	
	
	[master setValue:@"Master" forKey:@"name"];
	[master setValue:[masterAddress stringValue] forKey:@"ipAddress"];
	[[[[NSApp delegate] clusterManager] managedObjectContext] insertObject:master];

	//new cluster entry
	NSManagedObject * cluster = [NSEntityDescription insertNewObjectForEntityForName:@"Cluster" 
															  inManagedObjectContext:[[[NSApp delegate] clusterManager] managedObjectContext] ];
	[cluster setValue:[clusterName stringValue] forKey:@"name"];
	[cluster setValue:master forKey:@"master"];
	
	//hadoop settings
	if ([[hadoopBroker stringValue] length] > 0) {
		//define new server as hadoop broker
		NSManagedObject * hadoop = [NSEntityDescription insertNewObjectForEntityForName:@"Server" 
																 inManagedObjectContext:[[[NSApp delegate] clusterManager] managedObjectContext] ];
		
		
		[hadoop setValue:@"Hadoop Broker" forKey:@"name"];
		[hadoop setValue:[hadoopBroker stringValue] forKey:@"ipAddress"];
		[[[[NSApp delegate] clusterManager] managedObjectContext] insertObject:hadoop];
		[cluster setValue:hadoop forKey:@"hadoopThriftBroker"];
	}
	else {
		//set master as hadoop broker
		[cluster setValue:master forKey:@"hadoopThriftBroker"];
	}

	//hypertable settings
	if ([[hypertableBroker stringValue] length] > 0) {
		//define new server as hypertable broker
		NSManagedObject * hypertable = [NSEntityDescription insertNewObjectForEntityForName:@"Server" 
																 inManagedObjectContext:[[[NSApp delegate] clusterManager] managedObjectContext] ];
		
		
		[hypertable setValue:@"Hypertable Broker" forKey:@"name"];
		[hypertable setValue:[hypertableBroker stringValue] forKey:@"ipAddress"];
		[[[[NSApp delegate] clusterManager] managedObjectContext] insertObject:hypertable];
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
	[[NSApp delegate] saveAction:sender];
}

@end
