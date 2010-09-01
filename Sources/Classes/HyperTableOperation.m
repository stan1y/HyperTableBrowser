//
//  HyperTableOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 17/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "HyperTableOperation.h"
#import "Service.h"

@implementation HyperTableStatusOperation

@synthesize hypertable;
@synthesize errorCode;
@synthesize errorMessage;

- (void) dealloc
{
	[hypertable release];
	[errorMessage release];
	[super dealloc];
}

+ getStatusOfHyperTable:(HyperTable *)hypertable;
{
	HyperTableStatusOperation * op = [[HyperTableStatusOperation alloc] init];
	[op setHypertable:hypertable];
	return op;
}

- (void)main
{
	//set status to pending
	[hypertable setValue:[NSNumber numberWithInt:2] forKey:@"status"];
	
	//access over ssh
	SSHClient * sshClient = [hypertable remoteShell];
	if (!sshClient) {
		//set status to error
		[hypertable setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		return;
	}
	[[sshClient sshLock] lock];
	
	NSLog(@"Fetching status from %@ [%@]", [sshClient targetIpAddress], [hypertable class]);
	errorCode = 0;
	//get hostname
	errorCode = [sshClient runCommand:@"hostname"];
	if (errorCode) {
		NSLog(@"Failed to get hostname. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[hypertable setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		return;
	}
	NSString * hostname = [[sshClient output] stringByTrimmingCharactersInSet:
						   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSLog(@"Server hostname: %@", hostname);
	[hypertable setValue:hostname forKey:@"hostname"];
	
	//check hypertable
	errorCode = [sshClient runCommand:@"stat /opt/hypertable/current"];
	if (errorCode) {
		NSLog(@"Failed to stat /opt/hypertable/current. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[hypertable setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		return;
	}
	
	//get current dfs
	errorCode = [sshClient runCommand:@"cat /opt/hypertable/current/run/last-dfs"];
	if (errorCode) {
		NSLog(@"Failed to get /opt/hypertable/current/run/last-dfs. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
	}
	else {
		NSString * currentDfs = [[sshClient output] stringByTrimmingCharactersInSet:
								 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"Current DFS: %@", currentDfs);
		[hypertable setValue:currentDfs forKey:@"currentDfs"];
	}
	
	NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
	NSManagedObject * masterService;
	NSManagedObject * rangeService;
	NSManagedObject * hyperspaceService;
	NSManagedObject * dfsService;
	NSManagedObject * thriftService;
	
	//get available services
	errorCode = [sshClient runCommand:@"ls -l /opt/hypertable/current/bin"];
	if (errorCode) {
		NSLog(@"Failed to list available services. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[hypertable setValue:[NSNumber numberWithInt:1] forKey:@"status"];
		[[sshClient sshLock] unlock];
		return;
	}
	
	//parse available services
	NSArray * lines = [[sshClient output] componentsSeparatedByString:@"\n"];
	for (int lineIndex = 0; lineIndex < [lines count]; lineIndex++) {
		NSString * line = [lines objectAtIndex:lineIndex];
		
		if ([line rangeOfString:@"ThriftBroker"].location != NSNotFound) {
			NSLog(@"Found Thrift Broker.");
			thriftService = [Service thriftService:context onServer:hypertable];
			[thriftService setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
		}
		if ([line rangeOfString:@"start-dfsbroker.sh"].location != NSNotFound) {
			//if there was another dfs broker used before, set it up too
			dfsService = [Service dfsBrokerService:context onServer:hypertable 
										   withDfs:[hypertable valueForKey:@"currentDfs"]];
			[dfsService setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
			NSLog(@"Found DFS Broker (%@).", [hypertable valueForKey:@"currentDfs"]);
		}
		if ([line rangeOfString:@"start-hyperspace.sh"].location != NSNotFound) {
			NSLog(@"Found HyperSpace Service.");
			hyperspaceService = [Service hyperspaceService:context onServer:hypertable];
			[hyperspaceService setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
		}
		if ([line rangeOfString:@"start-rangeserver.sh"].location != NSNotFound) {
			NSLog(@"Found Range Server.");
			rangeService = [Service rangerService:context onServer:hypertable];
			[rangeService setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
		}
		if ([line rangeOfString:@"start-master.sh"].location != NSNotFound) {
			NSLog(@"Found Master Service.");
			masterService = [Service masterService:context onServer:hypertable];
			[masterService setValue:[NSNumber numberWithInt:-1] forKey:@"processID"];
		}
	}
	
	//get running services
	errorCode = [sshClient runCommand:@"ls -l /opt/hypertable/current/run/*.pid"];
	if (errorCode == 0) {
		//parse running services pids
		[[sshClient output] enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop){
			if ([line rangeOfString:@"DfsBroker"].location != NSNotFound) {
				errorCode = [sshClient runCommand:[NSString stringWithFormat:@"cat %@", [dfsService valueForKey:@"getPid"]]];
				if (errorCode == 0) {
					int pid = [[sshClient output] intValue];
					[dfsService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
					NSLog(@"DFS Broker is running with pid %d", pid);
				}
			}
			if ([line rangeOfString:@"Hyperspace"].location != NSNotFound) {
				errorCode = [sshClient runCommand:[NSString stringWithFormat:@"cat %@", [hyperspaceService valueForKey:@"getPid"]]];
				if (errorCode == 0) {
					int pid = [[sshClient output] intValue];
					[hyperspaceService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
					NSLog(@"Hyperspace is running with pid %d", pid);
				}
			}
			if ([line rangeOfString:@"Hypertable.Master"].location != NSNotFound) {
				errorCode = [sshClient runCommand:[NSString stringWithFormat:@"cat %@", [masterService valueForKey:@"getPid"]]];
				if (errorCode == 0) {
					int pid = [[sshClient output] intValue];
					[masterService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
					NSLog(@"HyperTable.Master is running with pid %d", pid);
				}
			}
			if ([line rangeOfString:@"Hypertable.RangeServer"].location != NSNotFound) {
				errorCode = [sshClient runCommand:[NSString stringWithFormat:@"cat %@", [rangeService valueForKey:@"getPid"]]];
				if (errorCode == 0) {
					int pid = [[sshClient output] intValue];
					[rangeService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
					NSLog(@"HyperTable.RangeServer is running with pid %d", pid);
				}
			}
			if ([line rangeOfString:@"ThriftBroker"].location != NSNotFound) {
				errorCode = [sshClient runCommand:[NSString stringWithFormat:@"cat %@", [thriftService valueForKey:@"getPid"]]];
				if (errorCode == 0) {
					int pid = [[sshClient output] intValue];
					[thriftService setValue:[NSNumber numberWithInt:pid] forKey:@"processID"];
					NSLog(@"ThriftBroker is running with pid %d", pid);
				}
			}
			
		}];
	}
	
	//get load
	errorCode = [sshClient runCommand:@"cat /proc/loadavg"];
	if (errorCode) {
		NSLog(@"Failed to get /proc/loadavg. Code: %d, Error: %s", errorCode,
			  [[sshClient error] UTF8String]);
		[self setErrorMessage:[sshClient error]];
		[hypertable setValue:[NSNumber numberWithInt:1] forKey:@"status"];
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
	
	[hypertable setValue:[NSNumber numberWithInt:healthLevel] forKey:@"health"];
	[hypertable setValue:[NSNumber numberWithInt:healthPercent] forKey:@"healthPercent"];
	NSLog(@"Server health: %d %%. Level: %d", healthPercent, healthLevel);
	
	//set status to 0 == Operational
	[hypertable setValue:[NSNumber numberWithInt:0] forKey:@"status"];
	[[NSApp delegate] saveAction:nil];
	
	[[sshClient sshLock] unlock];
}


@end
