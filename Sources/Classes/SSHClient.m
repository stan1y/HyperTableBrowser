//
//  SSHClient.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 15/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "SSHClient.h"

@implementation SSHClient

@synthesize sshLock;
@synthesize targetIpAddress;

- (void) dealloc
{
	NSLog(@"Deallocating ssh client wrapper.");
	
	[sshLock release];
	[targetIpAddress release];
	[arguments release];
	[stdoutPipe release];
	[stderrPipe release];
	
	if (sshOutput) {
		[sshOutput release];
	}
	
	if (sshError) {
		[sshError release];
	}
	
	if (ssh) {
		[ssh release];
	}
	
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
	
	if (self = [super init]) {
		
		//setup ssh arguments
		arguments = [[NSMutableArray alloc] init];
		
		//private key path
		[arguments addObject:@"-i"];
		[arguments addObject:[privateKeyPath stringByExpandingTildeInPath]];
		
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
		
		//save target address
		targetIpAddress = address;
		[targetIpAddress retain];
		
		//create lock
		sshLock = [[NSLock alloc] init];
		ssh = nil;
	}
	return self;
}

- (id) initClientTo:(NSString *)address 
			 onPort:(int)port 
			 asUser:(NSString *)user
{
	return [self initClientTo:address 
					   onPort:port 
					   asUser:user 
					  withKey:[[NSString stringWithString:@"~/.ssh/id_dsa"] stringByExpandingTildeInPath]];
}

- (int)lastExitCode
{
	if (ssh) {
		return [ssh terminationStatus];
	}
	NSLog(@"/usr/bin/ssh was not executed. No terminationStatus available.");
	return 0;
}

- (int)runCommand:(NSString*)command
{
	NSLog(@"SSH running command \"%s\"", [command UTF8String]);
	if (ssh) {
		NSLog(@"Deallocating ssh task.");
		[ssh release];
		ssh = nil;
	}
	ssh = [[NSTask alloc] init];
	//path to actual ssh
	[ssh setLaunchPath:@"/usr/bin/ssh"];
	
	//set arguments
	NSMutableArray * args = [NSMutableArray arrayWithArray:arguments];
	[args addObject:command];
	[ssh setArguments:args];
	
	if (stdoutPipe) {
		[stdoutPipe release];
		stdoutPipe = nil;
	}
	stdoutPipe = [[NSPipe alloc] init];
	if (stderrPipe) {
		[stderrPipe release];
		stderrPipe = nil;
	}
	stderrPipe = [[NSPipe alloc] init];
	if (sshOutput) {
		[sshOutput release];
		sshOutput = nil;
	}
	if (sshError) {
		[sshError release];
		sshError = nil;
	}
	
	[ssh setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	[ssh setStandardError:stderrPipe];
	[ssh setStandardOutput:stdoutPipe];
	
	int rc = 0;
	[ssh launch];
	
	
	sleep(10);
	if ([ssh isRunning]) {
		//timeout need to set error message manually, since
		//we're gonna kill child ssh
		[ssh terminate];
		sshError = @"ssh command execution timed out.";
		return 255;
	}
	
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
	
	//we need to keen ssh for pipes access
	//until next command
	return rc;
}


- (NSString *) output
{
	if (!sshOutput) {
		NSLog(@"Reading ssh output");
		NSData *theOutput = [[stdoutPipe fileHandleForReading] readDataToEndOfFile];
		sshOutput = [[NSString alloc] initWithData:theOutput encoding:NSUTF8StringEncoding];
		[stdoutPipe release];
		stdoutPipe = nil;
	}
	return sshOutput;
}

- (NSString *) error
{
	if (!sshError) {
		NSLog(@"Reading ssh error");
		NSData *theOutput = [[stderrPipe fileHandleForReading] readDataToEndOfFile];
		sshError = [[NSString alloc] initWithData:theOutput encoding:NSUTF8StringEncoding];
		[stderrPipe release];
		stderrPipe = nil;
	}
	return sshError;
}

@end