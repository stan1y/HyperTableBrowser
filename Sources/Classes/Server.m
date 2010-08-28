//
//  Server.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Server.h"


@implementation Server

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
		//failed to open ssh, present error
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:[NSString stringWithFormat:@"Failed to open ssh connection to server %@. Code %d, Error: %@.", [self valueForKey:@"name"], rc, [sshClient error]] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:@"ClustersBrowser" code:1 userInfo:dict];
		NSLog(@"Failed to open remote shell on server. Code %d, Error: %@", rc, [sshClient error]);
		[NSApp presentError:error];
		
		[sshClient release];
		sshClient = nil;
	}
	else {
		NSLog(@"Connected to remote shell on server: %@.", self);
	}

	return sshClient;	
}

@end
