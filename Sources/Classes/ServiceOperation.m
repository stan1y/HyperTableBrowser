//
//  ServiceOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 24/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "ServiceOperation.h"
#import "SSHClient.h"

@implementation ServiceOperation

@synthesize service;
@synthesize cmd;
@synthesize cmdOutput;
@synthesize errorCode;
@synthesize flag;

- (void) dealloc
{
	[cmd release];
	[cmdOutput release];
	[super dealloc];
}

+ (ServiceOperation *) startService:(id)service
{
	ServiceOperation * op = [[ServiceOperation alloc] init];
	[op setService:service];
	[op setFlag:SERVICE_START];
	return op;
}

+ (ServiceOperation *) stopService:(id)service
{
	ServiceOperation * op = [[ServiceOperation alloc] init];
	[op setService:service];
	[op setFlag:SERVICE_STOP];
	return op;
}

- (void) executeCmd:(NSString *)cmd
{
	errorCode = 0;
	
	id server = [service valueForKey:@"runsOnServer"];
	SSHClient * ssh = [server remoteShell];
	if (!ssh) {
		NSLog(@"Failed to get remote shell to server %@", [server valueForKey:@"serverName"]);
		return NO;
	}
	
	[[ssh sshLock] lock];
	errorCode = [ssh runCommand:cmd];
	if (errorCode) {
		NSLog(@"Service command failed. Code: %d, %@", 
			  errorCode,
			  [ssh error]);
	}
	else {
		[self setCmdOutput:[ssh output]];
		NSLog(@"Service command executed sucessfuly.");
	}

	[[ssh sshLock] unlock];
}

- (void) main
{
	if (flag == SERVICE_START) {
		[self executeCmd:[service valueForKey:@"startService"]];
		if (errorCode) return;
		[self executeCmd:[NSString stringWithFormat:@"cat %@", [service valueForKey:@"getPid"]]];
		if (errorCode) {
			NSLog(@"Service is not runing after attempt to start");
			//mark as stopped
			[service setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
			return;
		}
		//mark as running with pid
		int pid = [[self cmdOutput] intValue];
		[service setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
		NSLog(@"Service started with pid %d", pid);
	}
	else if (flag == SERVICE_STOP){
		[self executeCmd:[service valueForKey:@"stopService"]];
		if (errorCode) return;
		else {
			//remove pid file
			[self executeCmd:[NSString stringWithFormat:@"rm -f %@", [service valueForKey:@"getPid"]] ];
			if (errorCode) {
				NSLog(@"Failed to remove pid file of service.");
				return;
			}
			//mark as stopped running
			[service setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
			NSLog(@"Service stopped.");
		}
	}
	//commit changes
	[[NSApp delegate] saveAction:nil];
}

@end
