//
//  GetStatusOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 17/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "GetStatusOperation.h"

@implementation GetStatusOperation

@synthesize sshClient;
@synthesize server;
@synthesize errorCode;
@synthesize errorMessage;

- (void) dealloc
{
	[sshClient release];
	[server release];
	[errorMessage release];
	[super dealloc];
}

+ getStatusFrom:(SSHClient *)client forServer:(NSManagedObject *)server
{
	GetStatusOperation * op = [[GetStatusOperation alloc] init];
	[op setSshClient:client];
	[op setServer:server];
	return op;
}

- (void)main
{
	[[sshClient sshLock] lock];
	
	//defaults
	[server setValue:[NSNumber numberWithBool:NO] forKey:@"hasDfsBroker"];
	[server setValue:[NSNumber numberWithBool:NO] forKey:@"hasMaster"];
	[server setValue:[NSNumber numberWithBool:NO] forKey:@"hasRangeServer"];
	[server setValue:[NSNumber numberWithBool:NO] forKey:@"hasHyperspace"];
	[server setValue:[NSNumber numberWithBool:NO] forKey:@"hasThriftBroker"];
	
	NSLog(@"Fetching server status from %s", [[sshClient targetIpAddress] UTF8String]);
	errorCode = 0;
	//check hypertable
	errorCode = [sshClient runCommand:@"stat /opt/hypertable/current"];
	if (errorCode) {
		NSLog(@"Failed to stat /opt/hypertable/current. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[server setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		return;
	}
	//get running services
	errorCode = [sshClient runCommand:@"ls -l /opt/hypertable/current/run/*.pid"];
	if (errorCode) {
		NSLog(@"Failed to list running services. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[server setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		return;
	}
	
	//parse running services
	[[sshClient output] enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop){
		if ([line rangeOfString:@"DfsBroker"].location != NSNotFound) {
			NSLog(@"Found DFS Broker.");
			[server setValue:[NSNumber numberWithBool:YES] forKey:@"hasDfsBroker"];
		}
		if ([line rangeOfString:@"Hyperspace"].location != NSNotFound) {
			NSLog(@"Found Hyperspace.");
			[server setValue:[NSNumber numberWithBool:YES] forKey:@"hasHyperspace"];
		}
		if ([line rangeOfString:@"Hypertable.Master"].location != NSNotFound) {
			NSLog(@"Found HyperTable.Master");
			[server setValue:[NSNumber numberWithBool:YES] forKey:@"hasMaster"];
		}
		if ([line rangeOfString:@"Hypertable.RangeServer"].location != NSNotFound) {
			NSLog(@"Found HyperTable.RangeServer");
			[server setValue:[NSNumber numberWithBool:YES] forKey:@"hasRangeServer"];
		}
		if ([line rangeOfString:@"ThriftBroker"].location != NSNotFound) {
			NSLog(@"Found ThriftBroker");
			[server setValue:[NSNumber numberWithBool:YES] forKey:@"hasThriftBroker"];
		}
		
	}];
	
	//get load
	errorCode = [sshClient runCommand:@"cat /proc/loadavg"];
	if (errorCode) {
		NSLog(@"Failed to get /proc/loadavg. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[server setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		return;
	}
	
	NSArray * parts = [[sshClient output] componentsSeparatedByString:@" "];
	float totalLoad = [[parts objectAtIndex:0] floatValue];
	totalLoad += [[parts objectAtIndex:1] floatValue];
	totalLoad += [[parts objectAtIndex:2] floatValue];
	totalLoad = totalLoad / 3;
	
	int healthPercent = (1 - totalLoad) * 100;
	int healthLevel = 0;
	
	if (healthPercent > 80)
		healthLevel = 3;
	else if (healthPercent > 50)
		healthLevel = 2;
	else if (healthPercent > 20)
		healthLevel = 1;
	
	[server setValue:[NSNumber numberWithInt:healthLevel] forKey:@"health"];
	[server setValue:[NSNumber numberWithInt:healthPercent] forKey:@"healthPercent"];
	NSLog(@"Server health: %d %%. Level: %d", healthPercent, healthLevel);
	
	//set status to 0 == Operational
	[server setValue:[NSNumber numberWithInt:0] forKey:@"status"];
	[[sshClient sshLock] unlock];
}


@end
