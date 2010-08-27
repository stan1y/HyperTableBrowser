//
//  NewServerController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "NewServerController.h"
#import "HyperTableOperation.h"
#import "ClustersBrowser.h"

@implementation NewServerController

@synthesize errorMessage;
@synthesize name;
@synthesize ipAddress;
@synthesize sshPort;
@synthesize userName;
@synthesize privateKeyPath;
@synthesize dialogTitle;

- (void) dealloc
{
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
	//quit app if no clusters
	if ( ![[Cluster clusters] count] ) {
		NSLog(@"Quiting application, New Server Dialog was canceled with no defined clusters");
		[NSApp terminate:nil];
	}
	
	[self hideModalForUsedWindow];
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
	HyperTable * newServer = [[HyperTable alloc] initWithEntity:[HyperTable hypertableDescription]
								 insertIntoManagedObjectContext:context];
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
	HyperTableStatusOperation * newServerStatus = [HyperTableStatusOperation getStatusOfHyperTable:newServer ];
	[newServerStatus setCompletionBlock: ^ {
		
		if ([newServerStatus errorCode]) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:[newServerStatus errorMessage] forKey:NSLocalizedDescriptionKey];
			[dict setValue:[newServerStatus errorMessage] forKey:NSLocalizedFailureReasonErrorKey];
			NSError *error = [NSError errorWithDomain:@"" code:[newServerStatus errorCode] userInfo:dict];
			[NSApp presentError:error];			
		}
	}];
	[[[NSApp delegate] operations] addOperation:newServerStatus];
	[newServerStatus release];
	
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
		//FIXME: Show error dialog
		//[NSString stringWithFormat:@"%@:%@ unable to commit editing before saving", [self class], _cmd]
    }
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	[context release];
	
	//close dialog
	[NSApp endSheet:[[self view] window]];
	[[[self view] window] orderOut:sender];
}

@end
