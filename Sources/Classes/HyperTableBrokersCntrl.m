//
//  HyperTableBrokersCntrl.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import "HyperTableBrokersCntrl.h"
#import "HyperTable.h"
#import "ClustersBrowser.h"

@implementation HyperTableBrokersCntrl

@synthesize brokerSelector;

- (void) addAndUpdate:(id)hypertable withCompletionBlock:(void (^)(BOOL)) codeBlock
{
	[hypertable updateTablesWithCompletionBlock:codeBlock];
	[brokerSelector addItemWithTitle:[hypertable valueForKey:@"name"]];
}

- (void) updateBrokersWithCompletionBlock:(void (^)(BOOL)) codeBlock
{
	[brokerSelector removeAllItems];
	id brokersList = [HyperTable hyperTableBrokersInCurrentCluster];
	if (![brokersList count]) {
		NSRunAlertPanel(@"Table Browser Problem", [NSString stringWithFormat:@"No Thrift API Brokers were found in cluster %@", [[[ClustersBrowser sharedInstance] selectedCluster] valueForKey:@"name"] ], @"Continue", nil, nil);
		return;
	}
	
	for (id hypertable in brokersList) {
		[self addAndUpdate:hypertable withCompletionBlock:codeBlock];
	}
}
															
- (IBAction)updateBrokers:(id)sender
{
	NSLog(@"Updating available brokers...");
	//populate selector
	[brokerSelector removeAllItems];
	NSArray * brokersList = [HyperTable hyperTableBrokersInCurrentCluster];
	if (![brokersList count]) {
		NSRunAlertPanel(@"Table Browser Problem", [NSString stringWithFormat:@"No Thrift API Brokers were found in cluster %@", [[[ClustersBrowser sharedInstance] selectedCluster] valueForKey:@"name"] ], @"Continue", nil, nil);
		return;
	}
	
	for (HyperTable * hypertable in brokersList) {
		//connect or add each available broker
		[self addAndUpdate:hypertable withCompletionBlock:^(BOOL success) {
			if ( !success ) {
				NSRunAlertPanel(@"Connection failed", [NSString stringWithFormat:@"Please make sure that Thrift API service is running on %@",
														 [hypertable valueForKey:@"name"]] , @"Continue", nil, nil);
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
