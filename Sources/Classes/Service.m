//
//  Service.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Service.h"
#import "ServiceOperation.h"

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
	[[[NSApp delegate] operations] addOperation:sOp];
	[sOp release];
}

- (void) stop:(void (^)(void)) codeBlock;
{
	ServiceOperation * sOp = [ServiceOperation stopService:self];
	[sOp setCompletionBlock:codeBlock];
	[[[NSApp delegate] operations] addOperation:sOp];
	[sOp release];
}

- (BOOL) isRunning
{
	return ([[self valueForKey:@"processID"] intValue] > 0);
}

#pragma mark Known Services

+ (NSManagedObject *) masterService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server
{
	
	NSManagedObject * service = [server serviceWithName:@"Master"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Master" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-master.sh" forKey:@"startService"];
		[service setValue:@"kill `cat /opt/hypertable/current/run/Hypertable.Master.pid`" forKey:@"stopService"];
		[service setValue:@"cat /opt/hypertable/current/run/Hypertable.Master.pid" forKey:@"getPid"];
	}
	return service;
}

+ (NSManagedObject *) rangerService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [server serviceWithName:@"Range Server"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Range Server" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-rangeserver.sh" forKey:@"startService"];
		[service setValue:@"kill `cat /opt/hypertable/current/run/Hypertable.RangeServer.pid`" forKey:@"stopService"];
		[service setValue:@"cat /opt/hypertable/current/run/Hypertable.RangeServer.pid" forKey:@"getPid"];
	}
	return service;
}

+ (NSManagedObject *) dfsBrokerService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
							   withDfs:(NSString *)dfs
{
	NSManagedObject * service = [server serviceWithName:@"DFS Broker"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"DFS Broker" forKey:@"serviceName"];
		[service setValue:[NSString stringWithFormat:@"/opt/hypertable/current/bin/start-dfsbroker.sh %@", dfs]
				   forKey:@"startService"];
		[service setValue:[NSString stringWithFormat:@"kill `cat /opt/hypertable/current/run/DfsBroker.%@.pid`", dfs]
				   forKey:@"stopService"];
		[service setValue:[NSString stringWithFormat:@"cat /opt/hypertable/current/run/DfsBroker.%@.pid", dfs]
				   forKey:@"getPid"];
	}
	return service;
}

+ (NSManagedObject *) hyperspaceService:(NSManagedObjectContext *)inContent
							   onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [server serviceWithName:@"Hyperspace"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Hyperspace" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-hyperspace.sh" forKey:@"startService"];
		[service setValue:@"/opt/hypertable/current/bin/stop-hyperspace.sh" forKey:@"stopService"];
		[service setValue:@"cat /opt/hypertable/current/run/Hyperspace.pid" forKey:@"getPid"];
	}
	return service;
}

+ (NSManagedObject *) thriftService:(NSManagedObjectContext *)inContent
						   onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [server serviceWithName:@"Thrift API"];
	if (!service) {
		service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
												inManagedObjectContext:inContent ];
		[service setValue:server forKey:@"runsOnServer"];
		[service setValue:@"Thrift API" forKey:@"serviceName"];
		[service setValue:@"/opt/hypertable/current/bin/start-thriftbroker.sh" forKey:@"startService"];
		[service setValue:@"kill `cat /opt/hypertable/current/run/ThriftBroker.pid`" forKey:@"stopService"];
		[service setValue:@"cat /opt/hypertable/current/run/ThriftBroker.pid" forKey:@"getPid"];
	}
	return service;
}

@end
