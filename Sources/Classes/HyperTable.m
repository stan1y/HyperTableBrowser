//
//  HyperTable.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "HyperTable.h"
#import "FetchTablesOperation.h"
#import "FetchPageOperation.h"
#import "HyperTableOperation.h"
#import "ConnectOperation.h"
#import "Service.h"
#import "ClustersBrowser.h"
#import "Activities.h"

@implementation HyperTable

@synthesize thriftClient;
@synthesize hqlClient;
@synthesize connectionLock;

@synthesize lastFetchedIndex;
@synthesize lastFetchedTotalIndexes;

// Class Methods

+ (NSString *)errorFromCode:(int)code {
	switch (code) {
		case T_ERR_CLIENT:
			return @"Failed to execute. Check syntax.";
			break;
		case T_ERR_TRANSPORT:
			return @"Connection failed. Check Thrift broker is running.";
			break;
		case T_ERR_NODATA:
			return @"No data returned from query, where is was expected to.";
			break;
		case T_ERR_TIMEOUT:
			return @"Operation timeout. Check HyperTable is running correctly.";
			break;
		case T_ERR_APPLICATION:
			return @"System error occured. Either your HyperTable server is incompatible with this client application or it had experienced problem service the request";
			break;
			
		case T_OK:
		default:
			return @"Executed successfuly.";
			break;
	}
}

+ (NSEntityDescription *) hypertableDescription
{
	return [NSEntityDescription entityForName:@"HyperTable" 
					   inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

+ (NSArray *) hyperTableBrokersInCurrentCluster;
{
	return [HyperTable hyperTableBrokersInCluster:[[ClustersBrowser sharedInstance] selectedCluster]];
}

+ (NSArray *) hypertablesInCurrentCluster
{
	return [HyperTable hypertablesInCluster:[[ClustersBrowser sharedInstance] selectedCluster]];
}

+ (NSArray *) hyperTableBrokersInCluster:(id)cluster
{
	if (!cluster) {
		return nil;
	}
	
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Service serviceDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"serviceName == \"Thrift API\" && runsOnServer.belongsTo = %@", cluster]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to fetch HyperTable brokers.");
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	
	//get servers from services
	NSMutableArray * serversArray = [NSMutableArray array];
	for (id service in servicesArray) {
		[serversArray addObject:[service valueForKey:@"runsOnServer"]];
	}
	
	return serversArray;
}

+ (NSArray *) hypertablesInCluster:(id)cluster
{
	if (!cluster) {
		return nil;
	}
	
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[HyperTable hypertableDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"belongsTo = %@", cluster]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * array = [[[NSApp delegate] managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to fetch HyperTables.");
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	
	return array;
}



//	Initialization

- (id) init
{
	if (self = [super init] ) {
		connectionLock = [[NSLock alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[connectionLock release];
	
	if (thriftClient) {
		free(thriftClient);
		thriftClient = nil;
	}
	
	if (hqlClient) {
		free(hqlClient);
		hqlClient = nil;
	}
	[super dealloc];
}

//	ClusterMember implementation

- (void) updateStatusWithCompletionBlock:(void (^)(BOOL))codeBlock;
{
	HyperTableStatusOperation * op = [HyperTableStatusOperation getStatusOfHyperTable:self];
	[op setCompletionBlock: ^{
		if ([op errorCode] != 0) {
			codeBlock(NO);
		}
		else {
			codeBlock(YES);
		}

	}];
	[[Activities sharedInstance] appendOperation:op withTitle:[NSString stringWithFormat:@"Updating %@ [%@]", [self valueForKey:@"name"], [self class]]];
	[op release];
}

- (NSArray *)services
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[NSEntityDescription entityForName:@"Service" 
							 inManagedObjectContext:[self managedObjectContext]]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"runsOnServer = %@", self]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get services on server %@.", [self valueForKey:@"name"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	if (![servicesArray count]) {
		return nil;
	}
	
	return servicesArray;
}

- (Service *) serviceWithName:(NSString *)name;
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Service serviceDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"runsOnServer = %@ && serviceName = %@", 
					 self, 
					 name] ];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get services on server %@.", [self valueForKey:@"name"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	if (![servicesArray count]) {
		return nil;
	}
	else if ([servicesArray count] > 1) {
		NSLog(@"Multiple (%d) services with name \"%@\" found on server \"%@\"",
			  [servicesArray count], name, [self valueForKey:@"name"]);
	}
	return [servicesArray objectAtIndex:0];
}


// CellStorage implementation

- (BOOL)isConnected 
{
	return ( (thriftClient != nil) && (hqlClient != nil) );
}

- (void) _updateTablesWithCompletionBlock:(void (^)(void))codeBlock
{
	FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFrom:self];
	[fetchTablesOp setCompletionBlock:codeBlock];
	[[Activities sharedInstance] appendOperation:fetchTablesOp withTitle:[NSString stringWithFormat:@"Update tables on server %@(%@)", [self valueForKey:@"name"], [self class]]];
	[fetchTablesOp release];
}

- (void) updateTablesWithCompletionBlock:(void (^)(void))codeBlock
{
	if ( ![self isConnected]) {
		//reconnect server with saved values
		NSLog(@"Opening connection to HyperTable Thrift Broker at %@:%d...",
			  [self valueForKey:@"ipAddress"],
			  [[self valueForKey:@"thriftPort"] intValue]);		
		ConnectOperation * connectOp = [ConnectOperation connect:self 
														toBroker:[self valueForKey:@"ipAddress"]
														  onPort:[[self valueForKey:@"thriftPort"] intValue]];
		[connectOp setCompletionBlock: ^{
			//update after connected
			if ([self isConnected]) {
				[self _updateStatusWithCompletionBlock:codeBlock];
			}
		}];
				
		//add operation to queue
		[[Activities sharedInstance] appendOperation:connectOp withTitle:[NSString stringWithFormat:@"Reconnecting to server %@(%@)", [self valueForKey:@"name"], [self class]]];
		[connectOp release];	
	}
	else {
		//it was connected
		[self _updateTablesWithCompletionBlock:codeBlock];
	}

}

- (NSArray *) tables
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[NSEntityDescription entityForName:@"Table" 
							 inManagedObjectContext:[self managedObjectContext]]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"onServer = %@", self]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"tableID" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get tables list from server  %@.", [self valueForKey:@"name"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	if (![servicesArray count]) {
		return nil;
	}
	
	return servicesArray;
}

- (void)fetchPageFrom:(id)tableID number:(int)number ofSize:(int)size 
	   withCompletionBlock:(void (^)(DATA_PAGE))codeBlock
{
	FetchPageOperation * fpageOp = [FetchPageOperation fetchPageFrom:self
															withName:tableID
															 atIndex:number
															 andSize:size];
	[fpageOp setCompletionBlock: ^{
		if ([fpageOp errorCode] == T_OK ) {
			DataPage * receivedPage = [fpageOp page];
			if (receivedPage) {
				//call user's code block with received page
				codeBlock(receivedPage);
			}
		}
	}];
	
	//start async operation
	[[Activities sharedInstance] appendOperation: fpageOp withTitle:[NSString stringWithFormat:@"Fetching page from server %@", [self valueForKey:@"name"]]];
	[fpageOp release];
	
}

- (void) fetchCellsFrom:(id)tableID forKeys:(NSArray *)keys withCompletionBlock:(void (^)(NSArray *))codeBlock
{
}


@end
