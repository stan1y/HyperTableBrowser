//
//  GetStatusOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 17/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "GetStatusOperation.h"
#import <KnownServices.h>

@implementation GetStatusOperation

@synthesize server;
@synthesize errorCode;
@synthesize errorMessage;

- (void) dealloc
{
	[server release];
	[errorMessage release];
	[super dealloc];
}

+ getStatusOfServer:(Server *)server;
{
	GetStatusOperation * op = [[GetStatusOperation alloc] init];
	[op setServer:server];
	return op;
}

- (void)main
{
	SSHClient * sshClient = [server remoteShell];
	if (!sshClient) {
		[self setErrorCode:255];
		[self setErrorMessage:@"Failed to establish ssh connection."];
		return;
	}
	[[sshClient sshLock] lock];
	
	NSLog(@"Fetching status from %@ [%@]", [sshClient targetIpAddress], [server class]);
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
	
	NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
	NSManagedObject * masterService;
	NSManagedObject * rangeService;
	NSManagedObject * hyperspaceService;
	NSManagedObject * dfsService;
	NSManagedObject * thriftService;
	//NSManagedObject * hdfsbrkService;
	
	//get available services
	errorCode = [sshClient runCommand:@"ls -l /opt/hypertable/current/bin"];
	if (errorCode) {
		NSLog(@"Failed to list available services. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[server setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		[context release];
		return;
	}
	
	//parse available services
	NSArray * lines = [[sshClient output] componentsSeparatedByString:@"\n"];
	for (int lineIndex = 0; lineIndex < [lines count]; lineIndex++) {
		NSString * line = [lines objectAtIndex:lineIndex];
		
		if ([line rangeOfString:@"ThriftBroker"].location != NSNotFound) {
			NSLog(@"Found Thrift Broker.");
			thriftService = [KnownServices newThriftService:context onServer:server];
		}
		if ([line rangeOfString:@"start-dfsbroker.sh"].location != NSNotFound) {
			NSLog(@"Found DFS Broker.");
			dfsService = [KnownServices newDfsBrokerService:context onServer:server withDfs:@"local"];
		}
		if ([line rangeOfString:@"start-hyperspace.sh"].location != NSNotFound) {
			NSLog(@"Found HyperSpace Service.");
			hyperspaceService = [KnownServices newHyperspaceService:context onServer:server];
		}
		if ([line rangeOfString:@"start-rangeserver.sh"].location != NSNotFound) {
			NSLog(@"Found Range Server.");
			rangeService = [KnownServices newRangerService:context onServer:server];
		}
		if ([line rangeOfString:@"start-master.sh"].location != NSNotFound) {
			NSLog(@"Found Master Service.");
			masterService = [KnownServices newMasterService:context onServer:server];
		}
	}
	
	//get running services
	errorCode = [sshClient runCommand:@"ls -l /opt/hypertable/current/run/*.pid"];
	if (errorCode) {
		NSLog(@"Failed to list running services. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[server setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		[context release];
		return;
	}
	
	//parse running services pids
	[[sshClient output] enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop){
		if ([line rangeOfString:@"DfsBroker"].location != NSNotFound) {
			errorCode = [sshClient runCommand:[dfsService valueForKey:@"getPid"]];
			if (errorCode == 0) {
				int pid = [[sshClient output] intValue];
				[dfsService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
				NSLog(@"DFS Broker is running with pid %d", pid);
			}
		}
		if ([line rangeOfString:@"Hyperspace"].location != NSNotFound) {
			errorCode = [sshClient runCommand:[hyperspaceService valueForKey:@"getPid"]];
			if (errorCode == 0) {
				int pid = [[sshClient output] intValue];
				[hyperspaceService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
				NSLog(@"Hyperspace is running with pid %d", pid);
			}
		}
		if ([line rangeOfString:@"Hypertable.Master"].location != NSNotFound) {
			errorCode = [sshClient runCommand:[masterService valueForKey:@"getPid"]];
			if (errorCode == 0) {
				int pid = [[sshClient output] intValue];
				[masterService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
				NSLog(@"HyperTable.Master is running with pid %d", pid);
			}
		}
		if ([line rangeOfString:@"Hypertable.RangeServer"].location != NSNotFound) {
			errorCode = [sshClient runCommand:[rangeService valueForKey:@"getPid"]];
			if (errorCode == 0) {
				int pid = [[sshClient output] intValue];
				[rangeService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
				NSLog(@"HyperTable.RangeServer is running with pid %d", pid);
			}
		}
		if ([line rangeOfString:@"ThriftBroker"].location != NSNotFound) {
			errorCode = [sshClient runCommand:[thriftService valueForKey:@"getPid"]];
			if (errorCode == 0) {
				int pid = [[sshClient output] intValue];
				[thriftService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
				NSLog(@"ThriftBroker is running with pid %d", pid);
			}
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
	[[NSApp delegate] saveAction:nil];
	
	[[sshClient sshLock] unlock];
}


@end
