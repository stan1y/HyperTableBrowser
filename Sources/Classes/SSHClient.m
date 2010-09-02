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
	
	if (output) {
		[output release];
	}
	
	if (err) {
		[err release];
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
		err = nil;
		output = nil;
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
	if (output) {
		[output release];
		output = nil;
	}
	
	[ssh setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	[ssh setStandardError:stderrPipe];
	[ssh setStandardOutput:stdoutPipe];
	
	int rc = 0;
	[ssh launch];
	int totalSlept = 0;
	while (YES) {
		if (totalSlept >= 15) {
			[ssh terminate];
			[self setError:@"ssh command execution timed out."];
			return 255;
		}
		
		sleep(1);
		if ( ![ssh isRunning] ) {
			break;
		}
		totalSlept++;
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

- (void)setError:(NSString *)err_
{
	[err_ retain];
	if (err) {
		[err release];
	}
	err = err_;
}

- (void)setOutput:(NSString *)output_
{
	[output_ retain];
	if (output) {
		[output release];
	}
	output = output_;
}

- (NSString *) output
{
	if (!output) {
		NSLog(@"Reading ssh output");
		NSData *output_ = [[stdoutPipe fileHandleForReading] readDataToEndOfFile];
		[self setOutput:[[NSString alloc] initWithData:output_ encoding:NSUTF8StringEncoding]];
		[stdoutPipe release];
		stdoutPipe = nil;
	}
	return output;
}

- (NSString *) error
{
	if (!err) {
		NSLog(@"Reading ssh error");
		NSData *err_ = [[stderrPipe fileHandleForReading] readDataToEndOfFile];
		[self setError:[[NSString alloc] initWithData:err_ encoding:NSUTF8StringEncoding]];
		[stderrPipe release];
		stderrPipe = nil;
	}
	return err;
}

@end