//
//  SSHClient.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 15/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "SSHClient.h"

@implementation SSHClient


- (void) dealloc
{
	[self close];
	
	[arguments release];
	[stdoutPipe release];
	[stderrPipe release];
	
	[super dealloc];
}

- (id) initClientTo:(NSString *)address 
			 onPort:(int)port 
			 asUser:(NSString *)user 
			withKey:(NSString *)privateKeyPath
{
	/*
	 self.ssh_cmd = ['ssh',
	 '-i', self.privkey_path,
	 '-p 22',
	 '-oStrictHostKeyChecking=no',
	 '-oBatchMode=yes', 
	 '-oLogLevel=ERROR',
	 '-oServerAliveInterval=15',
	 '-oPreferredAuthentications=publickey',
	 '-oUserKnownHostsFile=/dev/null',
	 host_login]
	 */
	
	[super init];
	
	//setup ssh arguments
	arguments = [NSMutableArray array];	
	//private key path
	[arguments addObject:@"-i"];
	[arguments addObject:privateKeyPath];
	
	//port
	[arguments addObject:@"-p"];
	[arguments addObject:[NSString stringWithFormat:@"%d", port]];
	
	//options
	[arguments addObject:@"-oStrictHostKeyChecking=no"];
	[arguments addObject:@"-oBatchMode=yes"];
	[arguments addObject:@"-oLogLevel=ERROR"];
	[arguments addObject:@"-oServerAliveInterval=15"];
	[arguments addObject:@"-oPreferredAuthentications=publickey"];
	[arguments addObject:@"-oUserKnownHostsFile=/dev/null"];
	
	//login & host
	NSString * hostArgument = [NSString stringWithFormat:@"%s@%s", 
							   [user UTF8String],
							   [address UTF8String]];
	[arguments addObject:hostArgument];
	
	return self;
}

- (id) initClientTo:(NSString *)address 
			 onPort:(int)port 
			 asUser:(NSString *)user
{
	return [self initClientTo:address onPort:port asUser:user withKey:@"~/.ssh/id_dsa"];
}

- (void) close
{
	if (ssh) {
		if([ssh isRunning]) {
			[ssh terminate];
		}
		[ssh release];
		ssh = nil;
	}
}

- (int)runCommand:(NSString*)command
{
	ssh = [[NSTask alloc] init];
	//path to actual ssh
	[ssh setLaunchPath:@"/usr/bin/ssh"];
	
	//set arguments
	NSMutableArray * args = [NSMutableArray arrayWithArray:arguments];
	[args addObject:command];
	[ssh setArguments:args];
	
	NSLog(@"Spawing ssh child with arguments:");
	for (int i=0; i< [args count]; i++) {
		NSLog(@" %s", [[args objectAtIndex:i] UTF8String]);
	}
	
	if (stdoutPipe) {
		[stdoutPipe release];
	}
	if (stderrPipe) {
		[stderrPipe release];
	}
	
	stdoutPipe = [[NSPipe alloc] init];
	stderrPipe = [[NSPipe alloc] init];
	
	[ssh setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	[ssh setStandardError:stderrPipe];
	[ssh setStandardOutput:stdoutPipe];
	
	int rc = 0;
	[ssh launch];
	[ssh waitUntilExit];
	
	if ([ssh terminationReason] != NSTaskTerminationReasonExit) {
		NSLog(@"Error: ssh child failed with uncaught signal");
		rc = 255;
	}
	else {
		rc = [ssh terminationStatus];
		if (rc) {
			NSLog(@"Error: ssh child process failed with code %d", rc);
		}
	}
	
	[args release];
	return rc;
}


- (NSString *) output
{
	NSData *theOutput = [[stdoutPipe fileHandleForReading] readDataToEndOfFile];
	return [[NSString alloc] initWithData:theOutput encoding:NSUTF8StringEncoding];
}

- (NSString *) error
{
	NSData *theOutput = [[stderrPipe fileHandleForReading] readDataToEndOfFile];
	return [[NSString alloc] initWithData:theOutput encoding:NSUTF8StringEncoding];
}


@end
