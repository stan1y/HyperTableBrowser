//
//  NewServerController.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "NewClusterController.h"
#import "GetStatusOperation.h"

@implementation NewServerController

@synthesize errorMessage;
@synthesize name;
@synthesize ipAddress;
@synthesize sshPort;
@synthesize userName;
@synthesize privateKeyPath;
@synthesize dialogTitle;
@synthesize cluster;

- (void) dealloc
{
	[errorMessage release];
	[name release];
	[ipAddress release];
	[sshPort release];
	[userName release];
	[privateKeyPath release];
	[dialogTitle release];
	if (cluster) {
		[cluster release];
	}
	
	[super dealloc];
}

- (void) modeAddToCluser:(Cluster *)toCluster
{
	if (toCluster) {
		[dialogTitle setStringValue:[NSString stringWithFormat:@"Add Server to %@",
									 [toCluster valueForKey:@"name"]]];
		 [self setCluster:toCluster];
	}
}

- (void) modeCreateNewCluser
{
	[dialogTitle setStringValue:[NSString stringWithFormat:@"Define New Cluster"]];
	[self setCluster:nil];
}

- (IBAction) cancel:(id)sender
{
	NSLog(@"New server dialog canceled");
	//close dialog
	[NSApp endSheet:[[self view] window]];
	[[[self view] window] orderOut:sender];
	
	//quit app if no clusters
	if ( ![[Cluster clusters] count] ) {
		NSLog(@"Quiting application, New Server Dialog was canceled with no defined clusters");
		[NSApp terminate:nil];
	}
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
	
	[[[NSApp delegate] clustersBrowser] indicateBusy];
	[[[NSApp delegate] clustersBrowser] setMessage:
	 [NSString stringWithFormat:@"Saving %@", [name stringValue]]];
	
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
		
		[[[NSApp delegate] clustersBrowser] indicateDone];
		[[[NSApp delegate] clustersBrowser] setMessage:
		 [NSString stringWithFormat:@"%@ was saved.", [name stringValue]]];
		
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
	
	if ( !cluster ) {
		//define new cluster
		[self setCluster:[[Cluster alloc] initWithEntity:[Cluster clusterDescription]
						 insertIntoManagedObjectContext:context]];
		//set name to cluster's name, change name of server to master[AT]cluster
		[cluster setValue:[name stringValue] forKey:@"name"];
		[newServer setValue:[NSString stringWithFormat:@"master@%@", [name stringValue]] forKey:@"name"];
		//set new server as master
		[cluster setValue:newServer forKey:@"master"];
	}
	
	//add to cluster
	[newServer setValue:cluster forKey:@"belongsTo"];
	[[cluster mutableSetValueForKey:@"members"] addObject:newServer];
	
	//commit
	NSError * error = nil;
	if (![context commitEditing]) {
		[[[NSApp delegate] clustersBrowser] indicateDone];
		[[[NSApp delegate] clustersBrowser] setMessage:
		 [NSString stringWithFormat:@"%@:%@ unable to commit editing before saving", [self class], _cmd]];
    }
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	[context release];
	
	//close dialog
	[[[self view] window] orderOut:sender];
}

@end
