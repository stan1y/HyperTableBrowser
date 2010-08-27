//
//  Server.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Server.h"


@implementation Server

#pragma mark Initialization

- (void) dealloc
{
	if (sshClient) {
		[sshClient release];
	}
	[super dealloc];
}

+ (NSEntityDescription *) serverDescription
{
	return [NSEntityDescription entityForName:@"Server" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

#pragma mark Server Access and Info 

- (SSHClient *) remoteShell
{
	if (sshClient) {
		return sshClient;
	}
		
	NSString * ipAddress = [self valueForKey:@"ipAddress"];
	int sshPort = [[self valueForKey:@"sshPort"] intValue];
	NSString * sshUserName = [self valueForKey:@"sshUserName"];
	NSString * sshPrivateKeyPath = [self valueForKey:@"sshPrivateKeyPath"];
	
	NSLog(@"Connecting to remote shell at %s:%d...",
		  [ipAddress UTF8String], sshPort);
	sshClient = [[SSHClient alloc] initClientTo:ipAddress 
								   onPort:sshPort 
								   asUser:sshUserName 
								  withKey:sshPrivateKeyPath];
	
	int rc = [sshClient runCommand:@"lsb_release -a"];
	if (rc) {
		NSLog(@"Failed to open remote shell on server. Code %d", rc);
		NSLog(@"Error: %s", [[sshClient error] UTF8String]);
		[sshClient release];
		sshClient = nil;
	}
	else {
		NSLog(@"Connected to remote shell on server: %@.", self);
	}

	return sshClient;	
}

- (Service *) serviceWithName:(NSString *)name;
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Service serviceDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"runsOnServer = %@ && serviceName = %@", 
					 self, 
					 name] ];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get services on server %@.", [self valueForKey:@"name"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	if (![servicesArray count]) {
		return nil;
	}
	else if ([servicesArray count] > 1) {
		NSLog(@"Multiple (%d) services with name \"%@\" found on server \"%@\"",
			  [servicesArray count], name, [self valueForKey:@"name"]);
	}
	return [servicesArray objectAtIndex:0];
}

- (NSArray *)services
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[NSEntityDescription entityForName:@"Service" 
							 inManagedObjectContext:[self managedObjectContext]]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"runsOnServer = %@", self]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get services on server %@.", [self valueForKey:@"name"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	if (![servicesArray count]) {
		return nil;
	}

	return servicesArray;
}

@end
