//
//  Service.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Service.h"
#import "ServiceOperation.h"
#import "Activities.h"

@implementation Service

#pragma mark Initialization

+ (NSEntityDescription *) serviceDescription
{
	return [NSEntityDescription entityForName:@"Service" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

#pragma mark Service Control API

- (void) waitUntilStatus:(BOOL)shouldBeRunning
{
	int sleepSecs = 2;
	do {
		NSLog(@"Waiting to service status change to %@ for %d seconds...", 
			  shouldBeRunning,
			  sleepSecs);
		
		sleep(sleepSecs);
		sleepSecs = sleepSecs * 2;
		
	} while (shouldBeRunning != [self isRunning]);
}

- (void) start:(void (^)(void)) codeBlock;
{
	ServiceOperation * sOp = [ServiceOperation startService:self];
	[sOp setCompletionBlock:codeBlock];
	
	[[Activities sharedInstance] appendOperation:sOp withTitle:[NSString stringWithFormat:@"Stopping service %@ on server %@", [self valueForKey:@"serviceName"], [[self valueForKey:@"runsOnServer"] valueForKey:@"serviceName"]]];
	[sOp release];
}

- (void) stop:(void (^)(void)) codeBlock;
{
	ServiceOperation * sOp = [ServiceOperation stopService:self];
	[sOp setCompletionBlock:codeBlock];
	[[Activities sharedInstance] appendOperation:sOp withTitle:[NSString stringWithFormat:@"Stopping service %@ on server %@", [self valueForKey:@"serviceName"], [[self valueForKey:@"runsOnServer"] valueForKey:@"serviceName"]]];
	[sOp release];
}

- (BOOL) isRunning
{
	return ([[self valueForKey:@"processID"] intValue] > 0);
}

#pragma mark Known Services

+ (Service *) masterService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server
{
	
	Service * service = [server serviceWithName:@"Master"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Master" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-master.sh" forKey:@"startService"];
		[service setValue:@"kill -9 `cat /opt/hypertable/current/run/Hypertable.Master.pid`" forKey:@"stopService"];
		[service setValue:@"/opt/hypertable/current/run/Hypertable.Master.pid" forKey:@"getPid"];
	}
	return service;
}

+ (Service *) rangerService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server
{
	Service * service = [server serviceWithName:@"Range Server"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Range Server" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-rangeserver.sh" forKey:@"startService"];
		[service setValue:@"kill -9 `cat /opt/hypertable/current/run/Hypertable.RangeServer.pid`" forKey:@"stopService"];
		[service setValue:@"/opt/hypertable/current/run/Hypertable.RangeServer.pid" forKey:@"getPid"];
	}
	return service;
}

+ (Service *) dfsBrokerService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
							   withDfs:(NSString *)dfs
{
	Service * service = [server serviceWithName:[NSString stringWithFormat:@"%@ DFS", [dfs capitalizedString]]];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:[NSString stringWithFormat:@"%@ DFS", [dfs capitalizedString]] forKey:@"serviceName"];
		[service setValue:[NSString stringWithFormat:@"/opt/hypertable/current/bin/start-dfsbroker.sh %@", dfs]
				   forKey:@"startService"];
		[service setValue:[NSString stringWithFormat:@"kill -9 `cat /opt/hypertable/current/run/DfsBroker.%@.pid`", dfs]
				   forKey:@"stopService"];
		[service setValue:[NSString stringWithFormat:@"/opt/hypertable/current/run/DfsBroker.%@.pid", dfs]
				   forKey:@"getPid"];
	}
	return service;
}

+ (Service *) hyperspaceService:(NSManagedObjectContext *)inContent
							   onServer:(NSManagedObject *)server
{
	Service * service = [server serviceWithName:@"Hyperspace"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Hyperspace" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-hyperspace.sh" forKey:@"startService"];
		[service setValue:@"/opt/hypertable/current/bin/stop-hyperspace.sh" forKey:@"stopService"];
		[service setValue:@"/opt/hypertable/current/run/Hyperspace.pid" forKey:@"getPid"];
	}
	return service;
}

+ (Service *) thriftService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server
{
	Service * service = [server serviceWithName:@"Thrift API"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Thrift API" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-thriftbroker.sh" forKey:@"startService"];
		[service setValue:@"kill -9 `cat /opt/hypertable/current/run/ThriftBroker.pid`" forKey:@"stopService"];
		[service setValue:@"/opt/hypertable/current/run/ThriftBroker.pid" forKey:@"getPid"];
	}
	return service;
}

@end
