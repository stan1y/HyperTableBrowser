//
//  HyperTable.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "HyperTable.h"
#import "FetchTablesOperation.h"
#import "FetchPageOperation.h"
#import "HyperTableOperation.h"
#import "ConnectOperation.h"
#import "DeleteRowOperation.h"
#import "SetRowOperation.h"
#import "Service.h"
#import "ClustersBrowser.h"
#import "Activities.h"
#import "Table.h"

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
	//get running thrift api services
	[r setPredicate:[NSPredicate predicateWithFormat:@"processID > 0 && serviceName == \"Thrift API\" && runsOnServer.belongsTo = %@", cluster]];
	
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
	[[Activities sharedInstance] appendOperation:op withTitle:[NSString stringWithFormat:@"Updating %@ [%@]", [self valueForKey:@"serverName"], [self class]]];
	[op release];
}

- (NSArray *)services
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Service serviceDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"runsOnServer = %@", self]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"serviceName" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * servicesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get services on server %@.", [self valueForKey:@"serverName"]);
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
		NSLog(@"Error: Failed to get services on server %@.", [self valueForKey:@"serverName"]);
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
			  [servicesArray count], name, [self valueForKey:@"serverName"]);
	}
	return [servicesArray objectAtIndex:0];
}


// CellStorage implementation

- (BOOL)isConnected 
{
	return ( (thriftClient != nil) && (hqlClient != nil) );
}

- (void) _updateTablesWithCompletionBlock:(void (^)(BOOL))codeBlock
{
	FetchTablesOperation * fetchTablesOp = [FetchTablesOperation fetchTablesFrom:self];
	[fetchTablesOp setCompletionBlock: ^{
		if ([fetchTablesOp errorCode]) {
			codeBlock(NO);
		}
		else {
			codeBlock(YES);
		}

	}];
	[[Activities sharedInstance] appendOperation:fetchTablesOp withTitle:[NSString stringWithFormat:@"Update tables on server %@(%@)", [self valueForKey:@"serverName"], [self class]]];
	[fetchTablesOp release];
}

- (void) updateTablesWithCompletionBlock:(void (^)(BOOL))codeBlock
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
				[self _updateTablesWithCompletionBlock:codeBlock];
			}
		}];
				
		//add operation to queue
		[[Activities sharedInstance] appendOperation:connectOp withTitle:[NSString stringWithFormat:@"Reconnecting to server %@(%@)", [self valueForKey:@"serverName"], [self class]]];
		[connectOp release];	
	}
	else {
		//it was connected
		[self _updateTablesWithCompletionBlock:codeBlock];
	}

}

- (NSArray *) tablesArray
{
	NSFetchRequest * r = [[NSFetchRequest alloc] init];
	[r setEntity:[Table tableDescription]];
	[r setIncludesPendingChanges:YES];
	[r setPredicate:[NSPredicate predicateWithFormat:@"onServer = %@", self]];
	NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"tableID" ascending:YES] autorelease];
	[r setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	NSError * err = nil;
	NSArray * tablesArray = [[self managedObjectContext] executeFetchRequest:r error:&err];
	if (err) {
		NSLog(@"Error: Failed to get tables list from server  %@.", [self valueForKey:@"serverName"]);
		[err release];
		[r release];
		return nil;
	}
	[err release];
	[r release];
	if (![tablesArray count]) {
		return nil;
	}
	
	return tablesArray;
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
			if (!receivedPage) {
				
				//show empty page if none fetched
				receivedPage = page_new();
			}
			codeBlock(receivedPage);
		}
		else {
			codeBlock(NULL);
		}

	}];
	
	//start async operation
	[[Activities sharedInstance] appendOperation: fpageOp withTitle:[NSString stringWithFormat:@"Fetching page from server %@", [self valueForKey:@"serverName"]]];
	[fpageOp release];
	
}

- (void) deleteRowWithKey:(NSString *)rowKey inTable:(NSString *)tableName withCompletionBlock:(void (^)(BOOL))codeBlock
{
	//drop row
	DeleteRowOperation * delOp = [DeleteRowOperation deleteRow:rowKey
													   inTable:tableName
													  onServer:self];
	
	[delOp setCompletionBlock: ^{
		if ([delOp errorCode])
			codeBlock(NO);
		else
			codeBlock(YES);
	}];
	
	//start async delete
	[[Activities sharedInstance] appendOperation:delOp withTitle:[NSString stringWithFormat:@"Deleting row with key %@ from table %@ on server %@", rowKey, tableName, [self valueForKey:@"serverName"]]];
	[delOp release];
}

- (void) setCell:(id)cellValue forRow:(NSString *)rowKey andColumn:(NSString *)column inTable:(NSString*)tableID  withCompletionBlock:(void (^)(BOOL)) codeBlock
{
	SetCellOperation * sop = [SetCellOperation setCellValue:cellValue forRow:rowKey andColumn:column inTable:tableID onServer:self];
	[sop setCompletionBlock:^{
		if ([sop errorCode]) {
			codeBlock(NO);
		}
		else {
			codeBlock(YES);
		}
	}];
	
	[[Activities sharedInstance] appendOperation: sop withTitle:[NSString stringWithFormat:@"Modifying cell in row %@, column %@ on server %@", rowKey, column, [self valueForKey:@"serverName"]]];
	[sop release];
}
																										   

@end
