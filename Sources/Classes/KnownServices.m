//
//  KnownServices.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "KnownServices.h"


@implementation KnownServices

+ (NSManagedObject *) newMasterService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
										 inManagedObjectContext:inContent ];
	[service setValue:server forKey:@"runsOnServer"];
	[service setValue:@"Master" forKey:@"serviceName"];
	[service setValue:@"/opt/hypertable/current/bin/start-master.sh" forKey:@"startService"];
	[service setValue:@"kill `cat /opt/hypertable/current/run/Hypertable.Master.pid`" forKey:@"stopService"];
	[service setValue:@"cat /opt/hypertable/current/run/Hypertable.Master.pid" forKey:@"getPid"];
	
	return service;
}

+ (NSManagedObject *) newRangerService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
															  inManagedObjectContext:inContent ];
	[service setValue:server forKey:@"runsOnServer"];
	[service setValue:@"Range Server" forKey:@"serviceName"];
	[service setValue:@"/opt/hypertable/current/bin/start-rangeserver.sh" forKey:@"startService"];
	[service setValue:@"kill `cat /opt/hypertable/current/run/Hypertable.RangeServer.pid`" forKey:@"stopService"];
	[service setValue:@"cat /opt/hypertable/current/run/Hypertable.RangeServer.pid" forKey:@"getPid"];
	
	return service;
}

+ (NSManagedObject *) newDfsBrokerService:(NSManagedObjectContext *)inContent
								 onServer:(NSManagedObject *)server
								  withDfs:(NSString *)dfs
{
	NSManagedObject * service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
															  inManagedObjectContext:inContent ];
	[service setValue:server forKey:@"runsOnServer"];
	[service setValue:@"DFS Broker" forKey:@"serviceName"];
	[service setValue:[NSString stringWithFormat:@"/opt/hypertable/current/bin/start-dfsbroker.sh %@", dfs]
			   forKey:@"startService"];
	[service setValue:[NSString stringWithFormat:@"kill `cat /opt/hypertable/current/run/DfsBroker.%@.pid`", dfs]
			   forKey:@"stopService"];
	[service setValue:@"cat /opt/hypertable/current/run/Hypertable.RangeServer.pid" forKey:@"getPid"];
	
	return service;
}

+ (NSManagedObject *) newHyperspaceService:(NSManagedObjectContext *)inContent
								  onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
															  inManagedObjectContext:inContent ];
	[service setValue:server forKey:@"runsOnServer"];
	[service setValue:@"Hyperspace" forKey:@"serviceName"];
	[service setValue:@"/opt/hypertable/current/bin/start-hyperspace.sh" forKey:@"startService"];
	[service setValue:@"/opt/hypertable/current/bin/stop-hyperspace.sh" forKey:@"stopService"];
	[service setValue:@"cat /opt/hypertable/current/run/Hyperspace.pid" forKey:@"getPid"];
	
	return service;
}

+ (NSManagedObject *) newThriftService:(NSManagedObjectContext *)inContent
							  onServer:(NSManagedObject *)server
{
	NSManagedObject * service = [NSEntityDescription insertNewObjectForEntityForName:@"Service" 
															  inManagedObjectContext:inContent ];
	[service setValue:server forKey:@"runsOnServer"];
	[service setValue:@"Thrift API" forKey:@"serviceName"];
	[service setValue:@"/opt/hypertable/current/bin/start-thriftbroker.sh" forKey:@"startService"];
	[service setValue:@"kill `cat /opt/hypertable/current/run/ThriftBroker.pid`" forKey:@"stopService"];
	[service setValue:@"cat /opt/hypertable/current/run/ThriftBroker.pid" forKey:@"getPid"];
	
	return service;
}
//+ (NSManagedObject *) newHdfsbrkService:(NSManagedObjectContext *)inContent;
@end
