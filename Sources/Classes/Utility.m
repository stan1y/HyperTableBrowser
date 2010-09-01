//
//  Utility.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "Utility.h"
#import "HyperTable.h"
#import "ClustersBrowser.h"

@implementation HyperTableBrokersCntrl

@synthesize brokerSelector;

- (void) addAndReconnect:(id)hypertable withCompletionBlock:(void (^)(void)) codeBlock
{
	if ( ![hypertable isConnected]) {
		[hypertable reconnectWithCompletionBlock:codeBlock];
	}
	[brokerSelector addItemWithTitle:[hypertable valueForKey:@"name"]];
}

- (void) updateBrokers:(id)sender withCompletionBlock:(void (^)(void)) codeBlock
{
	[brokerSelector removeAllItems];
	id brokersList = [HyperTable hyperTableBrokersInCurrentCluster];
	for (id hypertable in brokersList) {
		[self addAndReconnect:hypertable withCompletionBlock:codeBlock];
	}
}
															
- (IBAction)updateBrokers:(id)sender
{
	NSLog(@"Updating available brokers...");
	//populate selector
	[brokerSelector removeAllItems];
	NSArray * brokersList = [HyperTable hyperTableBrokersInCurrentCluster];
	if (![brokersList count]) {
		NSMutableDictionary * dict = [NSMutableDictionary dictionary];
		[dict setValue:[NSString stringWithFormat:@"No Thrift API Brokers were found in cluster %@",
						[[[ClustersBrowser sharedInstance] selectedCluster] valueForKey:@"name"]] 
				forKey:NSLocalizedDescriptionKey];
		NSError * error = [NSError errorWithDomain:@"Thrift API" code:1 userInfo:dict];
		[[NSApplication sharedApplication] presentError:error];
		return;
	}
	
	for (HyperTable * hypertable in brokersList) {
		//connect or add each available broker
		[self addAndReconnect:hypertable withCompletionBlock:^ {
			if ( ![hypertable isConnected] ) {
				NSMutableDictionary * dict = [NSMutableDictionary dictionary];
				[dict setValue:[NSString stringWithFormat:@"Please make sure that Thrift API service is running on %@",
								[hypertable valueForKey:@"name"]] 
						forKey:NSLocalizedDescriptionKey];
				NSError * error = [NSError errorWithDomain:@"Thrift API" code:1 userInfo:dict];
				[[NSApplication sharedApplication] presentError:error];
			}
			else {
				NSLog(@"Reconnected to thrift broker at %@ successfuly.",
					  [hypertable valueForKey:@"name"]);
				[brokerSelector addItemWithTitle:[hypertable valueForKey:@"name"]];
			}
		}];
	}
}

- (HyperTable *) selectedBroker {
	if ( ![[[brokerSelector selectedItem] title] length] ) {
		//return first available one if none selected
		if ([[HyperTable hyperTableBrokersInCurrentCluster] count] > 0) {
			return [[HyperTable hyperTableBrokersInCurrentCluster] objectAtIndex:0];
		}
		
		//or nil if none available
		return nil;
	}
	
	for (HyperTable * hypertable in [HyperTable hyperTableBrokersInCurrentCluster]) {
		if ([[brokerSelector selectedItem] title] == [hypertable valueForKey:@"name"]) {
			return hypertable;
		}
	}
	//none connected
	return nil;
}

@end
