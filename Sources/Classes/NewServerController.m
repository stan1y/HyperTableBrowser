//
//  NewServerController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "NewServerController.h"
#import "HyperTableOperation.h"
#import "ClustersBrowser.h"
#import "Activities.h"

@implementation NewServerController

@synthesize errorMessage;
@synthesize name;
@synthesize ipAddress;
@synthesize sshPort;
@synthesize userName;
@synthesize privateKeyPath;
@synthesize dialogTitle;
@synthesize typeSelector;

- (void) dealloc
{
	[typeSelector release];
	[errorMessage release];
	[name release];
	[ipAddress release];
	[sshPort release];
	[userName release];
	[privateKeyPath release];
	[dialogTitle release];
	
	[super dealloc];
}

- (void) setCreateNewCluster:(BOOL)flag
{
	createNewCluster = flag;
	if (createNewCluster) {
		[dialogTitle setStringValue:[NSString stringWithFormat:@"Define New Cluster"]];
	}
	else {
		[dialogTitle setStringValue:[NSString stringWithFormat:@"Add Server to %@",
									 [[[ClustersBrowser sharedInstance] selectedCluster] valueForKey:@"name"]]];
	}

}

- (IBAction) cancel:(id)sender
{
	[self hideModalForWindow:[[ClustersBrowser sharedInstance] window]];
}

- (IBAction) saveServer:(id)sender
{
	if ( ![[name stringValue] length] ) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify name"];
		return;
	}
	if ( ![[ipAddress stringValue] length] ) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify hostname or ip address"];
		return;
	}
	if ( ![[userName stringValue] length] ) {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Please specify username for ssh"];
		return;
	}
	
	[errorMessage setHidden:YES];	
	NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
	
	//define new server for cluser
	Server<ClusterMember> * newServer = nil;
	if ([[[typeSelector selectedItem] title] isEqual:@"HyperTable"]) {
		newServer = [[HyperTable alloc] initWithEntity:[HyperTable hypertableDescription]
						insertIntoManagedObjectContext:context];
	}
	else if ([[[typeSelector selectedItem] title] isEqual:@"HBase"]) {
		newServer = [[Hadoop alloc] initWithEntity:[Hadoop hadoopDescription]
						insertIntoManagedObjectContext:context];
	}
	else {
		[errorMessage setHidden:NO];
		[errorMessage setStringValue:@"Unknown type specified"];
		return;
	}

	
	[newServer setValue:[name stringValue] forKey:@"name"];
	[newServer setValue:@"" forKey:@"comment"];
	[newServer setValue:[NSNumber numberWithInt:0] forKey:@"status"];		
	[newServer setValue:[NSNumber numberWithInt:0] forKey:@"health"];
	[newServer setValue:[ipAddress stringValue] forKey:@"ipAddress"];
	[newServer setValue:[userName stringValue] forKey:@"sshUserName"];
	if ([[privateKeyPath stringValue] length]) {
		[newServer setValue:[privateKeyPath stringValue] forKey:@"sshPrivateKeyPath"];
	}
	if ([[sshPort stringValue] length]) {
		[newServer setValue:[NSNumber numberWithInt:[sshPort intValue]] forKey:@"sshPort"];
	}
	
	//get status of newServer
	[newServer updateStatusWithCompletionBlock:^(BOOL success) {
		if ( !success ) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:@"Failed to update status of a new server." forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:@"" code:5 userInfo:dict];
			[NSApp presentError:error];			
		}
		else {
			//status now is error
			[[ClustersBrowser sharedInstance] refreshMembersList];
		}

	}];
	
	Cluster * cluster = nil;
	
	if ( createNewCluster ) {
		//define new cluster
		cluster = [[Cluster alloc] initWithEntity:[Cluster clusterDescription]
						 insertIntoManagedObjectContext:context];
		//set name to cluster's name, change name of server to master[AT]cluster
		[cluster setValue:[name stringValue] forKey:@"name"];
		[newServer setValue:[NSString stringWithFormat:@"master@%@", [name stringValue]] forKey:@"name"];
		//set new server as master
		[cluster setValue:newServer forKey:@"master"];
	}
	else {
		cluster = [[ClustersBrowser sharedInstance] selectedCluster];
	}
	
	//add to cluster
	[newServer setValue:cluster forKey:@"belongsTo"];
	[[cluster mutableSetValueForKey:@"members"] addObject:newServer];
	
	//commit
	NSError * error = nil;
	if (![context commitEditing]) 
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:[NSString stringWithFormat:@"%@:%@ unable to commit editing before saving", [self class], _cmd] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:@"" code:5 userInfo:dict];
		[NSApp presentError:error];			
    }
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	
	//close dialog
	[self hideModalForWindow:[[ClustersBrowser sharedInstance] window]];
	
	if ( createNewCluster ) {
		//select newly defined cluster
		[[ClustersBrowser sharedInstance] refreshClustersList];
		[[[ClustersBrowser sharedInstance] clustersSelector] selectItemWithTitle:[cluster valueForKey:@"name"]];
	}
	else {
		//update memebers of current cluster
		[[ClustersBrowser sharedInstance] refreshMembersList];
	}

}

@end
