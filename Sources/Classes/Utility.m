//
//  Utility.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Utility.h"

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
	id services = [[[NSApp delegate] clusterManager] servicesOnServer:value];
	int runningServices = 0;
	for (id service in services) {
		if ([[service valueForKey:@"processID"] intValue] > 0) {
			runningServices++;
		}
	}
	return [NSString stringWithFormat:@"%d of %d services running", 
			runningServices, [services count]];
}
@end

@implementation ServiceStatusTransformer

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value 
{
	if (value > 0) {
		return [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceStatusRunning" ofType:@"png"]];
	}
	else {
		return [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceStatusStopped" ofType:@"png"]];
	}

}
@end
