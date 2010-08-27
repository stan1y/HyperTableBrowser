//
//  ClusterStatusOperation.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 27/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "ClusterStatusOperation.h"

@implementation ClusterStatusOperation

@synthesize cluster;

- (id) init
{
	if ( !(self == [super init])) {
		return nil;
	}
	
	operationsLock = [[NSLock alloc] init];
	operationsCount = 0;
	
	return self;
}

- (void) dealloc
{
	[operationsLock release];
	
	[super dealloc];
}

+ (ClusterStatusOperation *) getStatusOfCluster:(Cluster *)aCluster
{
	ClusterStatusOperation * op = [[ClusterStatusOperation alloc] init];
	[op setCluster:aCluster];
	
	return op;
}

- (void) main
{
	NSLog(@"Updating members of cluster %@", [cluster valueForKey:@"name"]);
	
	for (Server * member in [cluster members]) {
		//increase from current thread
		[operationsLock lock];
		operationsCount += 1;
		[operationsLock unlock];
		
		//spawn child update threads
		[member updateWithCompletionBlock:^{
			
			//decrease from tread
			[operationsLock lock];
			operationsCount -= 1;
			[operationsLock unlock];
		}];
	}
	
	int secondsToWait = 2;
	int totalWaited = 0;
	while (YES) {
		//waiting for children
		NSLog(@"Waiting %d seconds for members update...", secondsToWait);
		sleep(secondsToWait);
		totalWaited += secondsToWait;
		
		[operationsLock lock];
		if (operationsCount == 0) {
			[operationsLock unlock];
			NSLog(@"All members updated...");
			return;
		}
		
		NSLog(@"%d member updates in progress..", operationsCount);
		[operationsLock unlock];
		
		//increase wait time of timeout
		if (totalWaited >= 30) {
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			[dict setValue:[NSString stringWithFormat:@"Timeout updating %@ members.", [cluster valueForKey:@"name"]] 
					forKey:NSLocalizedDescriptionKey];
			NSError * error = [NSError errorWithDomain:@"HyperTableBrowser" code:2 userInfo:dict];
			[[NSApplication sharedApplication] presentError:error];
			
			return;
		}
		secondsToWait *= 2;
	}
}

@end
