//
//  Utility.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Utility.h"

#pragma mark HyperTable Brokers Controller

@implementation HyperTableBrokersCntrl

@synthesize brokerSelector;

- (void) addAndReconnect:(id)hypertable withCompletionBlock:(void (^)(void)) codeBlock
{
	if ( ![hypertable isConnected]) {
		[hypertable reconnect:codeBlock];
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
	id brokersList = [HyperTable hyperTableBrokersInCurrentCluster];
	for (id hypertable in brokersList) {
		//connect or add each available broker
		[self addAndReconnect:hypertable withCompletionBlock:^ {
			if ( ![hypertable isConnected] ) {
				[[NSApp delegate] showErrorDialog:1 
										  message:[NSString stringWithFormat:@"Please make sure that Thrift API service is running on %@",
												   [hypertable valueForKey:@"name"]]];		
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

#pragma mark Value Transformers

@implementation StatusValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value 
{
	int intStatus = [value intValue];
	NSString * status;
	
	switch (intStatus) {
		case 0:
			status = @"Operational";
			break;
		case 1:
			status = @"Error";
			break;
		default:
			status = @"Pending...";
			break;
	}
	
	return status;
}
@end

@implementation ServerSummaryTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value 
{
	int runningServices = 0;
	for (id service in [value services]) {
		if ([[service valueForKey:@"processID"] intValue] > 0) {
			runningServices++;
		}
	}
	return [NSString stringWithFormat:@"%d of %d services running", 
			runningServices, [[value services] count]];
}
@end
