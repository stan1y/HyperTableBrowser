//
//  NewClusterController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "NewClusterController.h"
#import <HyperTable.h>

@implementation NewClusterController

@synthesize errorMessage;
@synthesize clusterName;
@synthesize masterAddress;
@synthesize sshPort;
@synthesize userName;
@synthesize privateKeyPath;
@synthesize hadoopBroker;
@synthesize hypertableBroker;

- (void) dealloc
{
	[errorMessage release];
	[clusterName release];
	[masterAddress release];
	[sshPort release];
	[userName release];
	[privateKeyPath release];
	[hadoopBroker release];
	[hypertableBroker release];
	
	[super dealloc];
}

- (IBAction) cancel:(id)sender
{
	//close dialog
	[[[self view] window] orderOut:sender];
	
	//quit app if no clusters
	if ( ![[Cluster clusters] count] ) {
		NSLog(@"Quiting application, new cluster dialog was canceled with no defined clusters");
		[NSApp terminate:nil];
	}
}

- (IBAction) saveCluster:(id)sender
{
	if ( ![[clusterName stringValue] length] ) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify Cluster name"];
		return;
	}
	if ( ![[masterAddress stringValue] length] ) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify Master hostname"];
		return;
	}
	if ( ![[userName stringValue] length] ) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify Username for SSH"];
		return;
	}
	
	[errorMessage setHidden:YES];
	
	[[[NSApp delegate] clustersBrowser] indicateBusy];
	[[[NSApp delegate] clustersBrowser] setMessage:
		[NSString stringWithFormat:@"Saveing cluster %@", [clusterName stringValue]]];

	NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
	
	//new cluster entry
	Cluster * cluster = [[Cluster alloc] initWithEntity:[Cluster clusterDescription]
						 insertIntoManagedObjectContext:context];
															  
	[cluster setValue:[clusterName stringValue] forKey:@"name"];
	
	
	//new master for cluster
	HyperTable * master = [[HyperTable alloc] initWithEntity:[HyperTable hypertableDescription]
							  insertIntoManagedObjectContext:context];
	NSMutableSet * members = [cluster mutableSetValueForKey:@"members"];
	
	//name
	[master setValue:@"Master" forKey:@"name"];
	[master setValue:@"" forKey:@"comment"];
	//status
	[master setValue:[NSNumber numberWithInt:0] forKey:@"status"];		
	[master setValue:[NSNumber numberWithInt:0] forKey:@"health"];
	//network
	[master setValue:[masterAddress stringValue] forKey:@"ipAddress"];
	[master setValue:[userName stringValue] forKey:@"sshUserName"];
	if ([[privateKeyPath stringValue] length]) {
		[master setValue:[privateKeyPath stringValue] forKey:@"sshPrivateKeyPath"];
	}
	if ([[sshPort stringValue] length]) {
		[master setValue:[NSNumber numberWithInt:[sshPort intValue]] forKey:@"sshPort"];
	}
	//add to cluster
	[master setValue:cluster forKey:@"belongsTo"];
	[members addObject:master];
	[cluster setValue:master forKey:@"master"];
	
	//hadoop settings
	Server * hadoop = nil;
	if ([[hadoopBroker stringValue] length] > 0) {
		//define new server as hadoop broker
		hadoop = [[Server alloc] initWithEntity:[Server serverDescription]
				 insertIntoManagedObjectContext:context];
		//name
		[hadoop setValue:@"HDFS Broker" forKey:@"name"];
		[hadoop setValue:@"" forKey:@"comment"];
		//status
		[hadoop setValue:[NSNumber numberWithInt:0] forKey:@"status"];		
		[hadoop setValue:[NSNumber numberWithInt:0] forKey:@"health"];
		//network
		[hadoop setValue:[hadoopBroker stringValue] forKey:@"ipAddress"];
		[hadoop setValue:[userName stringValue] forKey:@"sshUserName"];
		if ([[privateKeyPath stringValue] length]) {
			[hadoop setValue:[privateKeyPath stringValue] forKey:@"sshPrivateKeyPath"];
		}
		if ([[sshPort stringValue] length]) {
			[hadoop setValue:[NSNumber numberWithInt:[sshPort intValue]] forKey:@"sshPort"];
		}
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
	HyperTable * hypertable = nil;
	if ([[hypertableBroker stringValue] length] > 0) {
		//define new server as hypertable broker
		hypertable = [[HyperTable alloc] initWithEntity:[HyperTable hypertableDescription]
						 insertIntoManagedObjectContext:context];
		
		//name
		[hypertable setValue:@"Hypertable Broker" forKey:@"name"];
		[hypertable setValue:@"" forKey:@"comment"];
		//status
		[hypertable setValue:[NSNumber numberWithInt:0] forKey:@"status"];		
		[hypertable setValue:[NSNumber numberWithInt:0] forKey:@"health"];
		//network
		[hypertable setValue:[hypertableBroker stringValue] forKey:@"ipAddress"];
		[hypertable setValue:[userName stringValue] forKey:@"sshUserName"];
		if ([[privateKeyPath stringValue] length]) {
			[hypertable setValue:[privateKeyPath stringValue] forKey:@"sshPrivateKeyPath"];
		}
		if ([[sshPort stringValue] length]) {
			[hypertable setValue:[NSNumber numberWithInt:[sshPort intValue]] forKey:@"sshPort"];
		}
		//add to cluster
		[hypertable setValue:cluster forKey:@"belongsTo"];
		[members addObject:hypertable];
		[cluster setValue:hypertable forKey:@"hypertableThriftBroker"];
	}
	else {
		//set master as hypertable broker
		[cluster setValue:master forKey:@"hypertableThriftBroker"];
	}
	
	//commit
	NSError * error = nil;
	if (![context commitEditing]) {
		[[[NSApp delegate] clustersBrowser] indicateDone];
		[[[NSApp delegate] clustersBrowser] setMessage:
			[NSString stringWithFormat:@"%@:%s unable to commit editing before saving", [self class], _cmd]];
    }
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	[context release];

	[[[NSApp delegate] clustersBrowser] setMessage:
	 [NSString stringWithFormat:@"Cluster with master %s was saved.", [masterAddress stringValue]]];
	
	//close dialog
	[[[self view] window] orderOut:sender];
	
	//get status for master
	GetStatusOperation * masterStatus = [GetStatusOperation getStatusOfServer:master ];
	[masterStatus setCompletionBlock: ^ {
		if ([masterStatus errorCode]) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:[masterStatus errorMessage] forKey:NSLocalizedDescriptionKey];
			[dict setValue:[masterStatus errorMessage] forKey:NSLocalizedFailureReasonErrorKey];
			NSError *error = [NSError errorWithDomain:@"" code:[masterStatus errorCode] userInfo:dict];
			[NSApp presentError:error];			
		}
		[[[NSApp delegate] clustersBrowser] indicateDone];
	}];
	[[[NSApp delegate] operations] addOperation:masterStatus];
	[masterStatus release];
	
	//get status for hypertable
	if (hypertable) {
		GetStatusOperation * hypertableStatus = [GetStatusOperation getStatusOfServer:hypertable ];
		[hypertableStatus setCompletionBlock: ^ {
			[[[NSApp delegate] clustersBrowser] indicateDone];
			if ([hypertableStatus errorCode]) {
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setValue:[hypertableStatus errorMessage] forKey:NSLocalizedDescriptionKey];
				[dict setValue:[hypertableStatus errorMessage] forKey:NSLocalizedFailureReasonErrorKey];
				NSError *error = [NSError errorWithDomain:@"" code:[hypertableStatus errorCode] userInfo:dict];
				[NSApp presentError:error];			
			}
		}];
		
		[[[NSApp delegate] operations] addOperation:hypertableStatus];
		[hypertableStatus release];
	}
	//get status for hadoop
	if (hadoop) {
		GetStatusOperation * hadoopStatus = [GetStatusOperation getStatusOfServer:hadoop ];
		[hadoopStatus setCompletionBlock: ^ {
			if ([hadoopStatus errorCode]) {
				[[[NSApp delegate] clustersBrowser] indicateDone];
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setValue:[hadoopStatus errorMessage] forKey:NSLocalizedDescriptionKey];
				[dict setValue:[hadoopStatus errorMessage] forKey:NSLocalizedFailureReasonErrorKey];
				NSError *error = [NSError errorWithDomain:@"" code:[hadoopStatus errorCode] userInfo:dict];
				[NSApp presentError:error];			
			}
		}];
		[[[NSApp delegate] operations] addOperation:hadoopStatus];
		[hadoopStatus release];
	}
}

@end
